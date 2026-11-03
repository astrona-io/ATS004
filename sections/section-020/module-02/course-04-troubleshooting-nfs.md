# Troubleshooting NFS

When an NFS mount fails, the cause is almost always in one of three places: the server did not export the path to this client, the signals cannot reach the server, or the options on the two ships disagree. This page gives one command for each place, in the order to try them.

## Is the path exported to this client?

Start on the ship that shares the hold. `sudo exportfs -v` lists the exports the kernel really holds, with the options it applied. If your path is missing, the file `/etc/exports` has not been applied yet, or it has a typo. From `client`, `showmount -e server` shows what the server offers to this client. A path that appears in `exportfs -v` but is not offered to your address means the client part of the line (the `10.10.20.0/24` part) does not match the client's address.

One option explains many surprises: `root_squash`, the default. It maps `root` on the client to an unprivileged user on the server. So `sudo touch /mnt/nfs/file` on the client can fail with "Permission denied" even on a read-write export, because the server treats the client's `root` as nobody.

### See it in your playground

Work on `server`. The export must exist (add it as shown earlier if the table is empty).

<!-- astrona:playground:renew -->

```sh
sudo exportfs -v
sudo exportfs -s
```

Both commands print the active export table. `exportfs -s` prints it in the form of `/etc/exports`, which is handy to compare with the file. The option list on each line shows `root_squash` unless you wrote `no_root_squash`.

## Can the signals reach the server?

NFS speaks RPC, and `rpcbind` is the directory that tells a client which port each service uses. If `rpcbind` or `nfsd` is down, the mount fails with a timeout or "RPC: Program not registered". From `client`, ask the server's directory directly:

```sh
rpcinfo -p server
```

The answer is a table of registered services. A healthy server lists `portmapper`, `nfs` and `mountd`. If `nfs` is missing, the NFS service is not running: on `server`, check `systemctl status nfs-kernel-server`.

## What did the client really mount?

Once mounted, the options in use can differ from the ones you typed, because the client and server negotiate the version and sizes. Two views show the truth:

```sh
nfsstat -m
findmnt -t nfs,nfs4
```

`nfsstat -m` prints, for each NFS mount, the real flags (`vers=`, `hard` or `soft`, `proto=`, `timeo=`, `retrans=`). To force a version, pass `-o vers=4.2` or `-o vers=3` to `mount`. Version 3 needs `rpcbind` and `mountd` as shown above. Version 4 uses a single well-known port, so it also works through simple firewalls.

## Common pitfalls

> [!WARNING]
> - **Debugging on the client only.** Half of the problems live in the server's export table. Look at both ships.
> - **Expecting `root` on the client to be `root` on the server.** `root_squash` changes that on purpose.
> - **Mixing up the export path and the mount path.** The client asks for the path as the server exports it, for example `server:/nfs/share`, and puts it on any local directory.
> - **Forgetting the firewall.** A firewall that blocks the NFS ports looks like a dead server. `rpcinfo -p server` tells you quickly.

## Your mission: Persistent Remote Mounts and NFS Repair Lab

You can now find out why an NFS mount is refused and fix the export list. The mission asks you to repair a broken export and write persistent `/etc/fstab` lines for an NFS mount and an SSHFS mount, then prove that both come back with `mount -a`.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-020-module-02-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-020/module-02/labs/lab-02
astrona ssh ats-004-lab-020-02-02
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-02/labs/lab-02
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-020-02-02
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-020/module-02/playground
```
