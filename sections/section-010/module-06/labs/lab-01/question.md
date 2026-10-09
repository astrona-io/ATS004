# Question

Solve this question on: `terminal`

Astronaut, a new 1 GB cargo hold has been fitted to your training ship. It is attached as `/dev/disk/by-id/virtio-lab016-data1` and has no filesystem yet. Mission control wants it to dock at `/srv/appdata` only when someone knocks on the hatch, and to do it with native systemd units, not with `/etc/fstab`.

1. Format the disk with the **ext4** filesystem.
2. Write a native `.mount` unit at `/etc/systemd/system/srv-appdata.mount` that mounts the disk at `/srv/appdata`. It must contain the lines `Where=/srv/appdata` and `Type=ext4`.
3. Write a paired `.automount` unit at `/etc/systemd/system/srv-appdata.automount` for the same path. It must contain the line `Where=/srv/appdata` and set an idle timeout with `TimeoutIdleSec=` (for example `TimeoutIdleSec=30`).
4. Reload systemd, then **enable** and start the `.automount` unit. Do not enable the `.mount` unit directly.
5. Access `/srv/appdata` and confirm that `srv-appdata.mount` becomes active, with `/srv/appdata` mounted as ext4.

The grader checks the live machine: it reads both unit files, checks that `srv-appdata.automount` is enabled, then accesses `/srv/appdata` itself and checks that `srv-appdata.mount` is active and the mounted filesystem is ext4.
