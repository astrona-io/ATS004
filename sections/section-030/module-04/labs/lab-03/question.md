# Question

Solve this question on: `terminal`

Astronaut, the mirror `/dev/md0` is a RAID 1 array on two disks. It is mounted at `/mnt/raid` and holds `manifest.txt`. A third disk still carries the RAID label of an old, retired array and must be cleaned before it can be reused.

- Mirror members: `/dev/disk/by-id/virtio-lab030403-a` and `/dev/disk/by-id/virtio-lab030403-b`
- Disk with the old label: `/dev/disk/by-id/virtio-lab030403-c`

1. Unmount `/mnt/raid` and stop the array `/dev/md0`. Confirm it is gone from `/proc/mdstat`.
2. Put the array back together with `mdadm --assemble`, naming `/dev/md0` and its two member disks. Confirm both disks are active.
3. Mount `/dev/md0` at `/mnt/raid` again and check that `manifest.txt` is still there.
4. Find out whether the disk with the old label shows a RAID label (`mdadm --examine`). If a leftover array holds it, stop that array first. Then erase the label with `mdadm --zero-superblock` and confirm that `mdadm --examine` finds no label.

The grader checks that `/dev/md0` is a clean RAID 1 with two active members, mounted at `/mnt/raid` with its file, and that `mdadm --examine` reports no md superblock on the third disk.
