# Question

**Optional practice.** Guided introduction with destination capacity already available. The main learning path uses [lab 038](../lab-03/README.md). This ID remains runnable and covered by CI.

Solve this question on: `terminal`

You are tasked with shrinking a production Volume Group named `vg_migration` by removing one of its physical disks without causing downtime.

- Disk 1: `/dev/disk/by-id/virtio-lab032-disk1` (to be removed)
- Disk 2: `/dev/disk/by-id/virtio-lab032-disk2` (target migration disk)

1. Perform a live, online LVM migration using `pvmove` to move all allocated extents off `/dev/disk/by-id/virtio-lab032-disk1` onto `/dev/disk/by-id/virtio-lab032-disk2`.
2. Once the physical volume `/dev/disk/by-id/virtio-lab032-disk1` is completely free, remove it from the Volume Group `vg_migration` using `vgreduce`.
3. Erase LVM signatures on `/dev/disk/by-id/virtio-lab032-disk1` using `pvremove` to return it to a raw state.
4. Ensure the logical volume at `/mnt/lvm-migration` remains fully readable and writable throughout the process.

<!-- curriculum-links -->
## Related lessons and assessment

Read [section-030/module-02](../../course.md).

The grader checks:

- Confirms extent migration and removal of disk1 from the VG.

Inspect your work before submitting. Submission ends this environment.
