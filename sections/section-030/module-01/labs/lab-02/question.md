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
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../course.md).

The grader checks:

- Confirms both disks were initialised as LVM Physical Volumes (step 1).
- Confirms vg_pool exists and pools exactly 2 PVs (step 2).
- Confirms lv_wide exists at roughly 1500M inside vg_pool (step 3).
- Confirms lv_wide is formatted ext4 and mounted at /mnt/lvm-wide (steps 4-5).
- Confirms lv_wide's extents actually landed on both physical disks (step 6).

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
