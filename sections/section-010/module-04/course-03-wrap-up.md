# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about keeping a filesystem healthy and making sure it always docks as the right hold: repairing it, naming it, and planning its inspections.

**From [Filesystem Corruption and the fsck Repair Model](./course-01-fsck-repair-model.md):**

- A filesystem works like a small database on disk. One write is several changes (inode, block map, directory index, free count), and a crash between them leaves the lists disagreeing.
- The superblock is the master record: block and inode counts, free counts, UUID, label, feature flags and a clean state. `mkfs` writes backup copies across the disk.
- The kernel writes each change to the journal first, then to the main tables, then marks the entry complete. After a crash, complete entries are replayed and incomplete ones are thrown away, which takes seconds.
- `sudo tune2fs -l <device>` prints the superblock; `has_journal` in the features proves there is a journal.
- Never run `fsck` on a mounted filesystem. For `/`, use rescue media or a check at boot.
- `fsck -n` only reports, `fsck -y` repairs everything, and plain `fsck` asks at each problem. Recovered pieces land in `lost+found`, named by inode number.

**From [Labels, UUIDs and Tuning Check Intervals](./course-02-labels-uuids-and-tuning.md):**

- Device names such as `/dev/vdb` follow the order the kernel finds the disks, so they can change between boots.
- The UUID is written once by `mkfs` and never changes. The label is a name you set with `tune2fs -L` (or `xfs_admin -L` on XFS), and you must keep it unique yourself.
- `blkid` shows the label and the UUID; `blkid -s UUID -o value` prints only the UUID.
- `mount UUID=<uuid> <dir>` finds the right disk whatever its device name is, and `findmnt` shows which device that was.
- An `/etc/fstab` line normally starts with `UUID=`. Check it with `sudo findmnt --verify` and `sudo mount -a` before any reboot.
- `tune2fs -c N` plans a full check after `N` mounts, and `-i` after a calendar interval. `-c 0 -i 0` turns both off.

## Your missions

You proved the skills in a graded mission, right after the part that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Filesystem Repairs, Labeling, & UUIDs](./labs/lab-01/README.md) | Labels, UUIDs and Tuning Check Intervals | repair a damaged ext4 filesystem, label it `RECOVERED_VOL` and mount it at `/mnt/recovered` by UUID from `/etc/fstab` |

## Check yourself

Try to answer each question before you open it.

<details>
<summary>Why is it dangerous to run <code>fsck</code> on a mounted filesystem?</summary>

While the filesystem is mounted, the kernel keeps parts of it in memory and writes changes back to the same spots that `fsck` reads and fixes. Each thinks it is in sole control, so writing at the same time damages the filesystem. It is a real clash between two writers, not a permission rule.

</details>

<details>
<summary>After a crash, why does a journaling filesystem usually come back in seconds?</summary>

Every change is written to the journal before it is made. On the next mount, the kernel replays the journal entries that were fully written and throws away the ones that were not. It does not have to walk every shelf the way a full `fsck` does.

</details>

<details>
<summary>Which <code>fsck</code> option checks a filesystem without changing anything, and which one repairs everything without asking?</summary>

`fsck -n` is read-only: it reports problems and changes nothing. `fsck -y` answers "yes" to every repair.

</details>

<details>
<summary>After a repair, some files seem to be missing. Where do you look first?</summary>

In `lost+found` at the top of that filesystem. `fsck` links pieces of data that lost their directory entry there, named by inode number.

</details>

<details>
<summary>Why should <code>/etc/fstab</code> use <code>UUID=</code> instead of <code>/dev/vdb</code>?</summary>

The kernel gives out device names in the order it finds the disks, so `/dev/vdb` can become `/dev/vdc` after a disk is added. The UUID lives in the superblock and never changes, so the right filesystem mounts every time.

</details>

<details>
<summary>You run <code>tune2fs -L DATA /dev/vdb</code> and it fails. <code>blkid</code> shows <code>TYPE="xfs"</code>. What do you use instead?</summary>

`xfs_admin -L DATA /dev/vdb`. `tune2fs` only handles ext2, ext3 and ext4 superblocks.

</details>

<details>
<summary>What does <code>sudo tune2fs -c 0 -i 0 /dev/vdb</code> do, and why do many servers use it?</summary>

It turns off both the mount-count check and the time-based check, so no full `fsck` is forced at boot. Servers rely on the journal and outside monitoring instead, so a reboot does not suddenly take much longer.

</details>

## Clean up the playground

When you are done, land everything cleanly so it stops using memory on your computer.

First, see what is still running:

```sh
astrona list
```

Remove the playground by its name:

```sh
astrona destroy section-010-module-04-playground
```

If the list also shows the mission, remove it too:

```sh
astrona destroy ats-004-lab-013
```

Run `astrona list` again. Neither the playground nor the mission should be in the list.

> *A filesystem you can repair, name and find again is a hold you can trust at every launch.*
