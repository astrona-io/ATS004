# Enterprise Sharing with NFS

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-020/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-020/module-02/playground
> astrona destroy section-020-module-02-playground
> ```

Where SSHFS is a quick personal courier, NFS (Network File System) is the standing infrastructure: a kernel-level protocol built to serve the same directories to many clients at once, continuously, at high throughput. It is what backs shared home directories, application data volumes, and content stores across a fleet of servers.

This module covers the two halves of an NFS setup — declaring a share on the server with `/etc/exports`, and mounting it safely on a client — plus the options on each side that decide who gets in, how durable writes are, and what happens to the client if the server disappears.

## How this module is organised

1. **[Client-Server Model & Exports](./course-01-client-server-and-exports.md)** — the RPC machinery (`rpcbind`, `nfsd`, `rpc.mountd`) behind NFS, writing `/etc/exports`, and applying it with `exportfs`.
2. **[Mounting, Read-Only & a Down Server](./course-02-mounting-readonly-and-server-down.md)** — discovering and mounting an export, what `ro` actually enforces and where, and the `hard`/`soft` choice for a server that stops responding. A graded mission ends this part.
3. **[Persistent NFS Mounts](./course-03-persistent-nfs-mounts.md)** — an `/etc/fstab` line for NFS, the `_netdev`, `nofail` and `x-systemd.automount` options, and how to test before a reboot.
4. **[Troubleshooting NFS](./course-04-troubleshooting-nfs.md)** — one command for each place a mount can fail: the export table, the RPC signals, and the options in use. A graded mission ends this part.
5. **[Wrap-Up: Mission Debrief](./course-05-wrap-up.md)** — a recap, a self-check, and how to land the playground.

## Learning objectives

After this module you can:

- Name the three RPC daemons behind NFS (`rpcbind`, `nfsd`, `rpc.mountd`) and what each one does.
- Write an `/etc/exports` entry and explain the `ro`/`rw`, `sync`/`async`, and `no_subtree_check` options.
- Apply exports changes with `exportfs -arv` and inspect the active table with `exportfs -v`.
- Query a server's available exports with `showmount -e` and mount one with `mount -t nfs`.
- Explain the difference between a `hard` and a `soft` NFS mount, why `soft` is only safe for read-only mounts, and when each is appropriate.
- Describe why `intr` is obsolete and what to use instead for responsiveness.
- Write an `/etc/fstab` entry for an NFS mount with `_netdev` and `nofail`, and test it with `findmnt --verify` and `mount -a`.
- Find why an NFS mount fails with `exportfs -v`, `rpcinfo -p` and `nfsstat -m`, and explain `root_squash`.

## Before you start

You should know how to mount and unmount a filesystem and read command output.

The linked playground gives you two VMs on a private `10.10.20.0/24` network: `server` (10.10.20.10), where `nfs-kernel-server` is already running and `/nfs/share` holds `report.txt` and `notes.txt`, and `client` (10.10.20.5), where `nfs-common` and `showmount` are installed and `/mnt/nfs` exists. `/etc/exports` on `server` starts **empty** — you write the export line yourself in the first hands-on step. Each VM resolves the other's name from `/etc/hosts`. Reach the environment with `astrona ssh astro-section-020-module-02-playground` and choose `server` or `client` when prompted; run each command block on the VM named in its heading.

<!-- curriculum-practice -->
## Practice and assessment

- [NFS Enterprise Network Sharing Lab](labs/lab-01/question.md): Export /var/nfs/public to all clients in /etc/exports and reload the export table; Mount the export from 127.0.0.1 at /mnt/nfs-share over NFS; Prove the mount is read-only by showing that writing to it fails.
- [Persistent Remote Mounts and NFS Repair Lab](labs/lab-02/question.md): Add persistent NFS and SSHFS lines to /etc/fstab with _netdev and nofail; Repair the export so the NFS mount is accepted and mounts read-only; Prove both mounts come back with mount -a.
- [iSCSI Disk on a Remote Server Lab](../module-03/labs/lab-01/question.md): Discover and log in to an iSCSI target and find the new disk by its by-path name; Create an ext4 filesystem on the iSCSI disk and mount it at /mnt/cargo; Add a UUID= fstab line with _netdev and set node.startup to automatic.
- [Remote Filesystems: SSHFS and NFS Capstone Lab](../capstone/labs/lab-01/question.md): Mount app-srv1:/data-export on terminal with sshfs, read-write and with allow_other; Export /nfs/share from terminal read-only to the 10.10.40.0/24 network; Mount terminal:/nfs/share read-only at /nfs/terminal/share on app-srv1.
