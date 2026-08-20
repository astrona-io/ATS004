# Solution

## Step 1: Install and enable autofs

```bash
sudo apt-get install -y autofs   # or: sudo dnf install -y autofs
sudo systemctl enable --now autofs
```

Check `man 8 automount` — this is the daemon that `systemctl` actually starts under the `autofs` service unit; skimming its synopsis confirms it's designed to run continuously, watching the mount points declared by the master map.

## Step 2: Create the base mount directory autofs will manage

```bash
sudo mkdir -p /mnt/auto
```

Note we create `/mnt/auto`, the *parent* directory referenced by the master map — we do **not** manually create `/mnt/auto/shared` itself. autofs creates and destroys that subdirectory dynamically as part of mounting/unmounting; pre-creating it isn't wrong, but understanding that autofs owns that specific path is important for later debugging.

## Step 3: Point the master map at an indirect map file

Check `man 5 autofs.master` — the format documented there is `mount-point map-name [options]` per line, and this is where the idle `timeout=` belongs, not in the indirect map file itself.

Edit `/etc/auto.master` (or add a file under `/etc/auto.master.d/shared.autofs` — either is valid, the latter is cleaner for not touching the main file):

```
/mnt/auto  /etc/auto.shared  --timeout=300
```

`/mnt/auto` is the base directory autofs will watch; `/etc/auto.shared` is the indirect map file that defines what lives under it; `--timeout=300` sets the idle-unmount window to 300 seconds (5 minutes), satisfying the "released after 5 minutes of inactivity" requirement.

## Step 4: Define the indirect map entry

Check `man 5 autofs` — the map-file syntax section documents the `key [-options] location` format used here; `-options` are standard `mount`-style options for the target filesystem type.

Create `/etc/auto.shared`:

```
shared  -fstype=nfs,rw  data-001:/exports/shared
```

Reading this line left to right: `shared` is the key — it becomes the subdirectory name under `/mnt/auto`, so the final accessible path is `/mnt/auto/shared`, matching the task's required path. `-fstype=nfs,rw` are the mount options, explicitly specifying NFS and read-write access. `data-001:/exports/shared` is the location — the same `host:/export` syntax used by a normal `mount -t nfs` command.

## Step 5: Reload autofs to pick up the new maps

```bash
sudo systemctl restart autofs
```

A restart re-reads `/etc/auto.master` and every map file it references. This is lighter than a reboot and is the standard workflow for iterating on autofs configuration — no filesystem is actually touched by the restart itself, since nothing is mounted until accessed.

## Step 6: Trigger the automount and verify it happened

```bash
cd /mnt/auto/shared
ls
mount | grep shared
```

Simply changing into `/mnt/auto/shared` is enough to trigger automount's on-demand mount — the kernel's autofs filesystem module intercepts the access to that not-yet-mounted path, notifies the `automount` daemon, which performs the actual `mount -t nfs data-001:/exports/shared /mnt/auto/shared` on your behalf. `mount | grep shared` should now show the live NFS mount.

## Step 7: Confirm the idle timeout actually releases the mount

```bash
cd ~
sleep 310
mount | grep shared
```

After leaving the directory (so nothing keeps it "in use") and waiting past the 300-second timeout, the mount should no longer appear in `mount` output — `automount` unmounted it automatically once idle, with zero manual `umount` involved. (In a real timed exam you would not literally `sleep` for 5 minutes to prove this — state the mechanism and, if time allows, shorten the timeout temporarily to something like `--timeout=10` to demonstrate the behavior quickly, then set it back to `300`.)

## Verification

```bash
# master map correctly references the indirect map and timeout
cat /etc/auto.master | grep auto.shared
# expect: /mnt/auto  /etc/auto.shared  --timeout=300

# indirect map defines the shared key correctly
cat /etc/auto.shared
# expect: shared  -fstype=nfs,rw  data-001:/exports/shared

# service is active
systemctl is-active autofs
# expect: active

# on-demand mount works
cd /mnt/auto/shared && mount | grep shared
# expect: data-001:/exports/shared on /mnt/auto/shared type nfs (rw,...)

# no permanent fstab entry exists for this share
grep shared /etc/fstab
# expect: no output
```

## Command Summary

```bash
sudo apt-get install -y autofs
sudo systemctl enable --now autofs
sudo mkdir -p /mnt/auto
# edit /etc/auto.master, add: /mnt/auto  /etc/auto.shared  --timeout=300
# create /etc/auto.shared, add: shared  -fstype=nfs,rw  data-001:/exports/shared
sudo systemctl restart autofs
cd /mnt/auto/shared
mount | grep shared
cd ~
mount | grep shared   # (after timeout) expect no output
```
