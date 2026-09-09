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

1. **[Part 1 — Client-Server Model & Exports](./course-01-client-server-and-exports.md)** — the RPC machinery (`rpcbind`, `nfsd`, `rpc.mountd`) behind NFS, writing `/etc/exports`, and applying it with `exportfs`.
2. **[Part 2 — Mounting, Read-Only & a Down Server](./course-02-mounting-readonly-and-server-down.md)** — discovering and mounting an export, what `ro` actually enforces and where, and the `hard`/`soft` choice for a server that stops responding.

## Learning objectives

After this module you can:

- Name the three RPC daemons behind NFS (`rpcbind`, `nfsd`, `rpc.mountd`) and what each one does.
- Write an `/etc/exports` entry and explain the `ro`/`rw`, `sync`/`async`, and `no_subtree_check` options.
- Apply exports changes with `exportfs -arv` and inspect the active table with `exportfs -v`.
- Query a server's available exports with `showmount -e` and mount one with `mount -t nfs`.
- Explain the difference between a `hard` and a `soft` NFS mount, why `soft` is only safe for read-only mounts, and when each is appropriate.
- Describe why `intr` is obsolete and what to use instead for responsiveness.

## Before you start

You should know how to mount and unmount a filesystem and read command output; the previous SSHFS module is helpful background but not required.

The linked playground gives you two VMs on a private `10.10.20.0/24` network: `server` (10.10.20.10), where `nfs-kernel-server` is already running and `/nfs/share` holds `report.txt` and `notes.txt`, and `client` (10.10.20.5), where `nfs-common` and `showmount` are installed and `/mnt/nfs` exists. `/etc/exports` on `server` starts **empty** — you write the export line in Part 1's checkpoint. Each VM resolves the other's name from `/etc/hosts`. Reach the environment with `astrona ssh astro-section-020-module-02-playground` and choose `server` or `client` when prompted; run each command block on the VM named in its heading.
