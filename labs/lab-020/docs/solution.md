# Solution

## Step 1 (on `terminal`): Confirm SSH access to app-srv1 works

```bash
ssh root@app-srv1 'ls -ld /data-export'
```

`app-srv1`'s root account uses password authentication for this lab (password: `AstronaLab2024!`, see the lab README) — enter it when prompted. SSHFS piggybacks entirely on an existing SSH session, so if you can already `ssh app-srv1` and see the directory, SSHFS has everything it needs — there's no separate service to install on `app-srv1` for this part.

## Step 2 (on `terminal`): Install sshfs if needed and prepare the local mountpoint

```bash
sudo apt-get install -y sshfs   # or: dnf install -y fuse-sshfs
sudo mkdir -p /app-srv1/data-export
```

## Step 3 (on `terminal`): Allow non-owning users to see FUSE mounts system-wide

Check `man 5 fuse.conf` — this is a separate man page from `sshfs`, and it's the one that documents `user_allow_other` as the system-level opt-in required before any user's `-o allow_other` mount request will be honored.

```bash
echo 'user_allow_other' | sudo tee -a /etc/fuse.conf
```

The `allow_other` mount option is refused by the FUSE kernel module unless `/etc/fuse.conf` explicitly contains `user_allow_other` — this is a deliberate security gate so that a regular user can't silently expose their FUSE mounts to every other local user without a sysadmin-level opt-in first.

## Step 4 (on `terminal`): Mount the remote directory read-write with allow_other

```bash
sudo sshfs -o allow_other,rw root@app-srv1:/data-export /app-srv1/data-export
```

`sshfs` opens an SSH connection to `app-srv1`, authenticates, and translates every filesystem operation against `/app-srv1/data-export` into SFTP protocol calls against `/data-export` on the remote host. `rw` is actually the SSHFS default (it's not read-only unless you pass `-o ro`), but specifying it explicitly documents intent and satisfies "should be read-write" unambiguously.

Verify:

```bash
mount | grep sshfs
touch /app-srv1/data-export/write-test && rm /app-srv1/data-export/write-test
```

## Step 5 (on `terminal`): Confirm NFS server packages and services

```bash
sudo apt-get install -y nfs-kernel-server   # Debian/Ubuntu
# or: sudo dnf install -y nfs-utils && sudo systemctl enable --now nfs-server  # RHEL/Fedora
sudo systemctl status nfs-server 2>/dev/null || sudo systemctl status nfs-kernel-server
```

The task states NFS is "already installed" — this step is about confirming the daemon is actually running before you export anything against it.

## Step 6 (on `terminal`): Create the share directory and export it read-only to the subnet

```bash
sudo mkdir -p /nfs/share
```

Check `man 5 exports` — note the section number: this is the config-file format page, distinct from `man 8 exportfs` (the command). The page's `client_spec` discussion covers CIDR notation, and the `general options` list documents `ro`/`rw`/`sync`/`no_subtree_check`.

Edit `/etc/exports`:

```
/nfs/share 10.10.40.0/24(ro,sync,no_subtree_check)
```

Each line is `<path> <client-spec>(<options>)` — note there is **no space** between the client spec and the opening parenthesis; a stray space there silently changes the meaning to "export to this client with default options, AND export to everyone else with these options," which is a classic NFS misconfiguration. `ro` makes the export read-only as required, `10.10.40.0/24` restricts it to this lab's private subnet exactly as asked, `sync` commits writes before acknowledging them (safer default), and `no_subtree_check` avoids extra consistency checking overhead that isn't needed for a whole-filesystem export.

## Step 7 (on `terminal`): Apply the export

```bash
sudo exportfs -ra
sudo exportfs -v
```

`-r` re-exports everything in `/etc/exports` (removing anything no longer listed), `-a` targets all entries, and `-v` verbosely confirms exactly what's now active, including the resolved options — a good sanity check that `ro` and the subnet actually took effect as written.

## Step 8 (on `app-srv1`): Confirm what terminal is exporting, then mount it

```bash
showmount -e terminal
```

This queries `terminal`'s mountd over RPC and lists its exports — confirming reachability and the export list before committing to a mount attempt.

```bash
sudo mkdir -p /nfs/terminal/share
sudo mount -t nfs terminal:/nfs/share /nfs/terminal/share
```

`-t nfs` tells the generic `mount` command to hand off to the NFS client kernel module. Because the export is `ro`, attempts to write from `app-srv1` into `/nfs/terminal/share` will be rejected by the server regardless of local permissions — read-only is enforced server-side, not just advisory.

## Step 9 (on `app-srv1`): Verify and optionally persist

```bash
mount | grep nfs
findmnt /nfs/terminal/share
```

To persist across reboots, add to `/etc/fstab` on `app-srv1`:

```
terminal:/nfs/share  /nfs/terminal/share  nfs  ro,defaults  0  0
```

## Verification

```bash
# On terminal: SSHFS mount active and read-write
mount | grep '/app-srv1/data-export'
# expect: app-srv1:/data-export on /app-srv1/data-export type fuse.sshfs (rw,...,allow_other)

# On terminal: export list shows the ro subnet restriction
sudo exportfs -v
# expect: /nfs/share  10.10.40.0/24(ro,...)

# On app-srv1: NFS mount active
mount | grep '/nfs/terminal/share'
# expect: terminal:/nfs/share on /nfs/terminal/share type nfs (ro,...)

# On app-srv1: write should fail (read-only export)
touch /nfs/terminal/share/should-fail
# expect: Read-only file system
```

## Command Summary

```bash
# terminal (SSHFS client + NFS server)
ssh root@app-srv1 'ls -ld /data-export'
sudo apt-get install -y sshfs
sudo mkdir -p /app-srv1/data-export
echo 'user_allow_other' | sudo tee -a /etc/fuse.conf
sudo sshfs -o allow_other,rw root@app-srv1:/data-export /app-srv1/data-export
mount | grep sshfs

sudo mkdir -p /nfs/share
sudo tee -a /etc/exports <<< '/nfs/share 10.10.40.0/24(ro,sync,no_subtree_check)'
sudo exportfs -ra
sudo exportfs -v

# app-srv1 (NFS client)
showmount -e terminal
sudo mkdir -p /nfs/terminal/share
sudo mount -t nfs terminal:/nfs/share /nfs/terminal/share
mount | grep nfs
```
