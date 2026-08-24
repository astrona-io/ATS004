# Chapter 2: Splitting the Acre: Partitioning Raw Storage

When you connect a brand-new storage drive to a Linux server, you are looking at a vast, open tract of land. You cannot simply start throwing furniture and building walls randomly across the entire terrain. Instead, you first hire a surveyor to draw boundaries, put up fences, and divide the property into distinct, registered lots: one for the main house, another for a garden, and a third for a guest cottage. 

In the storage world, those fences are **partitions**. Dividing a single physical drive into logical segments makes it look and behave like several independent drives to the operating system. Even if a disk is destined to hold only a single filesystem, we almost always draw at least one partition boundary first. This boundary establishes the starting and ending points, preventing filesystems from stepping on each other's toes and ensuring the operating system knows exactly where to look for data.

---

## The Maps at the Gate: MBR vs. GPT

To maintain these boundaries, the drive needs a map. This map is stored at the very beginning of the disk in a structure called a **partition table**. Over the decades of personal computing, two primary standards have emerged to write this map: MBR (Master Boot Record) and GPT (GUID Partition Table).

### The Legacy Sentinel: MBR
Introduced in 1983 alongside PC DOS 2.0, the **Master Boot Record (MBR)** is a venerable but heavily limited partitioning standard. The entire MBR partition table is crammed into a tiny 512-byte sector at the absolute beginning of the disk. Because space in this sector is at a premium, the designers made a trade-off that still haunts system administrators today:

- **The Four-Partition Limit**: An MBR partition table can hold only four primary partition entries. If you want five partitions, you have to turn one of those primary slots into an **extended partition**. This extended partition acts as a container, inside of which you can carve out multiple **logical partitions**. It is a clunky workaround born of 1980s constraints.
- **The 2TB Ceiling**: MBR uses 32-bit values to store sector numbers. With a standard sector size of 512 bytes, the absolute maximum disk space MBR can address is $2^{32} \times 512$ bytes, which equals exactly 2.19 Terabytes. If you plug a 4TB drive into a system and partition it with MBR, any space beyond 2.19TB is completely invisible and unusable.

### The Modern standard: GPT
The **GUID Partition Table (GPT)** is the modern standard that replaces MBR. It is part of the Unified Extensible Firmware Interface (UEFI) specification and is designed to handle modern, high-capacity enterprise storage:

- **Nearly Unlimited Slices**: By default, GPT supports up to 128 primary partitions. You do not need to worry about extended or logical partitions; every slice is a primary, first-class citizen.
- **Zettabyte-Scale Addressing**: GPT uses 64-bit logical block addressing. This allows it to address disks up to 9.4 Zettabytes (9.4 billion Terabytes), easily accommodating any storage array you will encounter in your career.
- **Built-in Redundancy**: MBR stores its partition table in a single sector. If that sector is corrupted by a stray write or a failing drive head, your entire disk is lost. GPT, by contrast, stores a primary partition table at the beginning of the disk and a backup (or secondary) copy at the very end of the disk. If the primary map is damaged, the kernel automatically restores it using the backup copy.
- **Globally Unique Identifiers**: GPT identifies every disk and partition using a Globally Unique Identifier (GUID), ensuring that no two partitions in the world share the same ID. This makes disk identification incredibly reliable, even when drives are moved between systems.

---

## The Administrator's Toolkit

To construct these boundaries, Linux provides several tools. The two most common are `fdisk` and `parted`.

### `fdisk`: The Interactive Conversationalist
For most administrative tasks on a single server, `fdisk` is the classic choice. It is a menu-driven, interactive tool. When you run `sudo fdisk /dev/vdb`, you enter a specialized command loop where you use single-character keystrokes to design your disk layout in memory before committing any changes to the physical disk.

- `m`: Prints a helpful command cheat sheet.
- `p`: Prints the partition table as it currently stands in memory.
- `g`: Wipes any existing partition map and writes a clean, empty GPT partition table.
- `o`: Wipes the disk and writes a legacy MBR partition table.
- `n`: Creates a new partition, prompting you for a partition number, starting sector, and ending size.
- `d`: Prompts you for a partition number to delete.
- `t`: Changes a partition's type (e.g., marking it as a Linux Swap space or an LVM physical volume).
- `w`: Writes the changes from memory to the physical disk headers and exits.
- `q`: Quits without saving, abandoning any changes you drafted during the session.

### `parted`: The Command-Line Surgeon
While `fdisk` is fantastic for interactive use, it is difficult to automate in bash scripts because of its conversational prompt system. For scripting, or for working with massive enterprise arrays, we turn to `parted` (Partition Manipulator). 

`parted` can execute commands directly from the command line in a single line, making it perfect for automated deployment scripts. For example, a single command can initialize a GPT label, and another can carve out a partition.

---

## Scenario: Drawing boundaries on a Raw Disk

Let's walk through a real-world scenario. Your team has attached a brand-new, raw virtual disk identified as `/dev/vdb`. Your goal is to initialize it with a modern GPT partition table and slice out a single 10GB primary partition for data storage.

### Step 1: Opening the Operating Table
First, we launch `fdisk` and point it to our target disk:

```bash
sudo fdisk /dev/vdb
```

The terminal screen changes, welcoming you to the `fdisk` interactive shell. 

### Step 2: Surveying the Current State
Before making any changes, we must print the current partition table to ensure we aren't about to overwrite active data. Type `p` and hit `Enter`:

