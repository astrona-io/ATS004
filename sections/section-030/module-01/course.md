# Chapter 6: Liquid Storage: LVM Volume Groups and Logical Volumes

Traditional partitioning has a severe flaw: it is completely static. When you partition a hard drive, you carve its boundaries into physical blocks. If you allocate 20 Gigabytes to your database directory and it fills up, you cannot easily expand it—even if the neighboring partition has 100 Gigabytes of completely empty, unused space. To change static partition sizes, you are typically forced to unmount the filesystem, take your applications offline, delete partition markers, redraw boundaries (hoping you don't miscalculate a sector count), and resize the underlying filesystem tables. In enterprise environments, this kind of downtime is unacceptable.

To free ourselves from the constraints of static physical geometry, Linux uses **Logical Volume Manager (LVM)**. LVM introduces a powerful abstraction layer between your physical storage hardware and your filesystems. With LVM, storage is no longer a rigid concrete slab; it behaves like a liquid, allowing you to pool physical disks, expand or shrink volumes on the fly, and even migrate active data across physical drives while your applications are reading and writing to them in production.

---

## The Sliding Walls: The Three LVM Layers

To understand LVM, imagine you manage a massive commercial warehouse. 

Traditional partitioning is like pouring thick concrete walls inside the warehouse to divide the space into permanent storage rooms. Once the concrete cures, changing a room's size requires brings in jackhammers and wrecking crews—an incredibly disruptive, messy process.

LVM is like installing modular, sliding office cubicle walls instead. This modular system uses three distinct layers:

1.  **Physical Volumes (PVs) - Marking the Land**: First, you purchase raw land or adjacent properties (physical hard drives or partitions, such as `/dev/vdb` or `/dev/sdc1`). You hire a crew to grade the land and mark it as safe, LVM-compliant terrain. This process writes LVM metadata headers to the start of the drive. The disk is now a **Physical Volume**.
2.  **Volume Groups (VGs) - The Shared Pool**: Next, you merge all your graded properties into a single massive, unified real estate pool. This is your **Volume Group**. If you pool three 10GB Physical Volumes, your Volume Group becomes a single 30GB virtual disk. You don't care which physical disk a particular block lives on anymore; you only care about the total pool of square footage.
3.  **Logical Volumes (LVs) - The Custom Offices**: Finally, you draw lines on your pool space to construct custom offices of any size. These are **Logical Volumes**. This is where you actually format filesystems (like ext4 or XFS) and mount them to your file tree. If an office needs to grow from 5GB to 15GB, you don't break concrete. You simply slide the cubicle walls out, instantly drawing more space from the Volume Group's free pool—even while employees are sitting at their desks working.

---

## Under the Hood: The Physical Extent Currency

The secret to LVM's fluid flexibility lies in its internal currency: the **Physical Extent (PE)**.

When you initialize a Physical Volume and add it to a Volume Group, LVM chops the physical space into small, identical, bite-sized blocks called Physical Extents. By default, each PE is exactly **4 Megabytes** in size (though you can customize this when creating the pool). 

A Volume Group is not tracked as a raw byte range. Instead, the kernel tracks it simply as a big "bag of PEs." 

When you create a Logical Volume, you are not carving out sectors. Instead, you are asking LVM to hand you a specific number of extents. For example, if you request a 40MB Logical Volume, LVM reaches into the Volume Group's pool, grabs 10 extents, and chains them together. 

Because Logical Volumes are tracked as logical chains of PEs rather than continuous physical blocks on a disk platter:
- **Scattered Allocation**: The PEs assigned to a Logical Volume do not need to be adjacent to each other. LVM can assign 5 extents from physical disk `vdb` and 5 extents from physical disk `vdc` to build a single, seamless 40MB Logical Volume.
- **On-the-Fly Expansion**: To expand a volume, LVM simply grabs more PEs from the Volume Group's free bag and links them to the end of the Logical Volume's chain.
- **Active Data Migration**: If a physical drive starts showing signs of hardware failure, you can run the **`pvmove`** command. The kernel's device-mapper driver will mirror the data block-by-block, copying the PEs residing on the failing drive over to healthy free space on another drive in the same Volume Group. This copy happens live: active application read and write requests are seamlessly redirected to the destination sectors mid-execution, resulting in zero downtime.

---

## The Administrator's LVM Command Table

To manage this layered storage architecture, LVM provides commands categorized by the layer they target:

| Layer | Create & Expand | Quick Status | Detailed Configuration |
| :--- | :--- | :--- | :--- |
| **Physical Volume (PV)** | `pvcreate` / `pvresize` | `pvs` | `pvdisplay` |
| **Volume Group (VG)** | `vgcreate` / `vgextend` / `vgreduce` | `vgs` | `vgdisplay` |
| **Logical Volume (LV)** | `lvcreate` / `lvextend` / `lvreduce` | `lvs` | `lvdisplay` |

- `sudo pvcreate /dev/vdb`: Formats `/dev/vdb` with LVM metadata headers, turning it into an active Physical Volume.
- `sudo vgcreate storage_pool /dev/vdb /dev/vdc`: Combines both physical disks into a single Volume Group pool named `storage_pool`.
- `sudo lvcreate -L 5G -n app_data storage_pool`: Creates a 5GB Logical Volume named `app_data` inside the `storage_pool` VG.
- `sudo pvmove /dev/vdb`: Migrates all active extents off `/dev/vdb` and onto other available physical volumes inside the same volume group.
- `sudo vgreduce storage_pool /dev/vdb`: Evicts `/dev/vdb` from the `storage_pool` volume group.

---

## Scenario: Replacing a Failing Drive and Provisioning New Space

A S.M.A.R.T. monitoring daemon reports that physical disk `/dev/vdb` is beginning to experience hardware read-write sector failures. `/dev/vdb` is currently active inside our system's primary Volume Group, named `vol1`. 

Your goals are:
1.  Use `pvmove` to safely migrate all active data off `/dev/vdb` while the server remains online.
2.  Reduce the Volume Group `vol1` to safely disconnect and evict `/dev/vdb`.
3.  Reuse `/dev/vdb` (assuming a clean wipe for research/lab isolation) to initialize a brand-new, independent Volume Group named `vol2`.
4.  Carve a 50MB Logical Volume named `p1` out of `vol2`, and format it with an ext4 filesystem.

---

### Step 1: Locating and Evicting the Target Disk

First, let's run a quick LVM scan to inspect our physical disk usage and ensure we have enough free extents in our volume group to accommodate the migration:

```bash
sudo pvs -o+pv_used
```

The output shows our active physical volumes and how much space is currently occupied on each:

```text
  PV         VG   Fmt  Attr PSize   PFree   Used   
  /dev/vda2  vol1 lvm2 a--  <19.00g   4.00g  15.00g
  /dev/vdb   vol1 lvm2 a--   10.00g   6.00g   4.00g
```

We see that `/dev/vdb` is currently holding 4.00G of active database extents, while our healthy disk `/dev/vda2` has 4.00G of free space available. We are cleared to migrate.

We execute the live data migration:

```bash
sudo pvmove /dev/vdb
```

Under the hood, LVM begins reading physical extents from `/dev/vdb` and writing them to the free spaces on `/dev/vda2`. The terminal displays a progress indicator:

```text
  /dev/vdb: Moved: 1.25%
  /dev/vdb: Moved: 52.41%
  /dev/vdb: Moved: 100.0%
```

Once complete, all our database files are residing on `/dev/vda2`. `/dev/vdb` now holds zero active extents. We can safely remove it from the volume group pool:

```bash
sudo vgreduce vol1 /dev/vdb
```

The system confirms the reduction:

```text
  Removed "/dev/vdb" from volume group "vol1"
```

---

### Step 2: Creating the New Storage Pool (`vol2`)

Now, we want to repurpose `/dev/vdb` to build an independent storage pool named `vol2`. We run `vgcreate` to initialize `/dev/vdb` (it is already formatted as a PV, so LVM will automatically adapt it) and create the pool:

```bash
sudo vgcreate vol2 /dev/vdb
```

The output confirms the group's creation:

```text
  Volume group "vol2" successfully created
```

---

### Step 3: Carving and Formatting the Logical Volume (`p1`)

With our new pool online, we carve out a 50 Megabyte Logical Volume named `p1`. We use the `-L` option to specify the exact size, the `-n` option to assign the name, and point it to our parent pool:

```bash
sudo lvcreate -L 50M -n p1 vol2
```

LVM allocates the required extents and prints the success message:

```text
  Logical volume "p1" created.
```

To format this volume, we must find its device mapper node. In Linux, LVM exposes logical volumes through two interchangeable virtual device paths:
1.  The standard mapper path: `/dev/mapper/<VG>-<LV>` (e.g., `/dev/mapper/vol2-p1`)
2.  The symbolic link directory path: `/dev/<VG>/<LV>` (e.g., `/dev/vol2/p1`)

We use the symbolic link directory path to write an ext4 filesystem database to our new logical volume:

```bash
sudo mkfs.ext4 /dev/vol2/p1
```

Our new volume is fully formatted, isolated, and ready to be mounted into our root tree.

---

## Common Pitfalls

- **The Missing Soup Expansion (Vesey's Law of LVM)**: A classic beginner mistake is extending a Logical Volume but forgetting to resize the filesystem nested inside it. If you run `sudo lvextend -L +10G /dev/vol2/p1`, LVM will successfully assign 10GB of physical extents to the volume. However, running `df -h` will still show the original 50MB size! 
  
  Expanding the physical container does not expand the database tables inside. To fix this, you must run a filesystem-specific expansion utility:
  - For ext4 filesystems: Run `sudo resize2fs /dev/vol2/p1`
  - For XFS filesystems: Run `sudo xfs_growfs /mnt/mountpoint`
  
  Alternatively, you can pass the `-r` (or `--resizefs`) flag directly during the `lvextend` command (e.g., `lvextend -r -L +10G /dev/vol2/p1`) to ask LVM to automatically resize the underlying filesystem tables for you.

- **Premature Reduction**: If you try to run `vgreduce` to remove a physical disk before running `pvmove`, LVM will block the command or cause severe database corruption. Always ensure the physical volume has zero active extents before evicting it from the pool.

---

## Self-Check and Verification

Confirm your understanding of LVM operations before moving to the next chapter:
1.  **Extent Matching**: If your Volume Group has a default Physical Extent (PE) size of 4MB, and you request a Logical Volume of 15MB, how much space will LVM actually allocate? *(Answer: LVM allocates space in whole extent multiples. It will allocate 4 extents, giving you a Logical Volume of exactly 16MB).*
2.  **Zero Downtime Migration**: While running `pvmove /dev/vdb`, a web application is actively writing user profiles to a database mounted on that volume group. Will the application crash or fail to write? *(Answer: No. The kernel's device-mapper handles the migration transparently at the block level, queuing and mirroring transactions so that the application experiences zero downtime and zero write failures).*
3.  **Physical Volume Expansion**: You replaced a physical 10GB hard drive with a 50GB solid-state drive, and cloned your old partition table. LVM still shows the Physical Volume size as 10GB. What command should you run to tell LVM to recognize the new physical space? *(Answer: Run `sudo pvresize /dev/sdb` to force LVM to scan the physical device size and update its internal extent charts).*
