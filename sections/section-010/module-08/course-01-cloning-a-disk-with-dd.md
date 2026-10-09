# Cloning a Disk with dd

`dd` copies raw bytes from one place to another, one block at a time. The name is historical; think of it as "data duplicator". `dd` does not know what a partition table, a filesystem or a file is. That is exactly why it is the right tool for a whole-disk clone. It does not need to understand the source to copy it perfectly: partition table, filesystem data, every file and every byte of unused space.

In space terms, `dd` copies a cargo hold crate by crate, empty corners included. It never reads the labels on the crates.

## The command and its parts

A `dd` command is short, but every part of it matters. This section explains each option before you run one.

### The shape of the command

```text
dd if=<source> of=<destination> bs=<block size> status=progress
```

- **`if=`** (input file): what to read from. For a disk clone this is almost always a block device such as `/dev/vdb`. When you restore, it is an image file.
- **`of=`** (output file): what to write to. A block device to clone onto, or a file to copy the disk into.
- **`bs=`** (block size): how many bytes to read and write in each chunk. The default is 512 bytes. At that size, `dd` spends almost all its time on the work around each chunk instead of moving data. `bs=4M` or `bs=64M` gets close to the real speed of the disk.
- **`status=progress`**: prints a running byte count while `dd` works. Without it, `dd` is silent until it finishes. On a large disk, that looks just like a command that hangs.

### Picking a block size

Bigger is not always better. A very large block size wastes memory on the last, partial chunk at the end of a device whose size is not an exact multiple of it. For a whole-disk clone, `4M` to `64M` is the practical range.

## Cloning a whole disk

Here you clone `/dev/vdb` onto `/dev/vdc`. Both disks are the same size, and the destination ends up an exact copy: the same partition table, the same filesystems, the same files and the same UUID.

### See it in action

On a machine with two 1 GB spare disks, list the disks first, then clone one onto the other:

```sh
lsblk
sudo dd if=/dev/vdb of=/dev/vdc bs=4M status=progress
```

Expect something like:

```text
NAME MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
vda  253:0    0   15G  0 disk
vdb  253:1    0    1G  0 disk
vdc  253:2    0    1G  0 disk

1048576000 bytes (1.0 GB, 1000 MiB) copied, 4 s, 250 MB/s
250+0 records in
250+0 records out
1048576000 bytes (1.0 GB, 1000 MiB) copied, 4.19286 s, 250 MB/s
```

Always run `lsblk` first. It confirms both device names, and that `vdc` really is the disk you mean to overwrite, before `dd` runs. `status=progress` prints the running total while the copy runs. The last three lines are the summary `dd` prints when it is done.

## The warning that matters most

`dd` has no "are you sure?" question and no undo. This section explains why that makes it dangerous, and the habits that keep you safe.

### No questions, no undo

`dd` does exactly what `if=` and `of=` say, at once. A destination that already held data is gone the moment the first block is written. It is not moved to a bin, and `fsck` cannot bring it back; it is simply overwritten.

Swapping `if=` and `of=`, or picking the wrong device because you trusted your memory instead of `lsblk`, is so common that administrators gave `dd` a nickname: "disk destroyer". Every experienced administrator either has a story about it or knows someone who does.

### The habits that protect you

No option makes `dd` safe. The only real protection is a routine:

- Run `lsblk` or `blkid` **right before** the command, in the same terminal. Read the device names from that output, not from memory and not from a note you made ten minutes ago.
- Say the direction out loud, or write it in a comment, before you run it: "*from* vdb *to* vdc". `if=` is the disk you read; `of=` is the disk that is about to be overwritten.
- Always add `status=progress`. If a copy that should take five seconds is still running after fifty, something is wrong, usually a much bigger destination than you expected. You want to see that at once.

## Copying a disk to a file, and back

`of=` does not have to be a device. It can be a plain file. That turns a live disk into a portable image that you can store somewhere else and restore later, even onto different hardware.

### See it in action

Copy `/dev/vdb` into an image file, look at its size, and later write the image onto a fresh disk:

```sh
sudo dd if=/dev/vdb of=/root/vdb-backup.img bs=4M status=progress
ls -lh /root/vdb-backup.img

# ...later, onto a fresh disk...
sudo dd if=/root/vdb-backup.img of=/dev/vdc bs=4M status=progress
```

Expect something like:

```text
1048576000 bytes (1.0 GB, 1000 MiB) copied, 4 s, 250 MB/s
-rw-r--r-- 1 root root 1000M ... /root/vdb-backup.img

1048576000 bytes (1.0 GB, 1000 MiB) copied, 4 s, 250 MB/s
```

The image file is exactly the size of the source disk, whether or not that space held real data. `dd` copied every block, used and unused. That is the price of an exact copy: no compression, and no idea of "empty" or "used" space. You can send the output through a compressor yourself (`dd ... | gzip > image.img.gz`), but this module does not cover that.

## Common pitfalls

> [!WARNING]
> - **Swapping `if=` and `of=`.** The most common way to destroy the wrong disk. Read the device names from `lsblk` right before you run the command, every time.
> - **Forgetting `bs=`.** The default block size of 512 bytes makes a large clone many times slower. Set `bs=4M` or larger.
> - **Cloning onto a smaller disk.** `dd` does not compare sizes. A larger source written to a smaller destination stops when the destination is full, with no clear error, and leaves a broken filesystem behind.
> - **Running `dd` without `status=progress`.** A silent `dd` looks the same as a stuck one, so you cannot spot a wrong target until it is too late.

> *`dd` does not know what a file is, and that is the whole point. It copies a disk exactly because it never has to understand it, and it destroys a disk just as fast, for the same reason.*
