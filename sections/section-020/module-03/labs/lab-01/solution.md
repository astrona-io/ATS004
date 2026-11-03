# Solution Walkthrough

Six moves: discover, log in, find the disk, format it, mount it, then make it persistent. Run everything on `client`. After each step you can run `astrona submit -c sections/section-020/module-03/labs/lab-01` to see what the grader still misses.

---

## Step 1: Discover the target

Ask the server which targets it offers:

```sh
sudo iscsiadm -m discovery -t sendtargets -p 10.10.60.10
```

The command prints one line with the server address, the port 3260 and the target name `iqn.2026-01.io.astrona:storage.cargo`. It also saves a record of the target on your ship.

---

## Step 2: Log in

```sh
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 --login
sudo iscsiadm -m session
```

The second command lists the open session. If you run `astrona submit` now, the session check passes and the filesystem checks still fail.

---

## Step 3: Find the new disk

```sh
lsblk
ls -l /dev/disk/by-path/ | grep iscsi
```

A new 1 GB disk has appeared, and the `by-path` name points at it. Use the `by-path` name in the next steps, because it contains the target name and never changes. With `tgt` the disk is usually the `lun-1` entry.

---

## Step 4: Format and mount

Replace the path below with the `by-path` name you saw (use `ls /dev/disk/by-path/*iscsi*` to see it):

```sh
sudo mkfs.ext4 /dev/disk/by-path/<ISCSI-DISK-PATH>
sudo mount /dev/disk/by-path/<ISCSI-DISK-PATH> /mnt/cargo
findmnt /mnt/cargo
```

`findmnt` shows `/mnt/cargo` with the type `ext4`.

---

## Step 5: Make the mount persistent

Get the UUID:

```sh
sudo blkid /dev/disk/by-path/<ISCSI-DISK-PATH>
```

Add this line to `/etc/fstab` with `sudo nano /etc/fstab`, with your own UUID:

```text
UUID=<UUID> /mnt/cargo ext4 _netdev,nofail 0 2
```

Check the file before any restart:

```sh
sudo findmnt --verify
```

---

## Step 6: Log in automatically

```sh
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 --op update -n node.startup -v automatic
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 | grep node.startup
```

The last line shows `node.startup = automatic`. Now run `astrona submit` for the final grade.
