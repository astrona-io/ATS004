# Wrap-Up: Mission Debrief

Well done, astronaut. You have read both parts and flown the mission in this module. Before you move on, look back at what you learned, check yourself, and make sure no mission machine is still running.

## What you learned

This module was about FAT32, the filesystem on almost every piece of removable media, and the quirks that come from its missing owner data.

**From [What FAT32 Is & Creating One](./course-01-what-fat32-is-and-creating-one.md):**

- FAT32 keeps one flat table of files and blocks. It has no inodes, no journal and no owner, group or permission bits.
- That simple design is why Windows, macOS and Linux can all read and write it with no extra drivers.
- FAT32 is the format on the disk; `vfat` is the Linux driver and the type name in `mount`, `blkid` and `/etc/fstab`.
- `mkfs.vfat -F 32 -n <LABEL>` creates FAT32 with a label. Without `-F 32`, a small disk may get FAT16.
- `fatlabel <device>` reads the label, and `fatlabel <device> <NAME>` changes it.

**From [Mounting FAT32 & Its Unix-less Quirks](./course-02-mounting-fat32-quirks.md):**

- The kernel's `vfat` driver reports ownership from mount options, because the disk stores none.
- `uid=`, `gid=` and `umask=` set the owner, group and removed permission bits for every file at once.
- With no options, every file looks owned by `root` and normal users cannot write.
- `chmod` and `chown` do not last on FAT32.
- One file can be at most just under 4 GiB, whatever the free space. exFAT removes that limit.

## Your mission

You proved the skill in one graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [FAT32 Removable Media](./labs/lab-01/README.md) | Mounting FAT32 & Its Unix-less Quirks | format a labelled FAT32 disk and mount it so a normal user can write to it |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You run <code>mkfs.vfat -n USBDATA</code> on a small disk. Why might the task still fail?</summary>

Without `-F 32`, `mkfs.vfat` may choose FAT16 on a small disk. FAT16 is a different layout. Pass `-F 32` whenever the task asks for FAT32.
</details>

<details>
<summary>2. You mounted a FAT32 disk with no options, and <code>touch</code> as a normal user says "Permission denied". What is wrong?</summary>

Nothing on the disk blocks you. The kernel reports every file as owned by `root`, because FAT32 stores no owner and no `uid=` was given. Mount it again with `uid=$(id -u),gid=$(id -g)`.
</details>

<details>
<summary>3. You run <code>chown</code> on a file on a FAT32 disk. Does the new owner stay after the next mount?</summary>

No. FAT32 has no owner field to change. Ownership comes only from the mount options, for the whole filesystem.
</details>

<details>
<summary>4. A 6 GB video will not copy to a nearly empty FAT32 drive. Why?</summary>

FAT32 stores each file's size in a 32-bit field, so one file can be at most just under 4 GiB. The format stops the copy, not the free space. exFAT is the format that removes this limit.
</details>

## Clean up

This module has no playground. If a mission machine is still running, remove it.

First, see what is still running:

```sh
astrona list
```

If the list shows the mission, remove it by its name:

```sh
astrona destroy ats-004-lab-017
```

Run `astrona list` again. The mission should no longer be in the list.

> *FAT32 is the galaxy's shared shelf list: every ship can read it, and nobody's name is on the crates.*
