# Live Migration: pvmove

An LV is a list of extent assignments. This part covers the operation that edits that list while the filesystem on top stays mounted and being written to: evacuating every extent off one PV so the disk underneath can be pulled.

## Give it somewhere to go first

A disk throwing SMART warnings has not failed yet — you can still read from it, which is exactly what a live migration needs. The strategy is: add a healthy disk to the same VG, move the data across, then drop the sick one. This is the "build upward" pattern, stopping one layer short of the LV:

- `pvcreate <spare>` writes an LVM label to the front of the raw disk — from "not LVM's" to "a PV that belongs to no VG yet". The disk must hold no data you want to keep; nothing else on it is touched.
- `vgextend <vg> <spare>` hands that PV to an existing volume group. LVM slices it into extents and adds them to the pool's free space — the mirror image of `vgreduce`.

Both commands only add free extents to the pool's bookkeeping. No LV's extent list changes, so no filesystem is affected — this step is uneventful by design.

### See it in your playground

**1. Load the disk-name variables into your shell:**
<!-- astrona:playground:renew -->

```sh
. /etc/playground-disks
```
```text
(no output)
```
The leading `.` is the shell's "source" command — it runs that file's `source_disk=...` lines directly in your current shell, so `$spare_disk` etc. now expand to real device paths in every command below. Nothing prints because it's just setting variables, not running a program.

Reminder: `/etc/playground-disks` only exists on this specific playground VM. Anywhere else, find the same disks with `lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,SERIAL` and reference them by their `/dev/disk/by-id/…` path instead of a `$…_disk` variable.

**2. Initialise the spare disk as a PV:**
```sh
sudo pvcreate "$spare_disk"
```
```text
  Physical volume "/dev/vde" successfully created.
```
Same `pvcreate` as for any new disk — `$spare_disk` just expands to `/dev/vde` here.

**3. Add that new PV to the existing volume group:**
```sh
sudo vgextend company_storage "$spare_disk"
```
```text
  Volume group "company_storage" successfully extended
```
`vgextend` takes an existing VG name (not an invented one this time — `company_storage` already exists in the playground) and a PV to fold into it.

**4. Confirm the VG now spans three disks:**
```sh
sudo vgs
```
```text
  VG               #PV #LV #SN Attr   VSize  VFree
  company_storage   3   1   0 wz--n- <2.99g <2.60g
```
`#PV 3` — up from 2. `#LV` is still `1` — nothing about `shared_documents`'s extent list changed; you've only given the pool somewhere new to send data to, which is the whole point of this step.

**5. List physical volumes to see the spare joined the pool:**
```sh
sudo pvs
```
```text
  PV        VG              Fmt  Attr PSize    PFree
  /dev/vdc  company_storage lvm2 a--  1020.00m  620.00m
  /dev/vdd  company_storage lvm2 a--  1020.00m 1020.00m
  /dev/vde  company_storage lvm2 a--  1020.00m 1020.00m
```
All three rows now show `VG = company_storage`. The new `/dev/vde` row shows `PFree` equal to `PSize` — entirely free, exactly like `/dev/vdc` and `/dev/vdd` did right after the volume group was created, before anything claimed their space.

## What `pvmove` actually does

> As an analogy: `pvmove` is a crew carrying crates from one hold to another while the ship is under way. They carry one crate at a time, and the manifest changes only after the crate sits in its new slot. If the crew stops halfway, no crate is lost. The analogy breaks down because the crew can also stop and restart days later from exactly where it left off.

`pvmove <source>` walks every extent the VG metadata assigns to `<source>`, and for each one:

1. Allocates a free extent on another PV in the VG.
2. Mirrors that one extent — the new copy stays in sync with the old while the copy is in progress, using the same live-mirroring machinery `mdadm` RAID 1 uses underneath (a temporary device-mapper mirror target, one per extent in flight).
3. Once the mirror reports in-sync, atomically flips the LV's extent-list entry to point at the new location and tears down the temporary mirror for that extent.

Because each extent is mirrored — not simply copied-then-cut-over — a write from a running application during the copy lands on **both** the old and new location until the flip, and after the flip the extent-list update is atomic. There is no window where an in-flight write could be lost or where the LV's map is inconsistent. This is also why a `pvmove` interrupted mid-run (a reboot, a `Ctrl-C`) is safe to resume: re-running the same command picks up wherever the extent list says it left off, because the list itself is the only source of truth about what has and has not moved yet.

`pvmove` is the only "relocate" verb in LVM — no `vgmove`, no `lvmove` — because extents are a property of the PV they currently sit on, not of a VG or LV as a whole. You name the PV to drain; LVM consults the extent list to find whichever LVs happen to have entries pointing at it, and moves those.

It needs somewhere to put the data: enough free extents on the *other* PVs in the VG, which is why `vgextend` with the spare has to happen first.

### See it in your playground

(Skip this if you already sourced `/etc/playground-disks` in the previous step and your shell session is still open — the variables are still set.)

**1. Start the migration off the failing disk:**
```sh
sudo pvmove "$source_disk"
```
```text
  /dev/vdc: Moved: 29.00%
  /dev/vdc: Moved: 100.00%
```
`pvmove` prints its own progress as it works through the extents — the percentages you see will differ run to run, and on a real (slower or bigger) disk you'd see more lines tick by before it reaches 100%.

**2. Check where the LV's extents ended up:**
```sh
sudo lvs -o +devices
```
```text
  LV                VG              Attr       LSize   Devices
  shared_documents  company_storage -wi-ao---- 400.00m /dev/vdd(0)
```
Compare this to the survey before the move, where `Devices` read `/dev/vdc(0)` — now it reads `/dev/vdd(0)`: every entry in `shared_documents`'s extent list has been rewritten to point at `second_disk` instead of `source_disk`. They all landed on one PV because `second_disk` had one contiguous free run big enough; if no single PV had had room, `Devices` would list two or more, e.g. `/dev/vdd(0),/dev/vde(0)` — a perfectly normal, if messier, extent list.

**3. Confirm the file that was there before the move is still there:**
```sh
cat /mnt/shared_documents/data.txt
```
```text
important production data
```
Same contents as before `pvmove` ran — the data moved to a different physical disk without the filesystem, or anything reading from it, ever being aware.

**4. Confirm the mount is unaffected:**
```sh
df -h /mnt/shared_documents
```
```text
(same output as the survey before the move — size, usage, and mount point all unchanged)
```
From the filesystem's point of view, nothing happened — which is exactly the guarantee `pvmove` is built to provide.

> *`pvmove` never "copies a disk" — it mirrors and re-points one extent at a time, which is what makes it both live-safe and resumable.*

## Common pitfalls

> [!WARNING]
> - **Running `pvmove` without a place to go.** The other PVs need free extents at least equal to what the source disk holds. Add a disk with `vgextend` first.
> - **Naming the wrong PV.** `pvmove /dev/vdc` empties `vdc`. Read the `Devices` column first and double-check the path.
> - **Stopping a move and forgetting it.** An interrupted `pvmove` leaves a temporary mirror volume behind. Run `sudo pvmove` with no arguments to resume it, or `sudo pvmove --abort` to cancel.
> - **Believing the move is finished because the command returned.** Run `sudo lvs -o +devices` and check that the old disk is gone from the list.
