# Keeping an SSHFS Mount Alive

An SSHFS mount is only as steady as the secure channel under it. When the channel drops, every call waits for an answer that never comes. This page shows the options that make the channel detect a dead link and reconnect, how a mount can be written into `/etc/fstab`, and how to find out what is wrong when a mount hangs.

## Why a mount hangs

An `sshfs` mount depends on one running crew member: the `sshfs` process and its SSH connection to the other ship. If the network between the ships breaks, the SSH connection does not notice at once. The kernel keeps waiting for a reply from `/dev/fuse`, and every program that touches the mount waits with it.

Two SSH settings fix that. `ServerAliveInterval` makes the client send a small "are you there?" signal every given number of seconds. `ServerAliveCountMax` says how many unanswered signals the client accepts before it drops the connection. The `sshfs` option `reconnect` tells `sshfs` to open a new connection after a drop instead of leaving the mount dead.

### See it in your playground

Work on `client`. Mount the share with the keep-alive options, then confirm the mount and look at the process that serves it:

<!-- astrona:playground:renew -->

```sh
sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 srv:/srv/logs ~/remote
findmnt -t fuse.sshfs
pgrep -a sshfs
```

`findmnt` lists one `fuse.sshfs` mount with `srv:/srv/logs` as the source and `~/remote` (shown as your home path) as the target. `pgrep -a` prints the `sshfs` process and the command line it was started with. That process is the crew member that serves every request. If you stop it, the mount stops answering.

## Writing the mount into `/etc/fstab`

For a mount that should come back at every launch, `/etc/fstab` can hold an SSHFS line. The device field is `user@host:/path`, and the type is `fuse.sshfs`. The `_netdev` option tells systemd that the mount needs the network first.

The mount is made by `root` at boot, so it uses root's SSH key, not yours. Name a key file that root can read with the `IdentityFile=` option, and use absolute paths. An absolute path is needed because `~` means a different home for `root`.

Save this line at the end of `/etc/fstab` (use `sudo nano /etc/fstab`; a file under `/etc` is saved with `sudo`). Replace `<LOGIN>` with your login name and make sure the key file exists:

```text
<LOGIN>@srv:/srv/logs  /mnt/remote-logs  fuse.sshfs  _netdev,allow_other,reconnect,ServerAliveInterval=15,IdentityFile=/home/<LOGIN>/.ssh/id_ed25519  0  0
```

Create the mount point, then ask systemd to read the new line and check it:

```sh
sudo mkdir -p /mnt/remote-logs
sudo systemctl daemon-reload
sudo findmnt --verify
```

`findmnt --verify` reads `/etc/fstab` and reports problems in the file without mounting anything. Mount it now with `sudo mount /mnt/remote-logs`, then check with `findmnt /mnt/remote-logs`. The first connection also needs root to trust the host key of `srv`. If `root` has never connected, the mount waits for a yes or no answer that nobody can give at boot.

## Taking down a stuck mount

When `srv` is gone, a plain `fusermount -u` can fail with "target is busy" because programs still wait on the mount. A lazy unmount detaches the mount from the tree at once and cleans up when the last user leaves:

```sh
fusermount -u -z ~/remote
```

The same switch works for `sudo umount -l /mnt/remote-logs` on a mount that `root` made. Use it for a dead mount, not as a habit: a healthy mount should be unmounted the plain way.

## Common pitfalls

> [!WARNING]
> - **Testing a mount with your own key and expecting boot to work.** At boot, `root` makes the mount. Root needs a readable key file named with `IdentityFile=`, and a known host key.
> - **Leaving out `_netdev`.** systemd may try the mount before the network is up, and the boot waits or the mount fails.
> - **Using `~` in `/etc/fstab`.** The file is not read by your shell. Write the full path, such as `/home/<LOGIN>/.ssh/id_ed25519`.
> - **Trusting `reconnect` for open files.** After a reconnect, programs that held files open can still get errors. The option saves the mount, not the work in progress.
> - **Using `-z` on a healthy mount.** It hides problems. Use it when the other ship is truly gone.
