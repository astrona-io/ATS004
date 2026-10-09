# Wrap-Up: Mission Debrief

Well done, astronaut. You have read both parts and flown the mission in this module. Before you move on, look back at what you learned, check yourself, and make sure no mission machine is still running.

## What you learned

This module was about making safe copies of storage: whole disks with `dd`, files with `tar`, and proof that a copy is good.

**From [Cloning a Disk with dd](./course-01-cloning-a-disk-with-dd.md):**

- `dd` copies raw bytes. It does not know about partitions, filesystems or files, so it makes an exact copy of everything, unused space included.
- `if=` is what you read; `of=` is what gets overwritten. `dd` asks no questions and has no undo.
- Run `lsblk` right before every `dd`, and say the direction out loud.
- `bs=4M` or larger makes the copy fast; `status=progress` shows that it is moving.
- `of=` can be a file: a disk image is exactly the size of the source disk.

**From [File-Level Backups with tar, and Verifying Them](./course-02-tar-backups-and-verifying.md):**

- `tar czf` creates, `tar tzf` lists and `tar xzf ... -C <dest>` extracts an archive.
- `-C <folder> .` stores relative paths, so the archive restores anywhere.
- `-p` keeps owners and permissions when it matters.
- `tar` suits restores onto a different disk and single-file restores; `dd` suits exact copies such as a boot disk.
- Identical `sha256sum` results, or a silent `cmp`, prove a clone matches its source.

## Your mission

You proved the skill in one graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Disk Cloning & Backup](./labs/lab-01/README.md) | File-Level Backups with tar, and Verifying Them | clone a disk byte for byte with `dd` and prove it with a checksum |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You must copy a boot disk, including its partition table and boot loader, onto an identical disk. <code>dd</code> or <code>tar</code>?</summary>

`dd`. The partition table and boot loader sit outside any filesystem, and only a raw byte copy brings them along.
</details>

<details>
<summary>2. A 1 TB disk is 5% full. How big is a <code>dd</code> image of it, and how big is a <code>tar</code> archive of its files?</summary>

The `dd` image is 1 TB, because `dd` copies every block. The `tar` archive is about the size of the real data, or less with compression.
</details>

<details>
<summary>3. Your <code>dd</code> clone finished with no error. Is that proof the copy is good?</summary>

No. It only proves the command ran. Compare the two disks with `sha256sum` (the same checksum on both) or `cmp` (no output when they match).
</details>

<details>
<summary>4. Which detail of a <code>dd</code> command can destroy the wrong disk, and how do you protect yourself?</summary>

The direction: `if=` is read, `of=` is overwritten. Run `lsblk` right before the command, read the names from its output, and say "from ... to ..." before you press Enter.
</details>

## Clean up

This module has no playground. If a mission machine is still running, remove it.

First, see what is still running:

```sh
astrona list
```

If the list shows the mission, remove it by its name:

```sh
astrona destroy ats-004-lab-018
```

Run `astrona list` again. The mission should no longer be in the list.

> *`dd` copies the hold, `tar` packs the cargo, and a checksum proves the copy is real.*
