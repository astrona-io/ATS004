# Question

Solve this question on: `terminal`

Astronaut, a new hold needs flexible shelving that can be photographed before risky changes. An extra 2 GB disk, `/dev/disk/by-id/virtio-lab091-btrfs`, is blank. Turn it into a Btrfs hold with one mounted shelf and a photograph of it.

1. Format the disk as a **Btrfs** filesystem with the label `VAULT`.
2. Create a subvolume named `data` at the top of the filesystem.
3. Mount the subvolume `data` (not the whole filesystem) at `/srv/vault`, and make the mount come back at every launch with a line in `/etc/fstab` that names the filesystem by `UUID=`.
4. Create the file `/srv/vault/cargo.txt` with any content.
5. Take a **read-only** snapshot of the subvolume `data`, named `data-snapshot`, at the top of the filesystem (next to `data`).

The grader checks the live machine: the filesystem type and label, the subvolumes and the read-only flag of the snapshot, what is mounted at `/srv/vault`, the line in `/etc/fstab`, and that the snapshot holds `cargo.txt`.
