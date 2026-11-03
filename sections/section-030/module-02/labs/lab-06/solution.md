# Solution Walkthrough

Three moves: write the logbook line, grow the volume and the filesystem together, and check it. After each step you can run `astrona submit -c sections/section-030/module-02/labs/lab-06` to see what the grader still misses.

---

## Step 1: Write the logbook line

Find the filesystem's serial number. Device names can move between launches, so the logbook uses the UUID:

```sh
sudo blkid /dev/vg_data/lv_reports
```

Copy the `UUID` value. Add this line at the end of `/etc/fstab` with `sudo nano /etc/fstab`, using your own UUID:

```text
UUID=<UUID>  /mnt/reports  ext4  defaults  0  2
```

Check the file without mounting anything:

```sh
sudo findmnt --verify
```

---

## Step 2: Grow the volume and the filesystem in one command

```sh
sudo lvextend -r -L +300M /dev/vg_data/lv_reports
```

`-r` is short for `--resizefs`. After `lvextend` makes the volume bigger, it calls `resize2fs` for you, because it finds ext4 on the volume. The `+` matters: `-L +300M` adds 300M, while `-L 300M` would try to set the size to 300M.

---

## Step 3: Check it

```sh
sudo lvs vg_data/lv_reports
df -h /mnt/reports
cat /mnt/reports/reports-marker.txt
sudo umount /mnt/reports
sudo mount -a
findmnt /mnt/reports
```

`lvs` shows about 800M and `df` shows a bigger filesystem. The last two commands prove that the logbook line alone brings the volume back. Run `astrona submit` for the final grade.
