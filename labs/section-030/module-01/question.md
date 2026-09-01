# Question

Solve this question on: `terminal`

Create a flexible storage layout using the Logical Volume Manager (LVM).

1. Locate the raw 2GB secondary disk on the system.
2. Initialize this raw disk as an LVM Physical Volume (PV).
3. Create a new Volume Group (VG) named `vg_data` using this PV.
4. Carve out a Logical Volume (LV) named `lv_storage` of size `500M` from `vg_data`.
5. Format `lv_storage` with the `ext4` filesystem.
6. Mount the logical volume at `/mnt/lvm-storage`.
