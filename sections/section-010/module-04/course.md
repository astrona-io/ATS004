# Chapter 4: The Digital Auditor: Filesystem Maintenance, Labeling, & Tuning

Filesystems are high-performance relational databases. Every time you write a line of text, compile a program, or rotate a log, the kernel is running complex transaction sequences under the hood: modifying inode tables, updating directory indices, reserving data blocks, and updating free-space maps. 

But what happens when the power suddenly cuts out in the middle of a database write? What happens when a storage controller briefly drops offline or a block of physical memory degrades? 

To keep storage reliable, a system administrator must act as a digital auditor. You must understand how to inspect filesystems for structural integrity, repair corrupted indices, configure performance tunables, and assign stable, human-readable labels so the system can boot reliably under any condition.

---

## The Library in the Windstorm: Filesystem Integrity

To grasp why filesystem maintenance is necessary, imagine your storage drive is a massive physical archives library containing millions of books (files). The library's search desk uses a central card catalog (the metadata index) that records the exact shelf and box (block coordinates) for every book.

Now, imagine a sudden power outage occurs—the digital equivalent of a brief, violent windstorm blowing through the doors. The wind knocks catalog drawers onto the floor and scatters index cards. 

If you try to operate the library right away, you will face chaos. Some cards will point to empty shelves. Some books will be lying on the floor with no matching index cards. If a customer tries to checkout a book under these conditions, they might end up writing over an existing manuscript, causing permanent damage.

To restore order, you must close the library's doors to the public, lock the entrance, and bring in a professional archive auditor. 

This auditor is the **Filesystem Consistency Check (`fsck`)** utility. 

The auditor systematically walks through every room, matching index cards to physical books. If they find an index card pointing to a non-existent box, they shred the card. If they find a stack of valuable book pages on the floor with no title page or index card, they place those pages into a specialized box at the front desk named **`lost+found`** so that historians can inspect them later. Once the audit is complete, the doors are reopened, and operations resume safely.

---

## Under the Hood: Superblocks, Journals, and Mounted Hazards

As an enterprise administrator, you must understand the underlying disk structures that `fsck` and tuning tools interact with.

### The Superblock: The Master Registry
At the beginning of every ext4 filesystem sits a critical data structure called the **Superblock**. The superblock is the filesystem's master registry. It records the total number of blocks, the number of free blocks, the total count of inodes, the filesystem state (whether it was unmounted cleanly or is "dirty"), and the unique identifier of the filesystem. Because the superblock is so critical, the formatting process writes backup copies of it at regular block intervals across the drive. If the primary superblock is corrupted, you can point tuning tools to one of these backup blocks to salvage the disk.

### The Journal: Preventing the Worst
In older filesystems (like ext2), every unexpected shutdown required a complete, time-consuming disk scan by `fsck` upon reboot. Modern filesystems (like ext4 and XFS) use a technique called **journaling** to avoid this bottleneck. 

When you write a file, the kernel first records the intended modifications in a dedicated, circular log on the disk called the journal. Once the journal write is safe, the kernel applies the changes to the actual metadata and data blocks. 

If power cuts out mid-write, the reboot process does not need to scan the entire multi-terabyte drive. The kernel simply reads the journal, replays any completed transactions that didn't make it to the main tables, rolls back incomplete ones, and marks the filesystem clean in seconds. `fsck` is now reserved for deep, structural repairs when hardware anomalies or driver bugs corrupt the tables themselves.

### The Cardinal Rule of FSCK
There is one absolute, non-negotiable rule in Linux storage administration:

**Never, under any circumstances, run `fsck` on a mounted filesystem.**

Why is this so dangerous? When a filesystem is mounted, the kernel is constantly caching reads and writes in system memory and periodically flushing them down to disk sectors. The filesystem's blocks are in a fluid, active state. 

`fsck` is designed to read and directly modify those exact same physical disk sectors, operating under the assumption that it has exclusive, frozen control of the storage. 

If you run `fsck` on an active mount, the kernel and `fsck` will enter a silent, horrific race condition, writing conflicting structures to the same sectors. A slightly misaligned block will quickly escalate into a catastrophic wipeout, destroying your filesystem beyond repair. Always unmount the disk first.

---

## The Administration Toolkit

To inspect and modify our filesystems, we use three primary tools: `fsck`, `tune2fs`, and `blkid`.

### `fsck`: The Inspector General
`fsck` is actually a wrapper script that auto-detects the filesystem type on a device and calls the appropriate system checker, such as `e2fsck` for ext4 or `fsck.xfs` for XFS.
- `sudo fsck /dev/vdb1`: Runs an interactive scan. It will stop at every anomaly it finds and ask you for permission to repair it.
- `sudo fsck -y /dev/vdb1`: Runs a non-interactive repair. It automatically answers "yes" to every repair prompt, making it suitable for boot-time rescue scripts.
- `sudo fsck -n /dev/vdb1`: Executes a read-only dry run. It reports what issues exist without changing a single byte on the physical disk.

