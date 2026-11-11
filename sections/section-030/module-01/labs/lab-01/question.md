# Question

Solve this question on: `terminal`

Create a flexible storage layout using the Logical Volume Manager (LVM).

1. Locate the raw 2GB secondary disk on the system.
2. Initialize this raw disk as an LVM Physical Volume (PV).
3. Create a new Volume Group (VG) named `vg_data` using this PV.
4. Carve out a Logical Volume (LV) named `lv_storage` of size `500M` from `vg_data`.
5. Format `lv_storage` with the `ext4` filesystem.
6. Mount the logical volume at `/mnt/lvm-storage`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../course.md).

The grader checks:

- Confirms lab031-disk1 was initialised as an LVM Physical Volume (step 2).
- Confirms vg_data exists and pools the lab031-disk1 PV (step 3).
- Confirms lv_storage exists at roughly 500M inside vg_data (step 4).
- Confirms lv_storage is formatted ext4 and mounted at /mnt/lvm-storage (steps 5-6).

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
