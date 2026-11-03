# Solution Walkthrough

Five moves, in this order: format the disk, check the unit name, write the `.mount` unit, write the `.automount` unit, then enable the automount and trigger it. The last step checks the machine the same way the grader does.

---

## Step 1: Format the disk

Build the ext4 shelves on the new hold:

```sh
sudo mkfs.ext4 /dev/disk/by-id/virtio-lab016-data1
```

`mkfs.ext4` prints a few lines about blocks, inodes and the journal, and ends with `done`.

---

## Step 2: Confirm the unit filename

A `.mount` unit's filename must match its mount path, run through systemd's path escaping:

```sh
systemd-escape -p --suffix=mount /srv/appdata
```

This prints `srv-appdata.mount`. The `.automount` unit uses the same base name: `srv-appdata.automount`.

---

## Step 3: Write the `.mount` unit

Print the disk's UUID and create the mount point:

```sh
sudo blkid -s UUID -o value /dev/disk/by-id/virtio-lab016-data1
sudo mkdir -p /srv/appdata
```

Save this as `/etc/systemd/system/srv-appdata.mount`. Replace `<UUID>` with the value `blkid` printed. Files under `/etc` are saved with `sudo`, for example `sudo nano /etc/systemd/system/srv-appdata.mount`:

```ini
[Unit]
Description=Application data filesystem at /srv/appdata

[Mount]
What=UUID=<UUID>
Where=/srv/appdata
Type=ext4
Options=defaults,nofail

[Install]
WantedBy=multi-user.target
```

`What=UUID=` keeps the unit working even if the device name moves, and `nofail` stops a missing disk from failing the boot. The grader does not check these two lines, but they are good habits for the exam.

---

## Step 4: Write the paired `.automount` unit

Save this as `/etc/systemd/system/srv-appdata.automount`:

```ini
[Unit]
Description=Automount for /srv/appdata

[Automount]
Where=/srv/appdata
TimeoutIdleSec=30

[Install]
WantedBy=multi-user.target
```

`TimeoutIdleSec=30` tells systemd to unmount the filesystem after 30 seconds with nobody using it.

---

## Step 5: Activate and trigger

Make systemd read the new files, then enable and start the `.automount` unit. Do not enable the `.mount` unit directly for on-demand mounting:

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now srv-appdata.automount
```

Trigger the mount by accessing the path, then check that it is active:

```sh
ls /srv/appdata
systemctl is-active srv-appdata.mount
findmnt /srv/appdata
```

`srv-appdata.mount` should now report `active`, and `findmnt` should show `/srv/appdata` mounted as `ext4`. If you wait longer than 30 seconds, the idle timeout unmounts it again; run `ls /srv/appdata` once more and it comes back.

---

## Step 6: Check like the grader, then submit

Run the same checks the grader runs:

```sh
grep -E '^(Where|Type)=' /etc/systemd/system/srv-appdata.mount
grep -E '^(Where|TimeoutIdleSec)=' /etc/systemd/system/srv-appdata.automount
systemctl is-enabled srv-appdata.automount
ls /srv/appdata >/dev/null && systemctl is-active srv-appdata.mount
findmnt -no FSTYPE /srv/appdata
```

Look for `Where=/srv/appdata` and `Type=ext4` in the mount unit, `Where=/srv/appdata` and a `TimeoutIdleSec=` line in the automount unit, `enabled` for the automount, `active` for the mount, and `ext4` as the filesystem type.

When everything matches, send the mission for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-01
```
