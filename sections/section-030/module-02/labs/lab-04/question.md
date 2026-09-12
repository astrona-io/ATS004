# Question

Solve this question on: `terminal`

A Volume Group named `vg_split` spans three disks, and a single Logical Volume named `lv_data` already has its extents spread across all three of them:

- Disk 1: `/dev/disk/by-id/virtio-lab039-disk1`
- Disk 2: `/dev/disk/by-id/virtio-lab039-disk2` (to be removed)
- Disk 3: `/dev/disk/by-id/virtio-lab039-disk3`

`lv_data` is formatted `ext4` and mounted at `/mnt/lvm-split`, serving live data.

1. Confirm with `lvs -o +devices` that `lv_data`'s extents are currently spread across all three disks, not just one.
2. Live-migrate every extent off `/dev/disk/by-id/virtio-lab039-disk2` using `pvmove` — do **not** add any new disk first; the two remaining disks already have enough combined free space to absorb it.
3. Once `disk2` is completely free, remove it from `vg_split` with `vgreduce`.
4. Erase its LVM signature with `pvremove`, returning it to a raw state.
5. Confirm `vg_split` ends up with exactly two PVs, and that `lv_data` remains fully readable and writable at its original size throughout.
