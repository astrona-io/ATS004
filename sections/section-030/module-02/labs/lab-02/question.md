# Question

Solve this question on: `terminal`

A volume group `vg_resize` with a 300M logical volume `lv_data` (ext4,
mounted at `/mnt/resize-data`) is already set up.

1.  Grow `lv_data` by 200M (to 500M) with `lvextend`, then grow the ext4
    filesystem to match.
2.  Shrink `lv_data` back down to 350M. Do this in the correct order for a
    safe shrink: unmount it, check the filesystem, shrink the filesystem
    first, then shrink the logical volume — never the other way round.
3.  Remount `lv_data` at `/mnt/resize-data` and confirm `marker.txt` still
    has its original content.
