# Question

Solve this question on: `terminal`

You are given two raw 1GB secondary disks. Neither one is large enough on its own for the storage this task requires, so you must pool both into a single Volume Group before you can carve out the volume.

- Disk 1: `/dev/disk/by-id/virtio-lab037-disk1`
- Disk 2: `/dev/disk/by-id/virtio-lab037-disk2`

1. Initialize both raw disks as LVM Physical Volumes (PV).
2. Create a single Volume Group named `vg_pool` that pools both PVs together.
3. Carve out a Logical Volume named `lv_wide` of size `1500M` from `vg_pool` — deliberately larger than either single disk, so it can only be satisfied by drawing extents from both.
4. Format `lv_wide` with the `ext4` filesystem.
5. Mount the logical volume at `/mnt/lvm-wide`.
6. Confirm with `lvs -o +devices` that `lv_wide`'s extents are actually spread across both physical disks, not sitting entirely on one.
