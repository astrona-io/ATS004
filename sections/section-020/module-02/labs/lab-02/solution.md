# Solution Walkthrough

Four moves: find why NFS is refused, fix the export, write two logbook lines, and prove them with `mount -a`. Run everything on the one ship you are on. After each step you can run `astrona submit -c sections/section-020/module-02/labs/lab-02` to see what the grader still misses.

---

## Step 1: Find why NFS is refused

Ask the NFS server which holds it offers, and to whom:

```sh
sudo exportfs -v
showmount -e 127.0.0.1
```

`/srv/nfs/reports` is offered only to `10.99.0.0/24`. This ship is `127.0.0.1`, so the server says no. A refused mount reads "access denied by server while mounting". The fault is in the server's list, not on the client.

---

## Step 2: Fix the export

Open the export list with `sudo nano /etc/exports` and change the client part of the line, so that it reads:

```text
/srv/nfs/reports 127.0.0.1(ro,sync,no_subtree_check)
```

Ask the server to read the file again, and test the mount by hand:

```sh
sudo exportfs -ra
sudo exportfs -v
sudo mount -t nfs -o ro 127.0.0.1:/srv/nfs/reports /mnt/nfs-reports
findmnt /mnt/nfs-reports
sudo umount /mnt/nfs-reports
```

`exportfs -ra` makes the kernel re-read `/etc/exports`. The mount now works, so the fault was the client address. We unmount again, because the next steps make the logbook do the docking.

---

## Step 3: Write the two logbook lines

Add the NFS line at the end of `/etc/fstab` (a file under `/etc` is saved with `sudo`, for example `sudo nano /etc/fstab`):

```text
127.0.0.1:/srv/nfs/reports  /mnt/nfs-reports  nfs  _netdev,nofail,ro  0  0
```

Add the SSHFS line below it. `root` makes this mount at launch, so it needs root's key file with its full path:

```text
sshuser@localhost:/opt/remote-data  /mnt/sshfs-logs  fuse.sshfs  _netdev,allow_other,IdentityFile=/root/.ssh/id_ed25519  0  0
```

`_netdev` tells systemd to wait for the network. `nofail` lets the ship launch even if the NFS server does not answer.

---

## Step 4: Prove it before any restart

```sh
sudo systemctl daemon-reload
sudo findmnt --verify
sudo mount -a
findmnt /mnt/nfs-reports /mnt/sshfs-logs
ls /mnt/nfs-reports /mnt/sshfs-logs
```

`findmnt --verify` reads `/etc/fstab` and reports mistakes without mounting anything. `mount -a` docks every line that is not docked yet. You should see an `nfs4` mount and a `fuse.sshfs` mount, and the two files. Run `astrona submit` for the final grade.
