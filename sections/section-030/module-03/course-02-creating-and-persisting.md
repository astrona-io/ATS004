# Part 2 — Creating & Persisting an Array

> Prerequisite: [Part 1 — RAID Levels](./course-01-raid-levels.md). Next: [Module landing page](./course.md).

Part 1 covered which level to pick. This part builds one, puts a filesystem on it, and — the step that's easy to skip and expensive to forget — makes it survive a reboot.

## Creating an array

`mdadm --create <name> --level=<n> --raid-devices=<count> <disks...>` builds an array. It writes RAID **superblocks** to every member disk, then starts an initial **resync**.

### What's actually in a superblock

The superblock isn't just a "this disk belongs to an array" flag. It records, per array: a UUID identifying the array itself (so a reassembled array can be verified as the *right* one, not just *an* array), the array's level and layout, and — per member disk — a **role/slot number** (which position in the array this specific disk occupies) and an **event counter** that increments on every state change the array goes through. That event counter is what lets `mdadm` tell a disk that was cleanly part of the array five seconds ago from one that's been sitting on a shelf for a week: if a disk's counter doesn't match what the other members expect, `mdadm` treats it as stale, not current, even though its role slot looks correct.

This is also why `mdadm --create` prompts for confirmation ("really create array?") whenever a target disk already carries *any* recognizable signature — a filesystem superblock, a partition table, an old RAID superblock from a previous array. The tool isn't being cautious about RAID specifically; it's refusing to silently discard whatever that signature represents.

For a mirror, the resync copies one disk to the other; for parity levels, it computes parity across the stripe from scratch. The array is usable during the resync, just slower — reads and writes both work, they just compete with the background sync I/O.

You can build an array from whole disks (`/dev/vdb`) or from partitions (`/dev/vdb1`). Whole disks are simpler; partitions let you keep some of the disk for other uses and make disk-type intent explicit.

> [!TIP]
> **Try it — build a mirror**
>
> ```sh
> sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/vdb /dev/vdc
> cat /proc/mdstat
> sudo mdadm --detail /dev/md0
> ```
>
> Answer `y` to the "continue creating array?" prompt. Expect something like:
>
> ```text
> md0 : active raid1 vdc[1] vdb[0]
>       1046528 blocks super 1.2 [2/2] [UU]
>       [===========>.........]  resync = 58% (610000/1046528) ...
>
> /dev/md0:
>            Version : 1.2
>         Raid Level : raid1
>         Array Size : 1046528 (1022.00 MiB ...)
>       Raid Devices : 2
>        Total Devices : 2
>              State : clean, resyncing
>     Active Devices : 2
> ```
>
> `[2/2] [UU]` means both members are present and `Up` — that's the role-slot bookkeeping from the superblock, rendered as a bitmap. The `resync` line shows the initial mirror copy in progress; when it finishes, `State` becomes `clean`.

## A filesystem on the array

`/dev/md0` behaves like any block device. Format **the array**, never its members — writing a filesystem directly to `/dev/vdb` would corrupt the RAID superblock sitting at the start (or end, depending on metadata version) of that disk, and every other member's event counter would then disagree with what that disk reports.

> [!TIP]
> **Try it — format and mount**
>
> ```sh
> sudo mkfs.ext4 /dev/md0
> sudo mkdir -p /mnt/raid
> sudo mount /dev/md0 /mnt/raid
> df -h /mnt/raid
> echo "mirrored data" | sudo tee /mnt/raid/hello.txt
> ```
>
> Expect something like:
>
> ```text
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/md0        988M   24K  921M   1% /mnt/raid
> ```
>
> The mirror presents ~1 GB (the size of one disk, since RAID 1 keeps a full copy on each). The file you wrote now exists on both `/dev/vdb` and `/dev/vdc`; losing either disk keeps the data.

## Making the array persistent

An array assembled with `--create` is not remembered across reboots by itself. Two things make it come back:

1. **`/etc/mdadm/mdadm.conf`** — an `ARRAY` line recording the array's UUID and name, generated from that same superblock data, so the boot process knows to assemble it (and assembles it as `/dev/md0`, not a random `/dev/md127` — without a matching `ARRAY` line, `mdadm` falls back to numbering arrays in whatever order it discovers them, which is not guaranteed stable). Generate it with `mdadm --detail --scan`.
2. **An initramfs update** — the early-boot environment has its own copy of `mdadm.conf`, baked into the initramfs image at the time it was last built. If the array holds `/` or `/boot` it *must* be assembled there; even for a data array, refreshing the initramfs keeps the two configs in sync so a later `update-initramfs` for an unrelated reason doesn't silently revert this array's config. `update-initramfs -u` on Debian/Ubuntu, `dracut -f` on RHEL-family.

Then add the filesystem to `/etc/fstab` by the **array filesystem's** UUID (`blkid /dev/md0`), exactly as in Section 015.

> [!TIP]
> **Try it — record the array**
>
> ```sh
> sudo mdadm --detail --scan
> sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
> sudo update-initramfs -u
> ```
>
> Expect something like:
>
> ```text
> ARRAY /dev/md0 metadata=1.2 name=host:0 UUID=3b8f...:c1d2...:...:...
>
> update-initramfs: Generating /boot/initrd.img-6.8.0-...
> ```
>
> The `ARRAY` line now sits in `/etc/mdadm/mdadm.conf`, and the initramfs has been rebuilt with it. After a reboot the array would assemble automatically as `/dev/md0`.

> [!WARNING]
> **Common pitfalls**
>
> - **Treating RAID as a backup.** It protects against a disk failing. It does nothing against `rm -rf`, filesystem corruption, ransomware, or a datacentre fire. You still need backups.
> - **Choosing RAID 0 for "safety".** RAID 0 has no redundancy — it *increases* failure risk, because losing any one disk loses everything. Use it only for scratch data you can recreate.
> - **Running `mkfs` on a member disk.** Format `/dev/md0`, not `/dev/vdb`. Writing to a member corrupts the array's superblock and desyncs its event counter from the other members.
> - **Skipping `mdadm.conf` / initramfs.** Without the `ARRAY` line and an initramfs refresh, the array may not assemble at boot, or comes up renamed as `/dev/md127`, breaking any `/etc/fstab` entry that names `/dev/md0`.
> - **Ignoring the resync.** A freshly created parity array is slower and less resilient until the initial resync completes. Let it finish before heavy use; watch `/proc/mdstat`.
> - **Forgetting `--zero-superblock` when reusing a disk.** A disk that was previously in an array still has a RAID superblock with a stale event counter and role slot. `sudo mdadm --zero-superblock /dev/vdX` before reusing it, or `mdadm --create` may misbehave or simply refuse.

> *A RAID superblock isn't a label — it's the array's own record of who its members are, in what role, and how recently each one was in sync. Everything `mdadm` does to detect a stale or failed disk reads from that record.*

## Reference

- `man mdadm` — `--detail --scan` for the `mdadm.conf` line format, and `--examine <device>` to read one disk's superblock directly.
- `man mdadm.conf` — the full `ARRAY` line syntax and the other directives (`MAILADDR`, `PROGRAM`) used for monitoring in the next module.
