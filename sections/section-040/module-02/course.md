# Permanent Swap Partitions & Priority Scheduling

Swap files are excellent for emergencies, but they have overhead. Every read and write to a swap file must travel through the filesystem driver (like ext4 or XFS) before hitting the disk.

For permanent, high-performance infrastructure, you use a dedicated swap partition. This bypasses the filesystem layer entirely. The kernel writes memory pages directly to the raw blocks of the hard drive. Think of it as a dedicated, high-speed automated storage bin built straight into the factory floor, rather than a generic filing cabinet.

## Initializing Dedicated Partitions

Creating a swap partition requires a dedicated block device. This could be a standard physical partition (`/dev/sdb1`) or an LVM Logical Volume (`/dev/mapper/vg_system-lv_swap`).

You do not format this device with a standard filesystem. You format it strictly for swap.

```bash
mkswap /dev/sdb1
```

Once formatted, you activate it manually using `swapon /dev/sdb1`.

However, manual activation does not survive a reboot. To make the swap space permanent, you must declare it in `/etc/fstab`.

You open `/etc/fstab` and append a new line. You should always use the UUID of the partition, which you find using `blkid`, rather than the `/dev` path. This ensures the system mounts the correct partition even if the drive letters change during boot.

```text
UUID=a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d   none   swap   sw   0   0
```

The mount point is `none` because swap doesn't live in the directory tree. The type is `swap`, and the default option is `sw`. The dump and pass checks at the end are `0`, as the filesystem checker does not run on raw swap space.

You verify your fstab configuration by deactivating all swap with `swapoff -a` and then reading the fstab file to activate them all with `swapon -a`.

## Tuning Priority Queues

Linux allows you to configure multiple swap devices simultaneously. You might have a small, lightning-fast swap partition on an NVMe drive, and a massive, slow 50GB swap file on a spinning disk for absolute emergencies.

By default, if you activate multiple swap spaces, the kernel balances the load across them. It will write memory pages to the slow spinning disk just as often as the fast NVMe drive. This destroys performance.

You must tune the priority queues. The kernel respects a priority scale from -1 to 32767. Higher numbers indicate higher priority. The kernel will completely fill the highest priority swap space before it writes a single byte to the lower priority spaces.

You set this priority using the `pri=` option.

For ad-hoc activation, you pass it to the command line.

```bash
swapon -p 100 /dev/nvme0n1p2
swapon -p 10 /swapfile
```

For persistent configurations, you add it directly to the options column in `/etc/fstab`.

```text
UUID=a1b2...   none   swap   sw,pri=100   0   0
/swapfile      none   swap   sw,pri=10    0   0
```

With this configuration, the kernel writes all overflow memory exclusively to the NVMe partition. It only touches the slow swap file if the NVMe partition reaches 100% capacity. This ensures your server degrades gracefully rather than crashing into an I/O bottleneck immediately.

## Self-Check and Verification

To prove you can architect persistent, prioritized swap:

1. Identify a dedicated block device or create a small LVM volume.
2. Initialize the device as swap space using `mkswap`.
3. Add an entry to `/etc/fstab` using the device's UUID, configuring it as a high-priority swap space (`pri=50`).
4. Create a secondary swap file, secure it, initialize it, and add it to `/etc/fstab` as a low-priority space (`pri=10`).
5. Run `swapoff -a` followed by `swapon -a` to apply the fstab configuration.
6. Run `swapon --show` to verify both devices are active and the priorities dictate the correct filling order.
