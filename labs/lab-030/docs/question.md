# Question

Solve this question on: `terminal`

You're required to perform changes on LVM volumes:

Reduce the volume group `vol1` by removing the physical volume that currently holds the `vol1/data1` logical volume's extents (identify it with `pvs`/`lvs` — don't assume a specific `/dev/vdX` letter, since it isn't guaranteed stable).

Create a new volume group named `vol2` which uses that freed disk.

Create a 50M logical volume named `p1` for volume group `vol2`.

Format that new logical volume with ext4.
