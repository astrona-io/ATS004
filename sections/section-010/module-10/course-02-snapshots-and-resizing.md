# Snapshots and Resizing

Because Btrfs keeps old data until nothing needs it, it can photograph a subvolume almost instantly. This part takes snapshots, removes subvolumes, changes the size of a mounted filesystem, and shows why `df` cannot be trusted here.

## Snapshots

A **snapshot** is a subvolume that starts as a copy of another one. This section takes a read-only photograph and a writable copy, and shows what each one is for.

### Why a snapshot is cheap

A snapshot does not copy the data. Both subvolumes point at the same crates, and only the changes made afterwards use new space. That is copy-on-write at work. In space terms, a snapshot is a photograph of the shelf plan: it costs almost nothing until the real shelves change.

### See it in your playground

The commands below need the top of the filesystem mounted, because that is where the snapshots will sit. Mount it, put a file in the subvolume, and take a read-only snapshot with `-r`:

<!-- astrona:playground:renew -->

```sh
sudo mkdir -p /mnt/vault
sudo mount -o subvolid=5 /dev/disk/by-id/virtio-s010m10-a /mnt/vault
echo "first cargo list" | sudo tee /mnt/vault/data/cargo.txt
sudo btrfs subvolume snapshot -r /mnt/vault/data /mnt/vault/data-snap
```

If you did the previous part, `/srv/vault` also shows `data`, and you may keep it mounted. Now change the original and compare it with the snapshot:

```sh
echo "second line" | sudo tee -a /mnt/vault/data/cargo.txt
cat /mnt/vault/data/cargo.txt
cat /mnt/vault/data-snap/cargo.txt
```

The original has two lines. The snapshot still has only the first, because it is a frozen photograph. A read-only snapshot refuses writes: try `echo x | sudo tee /mnt/vault/data-snap/new.txt` and the shell reports an error about a read-only filesystem.

For a snapshot you can change, leave out `-r`. This makes a writable copy that you can use to test a change safely:

```sh
sudo btrfs subvolume snapshot /mnt/vault/data /mnt/vault/data-test
sudo btrfs subvolume list /mnt/vault
```

The list now shows `data`, `data-snap` and `data-test`.

### Deleting a subvolume

A snapshot is a subvolume, so you remove it with the subvolume command, not with `rm -r`:

```sh
sudo btrfs subvolume delete /mnt/vault/data-test
```

The command reports that it deleted the subvolume. Space is returned to the pool once nothing else uses those crates.

## Resizing a mounted filesystem

A Btrfs filesystem can change size while it is mounted. This section grows it, shrinks it, and explains the argument that sets the size.

### Grow and shrink

`btrfs filesystem resize` takes the change and the mount point. A plus or minus sign means a change by that amount. `max` means all the room the device offers. The command works on the mount point, not on the device, so the filesystem must be mounted:

```sh
sudo btrfs filesystem resize -200M /mnt/vault
sudo btrfs filesystem show /mnt/vault
sudo btrfs filesystem resize max /mnt/vault
sudo btrfs filesystem show /mnt/vault
```

The `show` output lists the size of the device in the pool. After `-200M` it is 200 MB smaller than the disk, and after `max` it is the full disk again. Growing is the usual job: after you enlarge the disk under a filesystem, `resize max` makes the filesystem use the new room.

## Why `df` misleads

`df` is the tool most people reach for to ask how full a hold is. On Btrfs it gives a rough answer at best. This section says why and which tool to use.

### Space is shared and shared again

Subvolumes and snapshots share the same crates, and Btrfs sets aside space separately for data and for metadata (the cargo tags). `df` sees none of that. It prints one total and one free number, so it can show free space that data cannot actually use, or hide space a snapshot still holds.

For a true picture, use `sudo btrfs filesystem usage /mnt/vault`. It shows what is allocated to data and metadata and what is still unallocated.

## Your mission: Btrfs Subvolume and Snapshot Lab

You can now format a Btrfs filesystem, mount a subvolume persistently by UUID and take a read-only snapshot. The mission asks you to do all three on a blank disk.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-010-module-10-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-10/labs/lab-01
astrona ssh ats-004-lab-091
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-10/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-091
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-10/playground
```

## Common pitfalls

> [!WARNING]
> - A snapshot is not a backup. It lives in the same filesystem, so if the disk fails, the snapshot is gone with it.
> - Delete snapshots with `btrfs subvolume delete`. A plain `rm -r` fails on the read-only ones.
> - `btrfs filesystem resize` takes a mount point. Giving it a device name is an error.
> - Do not trust `df` on Btrfs. Use `btrfs filesystem usage`.
