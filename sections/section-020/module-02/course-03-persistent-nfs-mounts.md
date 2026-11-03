# Persistent NFS Mounts

A `mount` command only lasts until the ship lands. The exam wants the mount back after a reboot, and it wants the ship to launch even when the other ship is silent. This page shows the `/etc/fstab` line for an NFS mount, the options that keep the launch safe, and the two checks to run before you trust it.

## One fstab line, six fields

An NFS entry in `/etc/fstab` has the same six fields as any other entry. The first field is `server:/path` instead of a `UUID=`, because the cargo lives on another ship and has no local disk name. The type is `nfs`.

Save this line at the end of `/etc/fstab` on `client` (a file under `/etc` is saved with `sudo`, for example `sudo nano /etc/fstab`):

```text
server:/nfs/share  /mnt/nfs  nfs  _netdev,nofail,ro,soft,timeo=30,retrans=2  0  0
```

The options do these jobs:

- **`_netdev`** marks the mount as needing the network, so systemd waits for the communications array before it docks.
- **`nofail`** lets the launch go on if the mount fails. Without it, a silent server can hold up the whole boot.
- **`ro,soft,timeo=30,retrans=2`** are the read-only and give-up options from the earlier page, shown here only as an example of data options. Use `rw` and the default `hard` for a writable share.

### See it in your playground

Work on `client`. The share must be exported on `server` first (`sudo exportfs -v` there shows it). Make sure the share is not mounted by hand, then apply the new line:

<!-- astrona:playground:renew -->

```sh
sudo umount /mnt/nfs
sudo systemctl daemon-reload
sudo findmnt --verify
sudo mount -a
findmnt /mnt/nfs
```

`findmnt --verify` reads `/etc/fstab` and reports mistakes without mounting. `mount -a` mounts every line that is not mounted yet, so it is the safe test before a reboot. The last command shows `/mnt/nfs` with source `server:/nfs/share` and type `nfs4` (the client picks version 4 when the server offers it). If `findmnt` prints nothing, the mount did not happen: read the error that `mount -a` printed.

## Mounting only when someone knocks

An fstab option can turn the mount into an on-demand mount. `x-systemd.automount` makes systemd create an `.automount` unit, a docking robot for that one hatch. The mount happens when a program first enters the path. `x-systemd.idle-timeout=60` undocks it after 60 seconds without use.

Change the options in the line to this (edit the same line):

```text
server:/nfs/share  /mnt/nfs  nfs  _netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=60  0  0
```

Apply it and check what systemd made:

```sh
sudo systemctl daemon-reload
sudo systemctl start mnt-nfs.automount
systemctl status mnt-nfs.automount
```

`systemd` turned the fstab line into the unit `mnt-nfs.automount` (the path `/mnt/nfs` becomes `mnt-nfs`). Before anyone touches `/mnt/nfs`, `findmnt /mnt/nfs` shows type `autofs`. After `ls /mnt/nfs`, it shows `nfs4`. A mount that happens on demand also means a silent server cannot block the boot at all.

## Common pitfalls

> [!WARNING]
> - **Putting a hand-typed `mount` in a startup script instead of `/etc/fstab`.** It runs once, in the wrong order, and nobody checks it.
> - **Leaving out `_netdev`.** systemd can try the mount before the network is up.
> - **Leaving out `nofail` on a remote mount.** A server that is down at launch can stop the boot in emergency mode.
> - **Rebooting to test.** Run `sudo findmnt --verify` and `sudo mount -a` first. A mistake then costs seconds, not a reboot.
> - **Writing a space in the options.** The options field ends at the first space. Separate options with commas only.
