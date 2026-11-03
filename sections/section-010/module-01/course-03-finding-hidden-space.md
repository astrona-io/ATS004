# Finding Hidden Space

Storage work is not only setting disks up, astronaut. It is also keeping them from filling up. When `df -h` shows a mount close to 100 percent, you need to find out what is using the space, even when a plain look at the directory shows nothing.

## Hidden directories that eat space

A common surprise is a directory whose name starts with a dot, such as `.trash`, `.Trash-1000` or `.cache`. A desktop environment or a program often creates one at the top of a mount. This section shows why you cannot see it, and the two commands that find it.

### Why a plain `ls` misses it

Names that begin with a dot are hidden from a plain `ls`. So `ls /mnt/data` can look empty while gigabytes sit in `/mnt/data/.trash`. It is a shelf behind a curtain in the cargo hold: the cargo is there, you just do not see it at a glance.

Two commands pull the curtain back:

- `ls -la` lists every entry, including the ones that start with a dot.
- `du` ("disk usage") adds up how much space files really take. With `-sh` it prints one total for a directory, in sizes that are easy to read. Where `df` shows how full each hold is, `du` shows how much one shelf really holds. Add `-x` to make `du` stay on one filesystem and skip anything mounted below it.

### See it in your playground

The commands below need the 2 GB disk formatted with ext4, unmounted, and the directory `/mnt/backup-black` in place. In a fresh playground the disk is raw again, so set it up first (confirm the disk name with `lsblk`):

<!-- astrona:playground:renew -->

```sh
sudo mkfs.ext4 /dev/vdb
sudo mkdir -p /mnt/backup-black
```

Now mount the disk, hide 64 MB of data in a dot-directory, and go looking for it:

```sh
sudo mount /dev/vdb /mnt/backup-black
sudo mkdir /mnt/backup-black/.trash
sudo dd if=/dev/zero of=/mnt/backup-black/.trash/junk bs=1M count=64
ls /mnt/backup-black            # looks empty
ls -la /mnt/backup-black        # .trash is visible
du -sh /mnt/backup-black/.trash
```

Expect something like:

```text
total 24
drwxr-xr-x 4 root root  4096 Aug 29 12:10 .
drwxr-xr-x 3 root root  4096 Aug 29 12:00 ..
drwx------ 2 root root 16384 Aug 29 12:05 lost+found
drwxr-xr-x 2 root root  4096 Aug 29 12:10 .trash

64M     /mnt/backup-black/.trash
```

The plain `ls` hides `.trash`. `ls -la` shows it, and `du -sh` confirms it holds the 64 MB you just wrote. On a real full disk, you get the space back by emptying such a directory (`sudo rm -rf /mnt/backup-black/.trash/*`). Check what is inside before you delete anything.

## Common pitfalls

> [!WARNING]
> - **Trusting a plain `ls` on a full disk.** Hidden dot-directories do not show up. Use `ls -la` and `du -sh` when you hunt for used space.
> - **Deleting before you look.** A hidden directory can hold data someone still needs. List its contents before you empty it.

> *A disk that looks empty to `ls` can still be full: `ls -la` shows the hidden shelves, and `du -sh` weighs them.*