### `tune2fs`: The Surgical Tuner
Designed exclusively for the ext2, ext3, and ext4 filesystem families, `tune2fs` allows you to adjust filesystem parameters directly in the superblock metadata without reformatting the drive.
- `sudo tune2fs -L "BACKUP_DATA" /dev/vdb1`: Sets a human-readable volume label.
- `sudo tune2fs -c 20 /dev/vdb1`: Configures the filesystem to trigger a mandatory automatic `fsck` scan after every 20 mounts.
- `sudo tune2fs -i 2m /dev/vdb1`: Configures the filesystem to trigger a mandatory scan every 2 months.
- `sudo tune2fs -l /dev/vdb1`: Reads the superblock and lists all metadata, including mount counts, filesystem state, features, block counts, and UUIDs.

### `blkid`: The Identity Finder
Every time you format a filesystem, the kernel generates a 128-bit Universally Unique Identifier (UUID). Traditional device names like `/dev/sdb1` are not stable; if you reboot a server with a new USB drive attached, the kernel might assign `/dev/sdb1` to the USB drive and rename your internal data disk to `/dev/sdc1`. 

To prevent catastrophic mounting mistakes, we use `blkid` to find the stable, unchanging UUID of a filesystem:
- `sudo blkid`: Lists all recognized block devices, showing their UUIDs, filesystem types, and volume labels.

---

## Scenario: Auditing and Re-labeling a Volume

Your database server recently experienced a kernel panic and hard crash. The database replica disk at `/dev/vdb1` was unmounted dirty. Before mounting it back into production, you need to audit its integrity, tag it with a clean production label, and find its UUID for a secure mount entry.

### Step 1: Guaranteeing Isolation
Before letting `fsck` touch the disk, we must guarantee it is unmounted. Let's run a query check:

```bash
df -h | grep vdb1
```

If it returns any active line, we instantly unmount the target path:

```bash
sudo umount /dev/vdb1
```

### Step 2: Running the Audit Sweep
Now we execute a clean-up and repair sweep on `/dev/vdb1`. We will use the `-y` flag to let `fsck` automatically resolve any orphaned inodes or block anomalies it encounters:

```bash
sudo fsck -y /dev/vdb1
```

The tool scans the filesystem in five distinct passes, checking block pointers, directory connections, and sizes:

```text
fsck from util-linux 2.37.2
e2fsck 1.46.5 (30-Dec-2021)
/dev/vdb1: recovering journal
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/vdb1: clean, 11/655360 files, 154122/2621440 blocks
```

The output shows that the journal was safely recovered and the filesystem is now clean.

### Step 3: Tagging the Volume
Next, we want to label this filesystem as `DB_REPLICA` so that other team members can easily identify its purpose without guessing:

```bash
sudo tune2fs -L "DB_REPLICA" /dev/vdb1
```

Let's read the disk's superblock to confirm our label was written successfully:

```bash
sudo tune2fs -l /dev/vdb1 | grep "volume name"
```

The superblock confirms the tag is saved:

```text
Filesystem volume name:   DB_REPLICA
```

### Step 4: Finding the Stable UUID
Now we query the block identity database to retrieve our UUID:

```bash
sudo blkid /dev/vdb1
```

The command returns the unchanging attributes of the partition:

```text
/dev/vdb1: LABEL="DB_REPLICA" UUID="e1a2f345-bc67-4d89-9ef0-123456789abc" BLOCK_SIZE="4096" TYPE="ext4"
```

### Step 5: Secure Mounting
We can now mount this drive using its volume label or its UUID, completely bypassing the unstable `/dev/vdb1` path name. Let's mount using the label:

```bash
sudo mount LABEL="DB_REPLICA" /mnt/db-data
```

Or, for absolute boot safety inside `/etc/fstab`, we use the UUID:

```bash
sudo mount UUID="e1a2f345-bc67-4d89-9ef0-123456789abc" /mnt/db-data
```

Both methods route directly to the exact same physical blocks, ensuring your data mounting is resilient to hardware rearrangement.

---

## Self-Check and Verification

Verify your grasp of filesystem maintenance and tuning before moving forward:
1.  **Safety First**: You notice that a server's root filesystem `/` is exhibiting strange read errors, but you cannot unmount it because it is active. Can you run `sudo fsck -y /` directly on the live root mount? *(Answer: No! Running `fsck` on any mounted filesystem, especially the root system, can result in total filesystem destruction. To check a root filesystem, you must reboot the system and use boot parameters to trigger a scan before mounting, or boot from a live recovery USB/ISO).*
2.  **Missing Files**: After running a deep repair with `fsck`, your disk space is freed up, but some of your recently written data files have vanished from their target folders. Where should you look on the mounted disk? *(Answer: Look inside the hidden `lost+found` directory located at the root of that partition. Files that lost their directory name entries during corruption are restored there as numbered block files).*
3.  **Tuning Failures**: You try to run `sudo tune2fs -L "FAST_STORE" /dev/vdc1` but receive a command failure. What is the likely cause? *(Answer: `tune2fs` is designed exclusively for the ext filesystem family (ext2/3/4). If `/dev/vdc1` is formatted with XFS or another filesystem type, you must use the native tools for that filesystem, such as `xfs_admin -L "FAST_STORE" /dev/vdc1`.)*