```text
Command (m for help): p
Disk /dev/vdb: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
```

Here, we see that `/dev/vdb` is a 20GB disk with a GPT label, but no partitions are listed at the bottom of the output. It is a blank slate. 

If the disk had a legacy label, or if we wanted to make absolutely sure we were starting fresh with a GPT layout, we would type `g` and press `Enter`:

```text
Command (m for help): g
Created a new GPT disklabel (GUID: B4E8C23A-64D2-4B6A-9DFA-0F0394747A11).
```

### Step 3: Carving out the 10GB Slice
Now, we create our new partition. Type `n` and press `Enter`:

```text
Command (m for help): n
Partition number (1-128, default 1): 
```

The system asks for a partition number. GPT can handle up to 128 partitions, but since this is our first, we press `Enter` to accept the default of `1`.

```text
First sector (2048-41943006, default 2048): 
```

Next, it asks for the starting sector. By default, `fdisk` selects sector `2048`. This is an extremely important number, and we should always accept this default. Press `Enter`.

```text
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-41943006, default 41943006): 
```

Finally, it asks where the partition should end. We do not want to calculate sectors manually. Instead, we use a human-readable size notation. To make the partition exactly 10 Gigabytes, we type `+10G` and press `Enter`:

```text
Created a new partition 1 of type 'Linux filesystem' and of size 10 GiB.
```

### Step 4: Inspecting our Work
Before we write these changes to the physical disk platters, let's print the partition table one last time to verify our draft. Type `p`:

```text
Command (m for help): p
Device       Start      End  Sectors  Size Type
/dev/vdb1     2048 20973567 20971520   10G Linux filesystem
```

Everything looks perfect. We have a 10GB partition starting at sector 2048 and ending at sector 20973567.

### Step 5: Committing the Layout
To save our changes, we type `w` and press `Enter`. This is the point of no return. Up until this moment, we have only been editing a draft in our system's memory. Typing `w` instructs `fdisk` to write the new GPT partition table and partition entry to the actual disk blocks, then close:

```text
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

The system has successfully committed the layout. If we run `lsblk /dev/vdb`, we will now see our new partition child sitting proudly underneath its parent disk:

```text
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
vdb     254:16   0   20G  0 disk 
└─vdb1  254:17   0   10G  0 part 
```

---

## Under the Hood: Sector Alignment and Kernel Refusals

As a professional administrator, you should understand the mechanics of what just happened.

### The Mystery of Sector 2048
Why does `fdisk` start partitions at sector 2048 instead of sector 1? 

In older hard drives, physical sectors were exactly 512 bytes. Modern mechanical drives and solid-state drives (SSDs) use larger physical blocks—typically 4096 bytes (4KiB) or larger—to increase storage density and reliability. However, to maintain compatibility with older systems, these drives expose fake "logical" 512-byte sectors to the operating system. This is known as **512-byte Emulation (512e)**.

If you start a partition at an odd logical sector (like sector 63, which was common in older operating systems), the partition's logical blocks will not align with the drive's physical 4KiB blocks. 

When your database tries to write a single 4KiB block of data to a misaligned partition, the physical disk is forced to read two physical blocks, modify a portion of both, and write them both back. This phenomenon is known as **write amplification**, and it can slash your storage read and write performance by 30% to 50% while wearing out your SSDs prematurely.

Sector 2048 corresponds to exactly 1 Megabyte ($2048 \times 512 \text{ bytes} = 1,048,576 \text{ bytes}$). Because 1MB is perfectly divisible by 4KiB, starting your partitions at sector 2048 ensures that every filesystem block aligns perfectly with the underlying physical storage, guaranteeing optimal hardware performance.

### "Device or Resource Busy"
Occasionally, when you write a partition table to an active disk, you might see this error message:

`Re-reading the partition table failed.: Device or resource busy. The kernel still uses the old table.`

When a partition table changes, the kernel must reload its internal map of the disk. However, if any filesystem on that disk is currently mounted, or if an active process is reading from any sector on that drive, the kernel will refuse to hot-reload the map to prevent data corruption.

To resolve this without rebooting the server, you have two options:
1.  **Unmount everything**: Ensure no filesystems on the target drive are mounted, and no LVM volume groups on the disk are active.
2.  **Force a reload**: Use the `partprobe` command to ask the kernel to force-scan the drive and update its partition tracking:
    ```bash
    sudo partprobe /dev/vdb
    ```

---

## Self-Check and Verification

Before moving to the next chapter, test your understanding of partitioning:
1.  **The 2TB Boundary**: If you are setting up a new 8TB backup server, why must you avoid using `o` in `fdisk` to initialize the disk? *(Answer: The `o` key writes a legacy MBR partition table, which cannot address or use any storage space beyond 2.19 Terabytes. You must use `g` to write a GPT partition table instead.)*
2.  **Sector Alignment**: Why is it crucial to accept `fdisk`'s default starting sector of 2048? *(Answer: Starting at sector 2048 aligns the partition with physical 4KiB pages on modern SSDs and advanced format drives, preventing write amplification and maintaining high I/O performance.)*
3.  **Kernel Syncing**: You deleted a partition using `fdisk`, but running `lsblk` still shows the deleted partition. What command should you run to force the kernel to update its memory map? *(Answer: Run `sudo partprobe` to sync the kernel's partition table with the physical disk map.)*
