# Software RAID Fundamentals

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-030/module-03/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-03/playground
> astrona destroy section-030-module-03-playground
> ```

RAID (Redundant Array of Independent Disks) combines several disks into one block device that is faster, or fault-tolerant, or both — depending on the layout you choose. Linux does this in software with the kernel's `md` (multiple devices) driver, managed by the `mdadm` command. The result, `/dev/md0`, is used exactly like any other disk: partition it, put a filesystem on it, mount it.

This module covers the common RAID levels and what each trades away, creating an array with `mdadm`, putting a filesystem on it, and the configuration step that makes the array reassemble itself at boot.

## Learning objectives

After this module you can:

- Describe RAID 0, 1, 5, and 10 in terms of capacity, redundancy, and minimum disks.
- Create an array with `mdadm --create` and read its state from `/proc/mdstat` and `mdadm --detail`.
- Put a filesystem on the array device and mount it.
- Persist an array with `/etc/mdadm/mdadm.conf` and an initramfs update, and explain why both are needed.

## Before you start

You should know how to create and mount a filesystem (`mkfs.ext4`, `mount`) and identify disks with `lsblk`.

The linked playground gives you an Ubuntu server VM with `mdadm` installed and **four raw 1 GB spare disks** (commonly `/dev/vdb`–`/dev/vde`), wiped on every boot. Run the command blocks below in that VM after `astrona ssh section-030-module-03-playground`.

## RAID levels

Each level is a different bargain between usable space, how many disk failures it survives, and how many disks it needs.

| Level | Layout | Min disks | Usable capacity | Survives | Notes |
| --- | --- | --- | --- | --- | --- |
| **0** | striping | 2 | 100% | **nothing** | Fast. One disk dies, all data is gone. Not redundancy — the opposite. |
| **1** | mirroring | 2 | 50% (size of one disk) | 1 disk (any) | Simple, robust. Reads can be faster; writes go to every mirror. |
| **5** | striping + one parity block | 3 | (N−1) disks | 1 disk (any) | Good capacity/safety balance. Rebuilds are slow and stress the survivors. |
| **10** | mirrored pairs, then striped | 4 | 50% | 1 disk per mirror pair | Fast and redundant; costs half the raw capacity. |

"Survives 1 disk" means the array keeps serving data in a **degraded** state until you replace the failed disk and it rebuilds. RAID is not a backup — it protects against a disk dying, not against deletion, corruption, or a fire.

> [!TIP]
> **Try it — the empty state**
>
> ```sh
> cat /proc/mdstat
> lsblk -dn -o NAME,SIZE
> ```
>
> Expect something like:
>
> ```text
> Personalities : [raid1] [raid6] [raid5] [raid10]
> unused devices: <none>
>
> vda   15G
> vdb    1G
> vdc    1G
> vdd    1G
> vde    1G
> ```
>
> `/proc/mdstat` lists the RAID levels the kernel can do and shows no arrays yet. The four 1 GB disks are the raw material.

## Creating an array

`mdadm --create <name> --level=<n> --raid-devices=<count> <disks...>` builds an array. It writes RAID **superblocks** (metadata identifying the array and each disk's role) to every member, then starts an initial **resync** — for a mirror, copying one disk to the other; for parity levels, computing parity across the stripe. The array is usable during the resync, just slower.

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
> `[2/2] [UU]` means both members are present and `Up`. The `resync` line shows the initial mirror copy in progress; when it finishes, `State` becomes `clean`.

## A filesystem on the array

`/dev/md0` behaves like any block device. Format **the array**, never its members — writing a filesystem directly to `/dev/vdb` would corrupt the RAID superblock.

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

1. **`/etc/mdadm/mdadm.conf`** — an `ARRAY` line recording the array's UUID and name so the boot process knows to assemble it (and assembles it as `/dev/md0`, not a random `/dev/md127`). Generate it with `mdadm --detail --scan`.
2. **An initramfs update** — the early-boot environment has its own copy of `mdadm.conf`. If the array holds `/` or `/boot` it *must* be assembled there; even for a data array, refreshing the initramfs keeps the two configs in sync. `update-initramfs -u` on Debian/Ubuntu, `dracut -f` on RHEL-family.

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
> - **Running `mkfs` on a member disk.** Format `/dev/md0`, not `/dev/vdb`. Writing to a member corrupts the array metadata.
> - **Skipping `mdadm.conf` / initramfs.** Without the `ARRAY` line and an initramfs refresh, the array may not assemble at boot, or comes up renamed as `/dev/md127`, breaking any `/etc/fstab` entry that names `/dev/md0`.
> - **Ignoring the resync.** A freshly created parity array is slower and less resilient until the initial resync completes. Let it finish before heavy use; watch `/proc/mdstat`.
> - **Forgetting `--zero-superblock` when reusing a disk.** A disk that was previously in an array still has a RAID superblock. `sudo mdadm --zero-superblock /dev/vdX` before reusing it, or `mdadm --create` may misbehave.
