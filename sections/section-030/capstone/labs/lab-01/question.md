# Question

Solve this question on: `terminal`

Astronaut, your training ship has a shared cargo pool called `vol1`. LVM (the Logical Volume Manager) builds that pool from two cargo holds (two disks). One storage area cut from the pool, the logical volume `vol1/data1`, sits completely on one of those holds. Mission control wants that hold taken out of `vol1` and turned into a pool of its own.

Do not guess the disk from a `/dev/vdX` letter. The letters on this ship are not stable, so find the right disk with `pvs` and `lvs`.

Your tasks:

1. Reduce the volume group `vol1` by removing the physical volume that holds the extents of the logical volume `vol1/data1`.
2. Create a new volume group named `vol2` that uses that freed disk.
3. Create a logical volume named `p1` in volume group `vol2`, with a size of `50M`.
4. Format the logical volume `p1` with `ext4`.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-01](../../../module-01/course.md), [module-02](../../../module-02/course.md), [module-03](../../../module-03/course.md), [module-04](../../../module-04/course.md).

The grader checks:

- Confirms the 'lab030-b' disk (resolved via by-id serial) is no longer a PV member of vol1.
- Confirms vol2 exists with the 'lab030-b' disk as its physical volume.
- Confirms vol2/p1 is a ~50M logical volume formatted ext4.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
