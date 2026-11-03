# Question

Solve this question on: `terminal`

Astronaut, before a risky repair, mission control wants an exact copy of one cargo hold. Two spare 1 GB disks are attached to this machine. One already holds a small filesystem with a file on it (the source). The other is blank (the clone). Make the blank disk an exact copy of the source.

1. Identify the two spare disks. The source disk carries data; the clone disk is blank. Their stable paths are `/dev/disk/by-id/virtio-lab018-source` and `/dev/disk/by-id/virtio-lab018-clone`.
2. Clone the source disk onto the clone disk with `dd`, byte for byte.
3. Verify that the clone is an exact match of the source with a checksum comparison.

The grader compares the two disks byte for byte, and then mounts the clone read-only to check its label and the file on it.
