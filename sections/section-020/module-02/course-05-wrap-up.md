# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about holds that live on another ship: sharing a directory with NFS, docking to it, and keeping the dock after a launch.

**From [Client-Server Model & Exports](./course-01-client-server-and-exports.md):**

- NFS is RPC: `rpcbind` lists services, `nfsd` serves data, and `rpc.mountd` handles the mount handshake.
- A line in `/etc/exports` is `path client(options)` with no space before the bracket. `exportfs -arv` loads it into the kernel table, and `exportfs -v` shows what is active.
- `ro`/`rw` and `sync`/`async` decide who may write and how safe a write is.

**From [Mounting, Read-Only & a Down Server](./course-02-mounting-readonly-and-server-down.md):**

- `showmount -e` lists exports, and `mount -t nfs server:/path /mnt/nfs` docks one.
- A read-only export is enforced by the server.
- `hard` retries forever and is right for writes. `soft` gives up and is only for read-only data.

**From [Persistent NFS Mounts](./course-03-persistent-nfs-mounts.md):**

- An NFS fstab line starts with `server:/path` and uses type `nfs`.
- `_netdev` waits for the network, `nofail` keeps the boot going, and `x-systemd.automount` mounts on first use.
- Test with `findmnt --verify` and `mount -a` before any reboot.

**From [Troubleshooting NFS](./course-04-troubleshooting-nfs.md):**

- Check the export table with `exportfs -v`, the signals with `rpcinfo -p server`, and the real mount options with `nfsstat -m`.
- `root_squash` maps client `root` to an unprivileged user on the server.

## Your missions

You proved the skills in graded missions, right after the part that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [NFS Enterprise Network Sharing Lab](./labs/lab-01/README.md) | Mounting, Read-Only & a Down Server | export a directory read-only, mount it over NFS, and show that reads work and writes are refused |
| [Persistent Remote Mounts and NFS Repair Lab](./labs/lab-02/README.md) | Troubleshooting NFS | fix a broken export and make an NFS mount and an SSHFS mount come back from `/etc/fstab` |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You edited `/etc/exports`, but clients still cannot mount. What is missing?</summary>

`sudo exportfs -arv`. The kernel export table is only rebuilt when you run it.
</details>

<details>
<summary>2. What does `async` change on an export?</summary>

The server answers a write before the data is safe on disk. A server crash can lose data the client thought was saved.
</details>

<details>
<summary>3. A client writes to a read-write export as `root` and gets 'Permission denied'. Why?</summary>

`root_squash` is the default. It treats the client's `root` as an unprivileged user on the server.
</details>

<details>
<summary>4. Which two options keep a launch safe when an NFS server may be down?</summary>

`_netdev` and `nofail`. Add `x-systemd.automount` to mount only on first use.
</details>

<details>
<summary>5. How do you test a new fstab line without rebooting?</summary>

Run `sudo findmnt --verify`, then `sudo mount -a`, then `findmnt <mount point>`.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-020-module-02-playground
```

If `astrona list` also showed a mission, remove it the same way:

```sh
astrona destroy ats-004-lab-022
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the missions from this module. You can start the playground again at any time with the `astrona run` command from the end of a mission; it always starts clean, so nothing you broke carries over.
