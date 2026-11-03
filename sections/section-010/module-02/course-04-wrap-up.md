# Wrap-Up: Mission Debrief

Well flown, astronaut. You have split a raw cargo hold into rooms, started them in the right place, and made the ship's core see the new deck plan. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the partition table: the deck plan that splits a raw disk into partitions.

**From [Partition Tables: MBR vs GPT](./course-01-partition-tables-mbr-vs-gpt.md):**

- A partition is a recorded region of a disk with a start sector, an end sector and a number (`vdb1`, `vdb2`).
- MBR keeps the whole table in sector 0: boot code, four 16-byte entries and the `0x55AA` signature. That gives four primary partitions and a limit of about 2.2 TB.
- MBR has only one copy of the table. If that sector is damaged, the layout of the whole disk is lost.
- GPT keeps a protective MBR in sector 0, a primary table from LBA 1 and a backup table at the end of the disk, each checked with a CRC32.
- GPT gives 128 partition entries by default, 64-bit sector numbers and a GUID for every partition and disk. Use GPT for any modern disk.

**From [Write an Aligned GPT Partition](./course-02-write-an-aligned-gpt-partition.md):**

- `fdisk` builds a draft in memory: `g` for a GPT label, `n` for a new partition, `p` to review, `w` to write, `q` to quit without saving.
- `parted -s` acts on each command at once, which makes it good for scripts: `sudo parted -s /dev/vdb mklabel gpt`.
- The `ext4` word in `parted mkpart` is only a type hint. It does not build a filesystem.
- Partitions start at sector 2048 (1 MiB) so that 4 KiB filesystem blocks line up with 4 KiB physical blocks. A misaligned partition causes write amplification.
- `parted /dev/vdb align-check optimal 1` and `fdisk -l` prove the alignment.

**From [When the Kernel Keeps the Old Table](./course-03-when-the-kernel-keeps-the-old-table.md):**

- The kernel keeps its own in-memory copy of the partition table, and `lsblk`, `mount` and LVM read that copy.
- The `BLKRRPART` request asks the kernel to read the table again. The kernel refuses while a partition on the disk is mounted or used by LVM.
- "The kernel still uses the old table" means the disk is already right; only the kernel's copy is old.
- Unmount what uses the disk, or run `sudo partprobe /dev/vdb`. No reboot is needed.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Partitioning Raw Storage: GPT/MBR](./labs/lab-01/README.md) | Write an Aligned GPT Partition | write a GPT label and a partition that starts at sector 2048 |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why can an MBR disk not use the space past about 2.2 TB?</summary>

Each MBR entry stores its start and length as 32-bit sector counts. 2^32 sectors of 512 bytes is about 2.2 TB, so MBR has no number for any sector past that point.
</details>

<details>
<summary>2. The primary GPT header is damaged. Is the disk's layout lost?</summary>

No. GPT keeps a backup copy of the table at the end of the disk, and both copies carry a CRC32 checksum. Tools that understand GPT notice the failed check, fall back to the backup, and can rebuild the primary from it.
</details>

<details>
<summary>3. An old MBR-only tool says a GPT disk has one partition of type <code>0xEE</code> covering the whole disk. What is it seeing?</summary>

The protective MBR in sector 0. It exists so that old tools see the disk as in use and leave it alone, instead of calling it blank.
</details>

<details>
<summary>4. You pressed <code>q</code> at the end of an <code>fdisk</code> session. What happened to the disk?</summary>

Nothing. `fdisk` keeps the draft in memory, and `q` throws it away. Only `w` writes the table to the disk.
</details>

<details>
<summary>5. Why do the tools start the first partition at sector 2048?</summary>

Sector 2048 is 1 MiB in and a multiple of 8, so every 4 KiB filesystem block lines up with one 4 KiB physical block. A start that is not a multiple of 8 makes each block cross two physical blocks, which forces read-modify-write cycles (write amplification).
</details>

<details>
<summary>6. <code>fdisk</code> says "The kernel still uses the old table." Is the new table on the disk?</summary>

Yes. The bytes on the disk are already correct. The kernel refused to re-read the table because a partition on the disk is in use. Unmount it (and switch off any LVM volume group on it), or run `sudo partprobe <disk>`.
</details>

## Clean up the playground

Your playground is a whole virtual machine running on your computer. When you are done with this module, remove it, and any mission that is still running.

First, see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its **name**, not its folder path:

```sh
astrona destroy section-010-module-02-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-011
```

Then check again:

```sh
astrona list
```

The playground and the mission should no longer be listed. You can start the playground again at any time with the `astrona run` command from the module's landing page. It always starts clean, so nothing you changed carries over.

> *Write the deck plan with GPT, start the first room at sector 2048, and make sure the ship's core reads the plan you wrote.*
