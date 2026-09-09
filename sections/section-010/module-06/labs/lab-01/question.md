# Question

Solve this question on: `terminal`

An extra 1GB disk (`/dev/disk/by-id/virtio-lab016-data1`) is attached but unformatted. Make it available at `/srv/appdata` **on demand**, using native systemd units — not `/etc/fstab`.

1. Format the disk with the `ext4` filesystem.
2. Write a native `.mount` unit at `/etc/systemd/system/srv-appdata.mount` that mounts it at `/srv/appdata` (keyed by `UUID=`, `Type=ext4`, `Options=defaults,nofail`).
3. Write a paired `.automount` unit at `/etc/systemd/system/srv-appdata.automount` for `/srv/appdata`, with a 30 second idle timeout (`TimeoutIdleSec=30`).
4. Reload systemd and enable + start the **`.automount`** unit (not the `.mount` unit directly).
5. Trigger the mount by accessing `/srv/appdata`, and confirm the `.mount` unit becomes active.
