# When df and du Disagree

Sometimes `df` shows a nearly full disk while `du` finds only half of that. This part walks through the usual reasons and shows how to find the missing space. It matters because a full filesystem stops databases, logs and logins, and the quick `du` answer is not always the true one.

## A deleted file that is still open

Remember that `rm` removes only a name. If a process still holds the file open, the kernel keeps the blocks until that crew member lets go. The file has no name, so `du` cannot see it. The command `lsof +L1` lists open files whose link count is below one, which means files with no name left.

<!-- astrona:playground:renew -->

### See it in your playground

Create a 100 MiB file, hold it open from a background process, and delete its name:

```sh
sudo dd if=/dev/zero of=/opt/held.bin bs=1M count=100 status=none
sudo sh -c 'tail -f /opt/held.bin >/dev/null 2>&1 &'
sudo rm /opt/held.bin
```

Compare what the two commands say about the root filesystem. First `df`, then `du`:

```sh
df -h /
sudo du -hx -d 1 /opt | sort -hr
```

The `df` line still counts the 100 MiB as used. The `du` total for `/opt` does not include it, because the name is gone. Now ask `lsof` for files with no name:

```sh
sudo lsof +L1
```

The list shows a `tail` process and a deleted `/opt/held.bin`. The process is the crew member holding the crate. To give the space back, end that process:

```sh
sudo pkill tail
df -h /
```

After the process exits, the kernel frees the blocks and `df` drops by about 100 MiB. For a long-running service you would restart the service instead of killing a process by name.

## Other reasons for a gap

A deleted open file is the most common cause, but not the only one. These also make `df` and `du` differ:

- **Reserved blocks.** An ext4 filesystem keeps a share of its blocks (5 percent by default) for the `root` user. `df` counts them as used for ordinary users, and `du` never sees them. The command `sudo tune2fs -l <device>` prints the reserved block count.
- **Metadata.** The journal and the inode tables take space that belongs to no file.
- **A mount point that hides files.** If you mount a disk on a directory that already holds files, those files stay on the disk below the mount. They fill the lower filesystem, and `du` sees only the new mount on top of them.
- **Hard links.** Two names for one inode use the blocks once. `du` counts the blocks once, even when it walks both names.

### See it in your playground

Check the reserved blocks of the second filesystem mounted at `/data`:

```sh
sudo tune2fs -l "$(findmnt -no SOURCE /data)" | grep -i 'block count'
```

The output lists the total `Block count` and the `Reserved block count`. The reserved number is the share that ordinary users cannot use.

To find files that a mount hides, bind-mount the root filesystem to a second place. Then look below `/data`:

```sh
sudo mkdir -p /mnt/rootview
sudo mount --bind / /mnt/rootview
ls -la /mnt/rootview/data
sudo umount /mnt/rootview
```

A bind mount of `/` does not carry the mounts that sit on top of it. So `ls` shows what the root filesystem itself holds under `/data`. If it is empty, nothing is hidden there.

## Common pitfalls

> [!WARNING]
> - **Deleting a big log and seeing no change in `df`.** The service that wrote it still holds it open. Run `lsof +L1` and restart that service.
> - **Killing a process only to free space.** Restarting the owning service is safer than `kill` on a name you guessed.
> - **Mounting a disk over a non-empty directory.** The old files are hidden, not gone, and they still use space.
> - **Forgetting that `/mnt/rootview` stays mounted.** Always run `umount` after the bind mount check.
