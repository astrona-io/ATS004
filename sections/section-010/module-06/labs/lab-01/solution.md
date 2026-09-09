# Solution Guide: systemd Mount and Automount Units

Follow these steps to mount a disk on demand using native systemd `.mount` and `.automount` units.

---

## Step 1: Format the Disk

```bash
sudo mkfs.ext4 /dev/disk/by-id/virtio-lab016-data1
```

---

## Step 2: Confirm the Unit Filename

A `.mount` unit's filename must match its mount path, run through systemd's path-escaping:

```bash
systemd-escape -p --suffix=mount /srv/appdata
```

This prints `srv-appdata.mount` — the `.automount` unit shares the same base name.

---

## Step 3: Write the `.mount` Unit

Get the disk's UUID and create the mount point:

```bash
UUID=$(sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab016-data1)
sudo mkdir -p /srv/appdata
```

Write `/etc/systemd/system/srv-appdata.mount`:

```bash
sudo tee /etc/systemd/system/srv-appdata.mount >/dev/null <<EOF
[Unit]
Description=Application data filesystem at /srv/appdata

[Mount]
What=UUID=$UUID
Where=/srv/appdata
Type=ext4
Options=defaults,nofail

[Install]
WantedBy=multi-user.target
EOF
```

---

## Step 4: Write the Paired `.automount` Unit

```bash
sudo tee /etc/systemd/system/srv-appdata.automount >/dev/null <<EOF
[Unit]
Description=Automount for /srv/appdata

[Automount]
Where=/srv/appdata
TimeoutIdleSec=30

[Install]
WantedBy=multi-user.target
EOF
```

---

## Step 5: Activate and Trigger

Reload unit files, then enable and start the `.automount` unit — never the `.mount` unit directly for on-demand behaviour:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now srv-appdata.automount
```

Trigger the mount by accessing the path, then confirm it is active:

```bash
ls /srv/appdata
systemctl is-active srv-appdata.mount
findmnt /srv/appdata
```

`srv-appdata.mount` should now report `active`, and `findmnt` should show `/srv/appdata` mounted `ext4`.
