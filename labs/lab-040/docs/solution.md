# Solution

## Step 1: Confirm the current state — no swap active

```bash
free -h
swapon --show
```

`free -h` should show `0B` in the `Swap` row, and `swapon --show` should print nothing at all — both confirm the starting state described in the scenario before you change anything.

## Step 2: Create a 2G swap file

```bash
sudo fallocate -l 2G /swapfile
```

`fallocate -l 2G` asks the filesystem to reserve a contiguous 2 gibibyte extent for `/swapfile` without physically zeroing it, which is fast. If the filesystem underlying `/` doesn't support `fallocate` for this purpose (some older or copy-on-write setups reject it with `fallocate failed: Operation not supported`), fall back to:

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
```

`bs=1M count=2048` writes exactly 2048 mebibytes (2 GiB) of zero bytes, guaranteeing a fully, physically allocated file regardless of filesystem quirks — slower, but universally reliable.

## Step 3: Secure the file's permissions

Check `man 8 swapon` — the description explicitly documents that a swap file with group/world-readable permissions is refused; that's the authoritative source for why `chmod 600` is mandatory here, not just good practice.

```bash
sudo chmod 600 /swapfile
sudo chown root:root /swapfile
```

`600` means only root can read or write the file at all. This is not optional — `mkswap`/`swapon` on a swap file with looser permissions will either warn loudly or, on some kernel/util-linux combinations, refuse outright, precisely because of the sensitive-memory-exposure risk described above.

## Step 4: Format the file as swap

```bash
sudo mkswap /swapfile
```

This writes the swap signature and a UUID into `/swapfile`, marking it as valid swap space. Note this must happen *after* permissions are locked down and the file is fully allocated — running `mkswap` on a sparse or wrongly-permissioned file can produce a broken or insecure swap area.

## Step 5: Activate the swap file

```bash
sudo swapon /swapfile
```

Verify immediately:

```bash
swapon --show
free -h
```

`swapon --show` should now list `/swapfile` with type `file`, size `2G`, and (until Step 9) the default priority. `free -h`'s `Swap` row should now show `2.0Gi` total.

## Step 6: Persist the swap file in /etc/fstab

Check `man 5 fstab` — the general field-format section documents that swap entries use `none` for the mountpoint field and `swap` for the type field, alongside the same six-column layout as any other filesystem entry.

Edit `/etc/fstab` and add:

```
/swapfile  none  swap  sw  0  0
```

The four data fields after the file mean: no mountpoint (`none`, since swap isn't mounted into the directory tree), filesystem type `swap`, mount option `sw` (shorthand meaning read-write swap), and both dump/fsck fields set to `0` since neither applies to swap. Without this line, the swap file would disappear on the next reboot even though it's active right now.

Test the fstab entry without rebooting:

```bash
sudo swapoff /swapfile
sudo swapon -a
swapon --show
```

`swapon -a` activates everything listed in `/etc/fstab` with a `swap` type — if `/swapfile` reappears in `swapon --show` after this, the fstab syntax is correct.

## Step 7: Identify and prepare the swap partition

```bash
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```

Look for a partition (`TYPE` = `part`) with no `FSTYPE` and no `MOUNTPOINT` — that's the freed-up disk, not something already in use. **Don't assume a specific device letter** — on some runtimes extra disks don't attach in a fixed, predictable order relative to the VM's own root disk, so this partition could show up under any `/dev/vdX`. Capture it into a variable:

```bash
SWAPPART=$(lsblk -rno NAME,FSTYPE,TYPE | awk '$3=="part" && $2==""{print "/dev/"$1; exit}')
echo "$SWAPPART"
```

This is the same "verify before you touch it" discipline as any block-device operation — a wrong guess here could mean formatting the VM's own boot partition as swap.

```bash
sudo mkswap "$SWAPPART"
```

Unlike a file, a partition needs no `fallocate`/`dd`/`chmod` dance — its size is fixed by the partition table, and its permissions are governed by the block device node, not filesystem permission bits, so `mkswap` is the only preparation step required.

## Step 8: Activate the swap partition

```bash
sudo swapon "$SWAPPART"
swapon --show
free -h
```

At this point both `/swapfile` and `$SWAPPART` are simultaneously active as swap, each with the kernel's default priority (`-2` and below, auto-assigned in the order activated, unless overridden).

## Step 9: Set relative priorities — partition preferred, file as fallback

Check `man 8 swapon` — the `-p`/`--priority` option section documents the numeric range and confirms higher values are preferred first, with equal-priority areas used round-robin.

Deactivate both to reset, then reactivate with explicit priorities:

```bash
sudo swapoff /swapfile "$SWAPPART"
sudo swapon -p 10 "$SWAPPART"
sudo swapon -p 5 /swapfile
```

`-p <N>` sets an explicit priority; higher numbers are preferred first. Here the partition (`pri=10`) will absorb swap activity before the kernel ever touches the file (`pri=5`), matching "partition as primary, swapfile as fallback."

## Step 10: Make the priorities persistent

Update `/etc/fstab` so both entries carry their priority across reboots:

```
/swapfile   none  swap  sw,pri=5    0  0
UUID=<uuid-of-swap-partition>  none  swap  sw,pri=10   0  0
```

Get the partition's UUID with:

```bash
sudo blkid "$SWAPPART"
```

Using `UUID=` instead of a raw `/dev/vdX` path in `/etc/fstab` protects against device-naming drift (a very real risk if disks are added/removed and Linux renumbers `/dev/vdX` names on a subsequent boot — exactly the instability this whole lab has been navigating around).

## Verification

```bash
swapon --show
```

Expected:

```
NAME          TYPE      SIZE USED PRIO
<swap-part>   partition   2G   0B   10
/swapfile     file        2G   0B    5
```

```bash
free -h
```

Expected: `Swap:` row shows total combined size (`4.0Gi`) across both areas.

```bash
sudo swapon -a && swapon --show   # confirms fstab entries reactivate correctly after a swapoff -a
```

## Command Summary

```bash
free -h
swapon --show
sudo fallocate -l 2G /swapfile          # or: sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
sudo chmod 600 /swapfile
sudo chown root:root /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
# add to /etc/fstab: /swapfile none swap sw 0 0
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
SWAPPART=$(lsblk -rno NAME,FSTYPE,TYPE | awk '$3=="part" && $2==""{print "/dev/"$1; exit}')
sudo mkswap "$SWAPPART"
sudo swapon "$SWAPPART"
sudo swapoff /swapfile "$SWAPPART"
sudo swapon -p 10 "$SWAPPART"
sudo swapon -p 5 /swapfile
sudo blkid "$SWAPPART"
# add to /etc/fstab: UUID=<uuid> none swap sw,pri=10 0 0
#                    /swapfile   none swap sw,pri=5  0 0
swapon --show
free -h
```
