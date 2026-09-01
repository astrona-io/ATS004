# Solution Guide (Offline & Exam Friendly)

This step-by-step guide explains how to find package names, options, and configuration formats using system utilities rather than memorization.

---

## Part 1: SSHFS Mount from `terminal` to `app-srv1`

You need to mount `/data-export` from `app-srv1` to `/app-srv1/data-export` on `terminal` using SSHFS, with read-write access and `allow_other` enabled.

### Step 1 (on `terminal`): Confirm SSH Access to `app-srv1`

Make sure you can connect to `app-srv1` via SSH:
```bash
ssh root@app-srv1 'ls -ld /data-export'
```
*Enter password `AstronaLab2024!` if prompted.*

### Step 2 (on `terminal`): Find and Install SSHFS

1. If you do not remember the exact package name for SSHFS, search your package manager:
   ```bash
   apt-cache search sshfs   # On Debian/Ubuntu
   # or: dnf search sshfs   # On RHEL/Fedora
   ```
2. Install the package:
   ```bash
   sudo apt-get install -y sshfs
   ```

### Step 3 (on `terminal`): Configure FUSE to Allow Other Users

By default, FUSE mounts do not allow other local users to access them. You must enable this option in the FUSE configuration file.

1. Find the FUSE config files:
   ```bash
   ls /etc/*fuse*
   ```
   *This reveals `/etc/fuse.conf`.*
2. Check the FUSE manual page to see how to enable options for non-owners:
   ```bash
   man 5 fuse.conf
   ```
   *Searching `/allow_other` inside the man page shows that you need to uncomment or add the line `user_allow_other`.*
3. Append this setting to the config file:
   ```bash
   echo 'user_allow_other' | sudo tee -a /etc/fuse.conf
   ```

### Step 4 (on `terminal`): Mount the Remote Directory

1. Create the mount directory:
   ```bash
   sudo mkdir -p /app-srv1/data-export
   ```
2. Run the `sshfs` mount command. If you forget `sshfs` syntax, run `sshfs -h` or `sshfs --help`. Under the options section, it lists `-o opt,...`.
3. Mount with the required options:
   ```bash
   sudo sshfs -o allow_other,rw root@app-srv1:/data-export /app-srv1/data-export
   ```
4. Verify the mount is active and accessible:
   ```bash
   mount | grep sshfs
   ```

---

## Part 2: NFS Share from `terminal` to `app-srv1`

Export `/nfs/share` read-only from `terminal` to the private subnet `10.10.40.0/24`, and mount it on `app-srv1`.

### Step 5 (on `terminal`): Install and Verify NFS Server

1. Find the NFS server package:
   ```bash
   apt-cache search nfs-server
   ```
2. Install and start the server:
   ```bash
   sudo apt-get install -y nfs-kernel-server
   sudo systemctl enable --now nfs-kernel-server
   ```

### Step 6 (on `terminal`): Configure the NFS Export

You need to share `/nfs/share` with the subnet `10.10.40.0/24` with read-only access.

1. Create the shared directory:
   ```bash
   sudo mkdir -p /nfs/share
   ```
2. To find the correct format for `/etc/exports`, consult its manual page:
   ```bash
   man 5 exports
   ```
   *Look at the "EXAMPLE" section at the bottom. It shows formats like:*
   ```text
   /usr/export  192.168.1.0/24(ro,insecure,sync)
   ```
3. Open `/etc/exports` in your editor or append the share configuration using `tee`:
   ```bash
   echo '/nfs/share 10.10.40.0/24(ro,sync,no_subtree_check)' | sudo tee -a /etc/exports
   ```
   *Note: Ensure there are no spaces between the subnet and the opening parenthesis `(`.*

### Step 7 (on `terminal`): Apply the Exports

Apply the changes:
```bash
sudo exportfs -ra
sudo exportfs -v
```
`-ra` re-exports everything in `/etc/exports`, and `-v` displays the active configuration to verify that `ro` is applied.

---

### Step 8 (on `app-srv1`): Discover and Mount the NFS Export

1. Check what exports are available on `terminal`:
   ```bash
   showmount -e terminal
   ```
   *If `showmount` is missing, you can find and install `nfs-common` or `nfs-utils` packages.*
2. Create the local mount directory:
   ```bash
   sudo mkdir -p /nfs/terminal/share
   ```
3. Mount the NFS export. If you do not remember the NFS mount type, check `man mount` and search `/nfs`:
   ```bash
   sudo mount -t nfs terminal:/nfs/share /nfs/terminal/share
   ```

---

## Verification

Run these checks to confirm success:

```bash
# On terminal: Check SSHFS mount options
mount | grep '/app-srv1/data-export'

# On terminal: Check NFS export status
sudo exportfs -v

# On app-srv1: Check NFS mount status
mount | grep '/nfs/terminal/share'

# On app-srv1: Confirm writing is rejected (Read-only)
touch /nfs/terminal/share/testfile
```
