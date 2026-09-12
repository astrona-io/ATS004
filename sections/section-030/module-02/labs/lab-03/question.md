# Question

Solve this question on: `terminal`

A Volume Group named `vg_live` already exists on a single 2GB disk, `/dev/disk/by-id/virtio-lab038-disk1`, and is almost completely full — a Logical Volume named `lv_active` occupies nearly all of it, is formatted `ext4`, and is mounted at `/mnt/lvm-live` serving live data. That disk needs to be retired. A second, completely raw 2GB disk is available at `/dev/disk/by-id/virtio-lab038-disk2` — it is **not** part of any Volume Group yet.

1. Initialize `/dev/disk/by-id/virtio-lab038-disk2` as an LVM Physical Volume.
2. Add it to the existing `vg_live` Volume Group using `vgextend` — `disk1` has no free space of its own to migrate onto, so this step is required before anything can move.
3. Perform a live, online migration with `pvmove` to move every extent off `/dev/disk/by-id/virtio-lab038-disk1` onto the newly added disk.
4. Once `/dev/disk/by-id/virtio-lab038-disk1` is completely free, remove it from `vg_live` with `vgreduce`.
5. Erase its LVM signature with `pvremove`, returning it to a raw state.
6. Ensure `lv_active` at `/mnt/lvm-live` remains fully readable and writable throughout, and that its data survives the whole process.
