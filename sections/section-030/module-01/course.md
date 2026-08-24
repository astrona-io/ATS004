# LVM Fundamentals

Static partitions are rigid. If you format a 100GB disk with a single partition, that filesystem is permanently bound to that specific physical hardware. If the filesystem fills up, your only option is to shut down the server, copy the data to a larger disk, switch the mount points, and reboot. This is unacceptable for modern infrastructure.

The Logical Volume Manager (LVM) breaks this rigid link. It creates a layer of abstraction between the physical hardware and the filesystems the operating system sees. Think of LVM as laying out cubicle terrain in a massive, open warehouse. You don't build concrete walls to separate departments; you build modular partitions that you can shift later without tearing down the building.

## The LVM Architecture

LVM relies on three distinct layers. Understanding how they stack on top of each other is non-negotiable.

### 1. Physical Volumes (PVs)

The foundation of LVM is the physical hardware. A Physical Volume is simply a raw disk (`/dev/sdb`) or a standard partition (`/dev/sda2`) that you have initialized for LVM use.

You initialize a device using `pvcreate`.

```bash
pvcreate /dev/sdb /dev/sdc
```

This command writes a small metadata header to the start of the disks. It flags them as owned by LVM. You can inspect all physical volumes on your system with the summary command `pvs` or the detailed command `pvdisplay`.

### 2. Volume Groups (VGs)

Physical Volumes on their own are useless. They must be grouped together into a massive pool of raw storage. This pool is the Volume Group.

When you create a Volume Group, you are essentially welding multiple physical disks together into one giant virtual hard drive.

```bash
vgcreate data_pool /dev/sdb /dev/sdc
```

This command creates a Volume Group named `data_pool` by absorbing both physical disks. If each disk was 1TB, `data_pool` now has 2TB of capacity. Use `vgs` to see the total size and available free space in your pools.

### The Currency of LVM: Physical Extents (PEs)

When LVM absorbs a disk into a Volume Group, it chops the disk up into identical, tiny blocks of space called Physical Extents (PEs). By default, a PE is 4 Megabytes.

Think of PEs as Lego bricks. The Volume Group is just a massive bin holding millions of these 4MB blocks. Everything LVM does from this point forward involves assigning or moving these identical blocks.

### 3. Logical Volumes (LVs)

You cannot format a Volume Group. It is just a pool of unassigned blocks. To actually store data, you carve out a virtual partition from the Volume Group. This is the Logical Volume.

A Logical Volume behaves exactly like a traditional partition, but it is built out of extents from the shared pool.

```bash
lvcreate -n app_data -L 50G data_pool
```

This command creates a Logical Volume named `app_data`. The `-n` flag specifies the name. The `-L` flag requests exactly 50 Gigabytes of space. LVM fulfills this request by grabbing 12,800 Physical Extents (50GB / 4MB) from the `data_pool` and linking them together into a virtual block device at `/dev/data_pool/app_data`.

You can now format this device with standard tools like `mkfs.ext4` and mount it, entirely unaware that the blocks might be scattered across two different physical hard drives. Use `lvs` to track your active Logical Volumes.

## Self-Check and Verification

To prove you understand the foundational layers of LVM:

1. Attach two blank disks to a Linux machine.
2. Initialize both disks as Physical Volumes using `pvcreate` and verify with `pvs`.
3. Combine both disks into a single Volume Group named `storage_vg` using `vgcreate`.
4. Run `vgs` and `vgdisplay storage_vg` to verify the combined capacity and the size of the Physical Extents.
5. Provision a 5GB Logical Volume named `test_vol` using `lvcreate`.
6. Format the Logical Volume with an ext4 filesystem and mount it.
