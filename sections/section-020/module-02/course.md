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

## Learning objectives

After this module you can:

- Write an `/etc/exports` entry and explain the `ro`/`rw`, `sync`/`async`, and `no_subtree_check` options.
- Apply exports changes with `exportfs -arv` and inspect the active table with `exportfs -v`.
- Query a server's available exports with `showmount -e` and mount one with `mount -t nfs`.
- Explain the difference between a `hard` and a `soft` NFS mount and when each is appropriate.
- Describe why `intr` is obsolete and what to use instead for responsiveness.

## Before you start

You should know how to mount and unmount a filesystem and read command output; the previous SSHFS module is helpful background but not required.

The linked playground gives you two VMs on a private `10.10.20.0/24` network: `server` (10.10.20.10), where `nfs-kernel-server` is already running and `/nfs/share` holds `report.txt` and `notes.txt`, and `client` (10.10.20.5), where `nfs-common` and `showmount` are installed and `/mnt/nfs` exists. `/etc/exports` on `server` starts **empty** — you write the export line in the checkpoints. Each VM resolves the other's name from `/etc/hosts`. Run each command block on the VM named above it (`astrona ssh server` / `astrona ssh client`).

## The client-server model

> As an analogy: NFS is a warehouse with a loading dock. The warehouse manager posts a list of which bays are open and which delivery companies may use them (`/etc/exports`); a truck that is on the list backs up to a bay and works directly from the shelves (`mount`). The analogy breaks down because an NFS client sees the files as an ordinary part of its own directory tree, not as a separate "remote" place — programs cannot tell the difference.

The server names directories it is willing to share and restricts each to specific clients. A client checks what is on offer, then mounts a share into its own tree. From then on the mounted path behaves like local storage.

## The server side: `/etc/exports`

Each line of `/etc/exports` is one exported path, followed by one or more `client(options)` groups with **no space** between the client and its parenthesised options. A representative line:

```text
/nfs/share   10.10.20.0/24(ro,sync,no_subtree_check)
```

This offers `/nfs/share` to any host in `10.10.20.0/24`, read-only. The options:

- **`ro` / `rw`** — read-only (the default) or read-write. `ro` is the safe choice unless clients genuinely need to write.
- **`sync` / `async`** — with `sync` (the modern default), the server acknowledges a write only after the data is on stable storage, so a server crash cannot silently lose an acknowledged write. `async` replies before the data is durable: faster, but a crash can lose data the client believes was saved.
- **`no_subtree_check`** — when you export a subdirectory of a larger filesystem, subtree checking makes the server verify on each request that the file still sits inside the exported subtree, which breaks awkwardly when files are renamed. `no_subtree_check` disables that. It is the default in current `nfs-utils`; naming it explicitly just documents intent and silences a startup warning.

The server does not re-read `/etc/exports` automatically. Apply changes with `exportfs`:

```sh
sudo exportfs -arv
```

`-a` processes all entries, `-r` re-syncs the running state to the file (adding new exports, dropping removed ones), `-v` prints what happened.

> [!TIP]
> **Try it — declare and apply an export**
>
> On `server`:
>
> ```sh
> echo '/nfs/share  10.10.20.0/24(ro,sync,no_subtree_check)' | sudo tee -a /etc/exports
> sudo exportfs -arv
> sudo exportfs -v
> ```
>
> Expect something like:
>
> ```text
> exporting 10.10.20.0/24:/nfs/share
>
> /nfs/share    10.10.20.0/24(ro,wdelay,root_squash,no_subtree_check,sec=sys,ro,secure,...)
> ```
>
> `exportfs -arv` reports it exported the path; `exportfs -v` then lists it in the active table with the options the server actually applied (it fills in defaults like `root_squash`, which maps a client's root to an unprivileged user).

## The client side: discover, then mount

Before mounting, ask the server what it exports and to whom with `showmount -e <server>`. If your client's address is covered and the path is listed, mount it with the standard `mount` command and `-t nfs`.

> [!TIP]
> **Try it — list the export and mount it**
>
> On `client`:
>
> ```sh
> showmount -e server
> sudo mount -t nfs server:/nfs/share /mnt/nfs
> df -h -t nfs4 -t nfs
> cat /mnt/nfs/report.txt
> ```
>
> Expect something like:
>
> ```text
> Export list for server:
> /nfs/share 10.10.20.0/24
>
> Filesystem            Size  Used Avail Use% Mounted on
> server:/nfs/share      15G  2.1G   12G  15% /mnt/nfs
> shared report from server
> ```
>
> `showmount -e` confirms the export and its allowed network. After `mount`, `/mnt/nfs` is part of the client's own tree — `df` shows it as a filesystem and `cat` reads a file straight from `server`.

## Read-only means read-only

An `ro` export is enforced by the server. A client can mount it, read everything, and cannot create or modify files regardless of local permissions or `sudo`.

> [!TIP]
> **Try it — a write against a read-only export**
>
> On `client`, with `/mnt/nfs` mounted:
>
> ```sh
> sudo touch /mnt/nfs/newfile
> ```
>
> Expect something like:
>
> ```text
> touch: cannot touch '/mnt/nfs/newfile': Read-only file system
> ```
>
> The write is refused at the filesystem level. To allow writes you would change `ro` to `rw` in `/etc/exports` on `server`, re-run `sudo exportfs -arv`, and remount on the client.

## When the server goes away: `hard` vs `soft`

By default an NFS mount is **`hard`**: if the server stops responding, the client retries indefinitely, and any process touching the mount blocks in the kernel until the server returns. Such a process is usually unkillable, even with `kill -9`, because it is stuck in a kernel wait. For data you cannot afford to have written incorrectly, this is the correct behaviour — the operation eventually completes once the server is back, rather than failing half-done.

A **`soft`** mount gives up after `retrans` retries of `timeo` (tenths of a second) each and returns an I/O error to the application instead of hanging. The system stays responsive, but a `soft` mount can let a write fail partway and report success/failure inconsistently, so it is advisable **only for read-only mounts**.

The old `intr` option (make operations interruptible by signals) is obsolete: since Linux 2.6.25 it is a no-op, because the kernel already lets fatal signals break out of NFS waits. Do not rely on it. For a responsive read-only client, use `soft` with a modest `timeo` and `retrans`; otherwise keep the `hard` default.

> [!TIP]
> **Try it — set soft-mount options and read them back**
>
> On `client`:
>
> ```sh
> sudo umount /mnt/nfs
> sudo mount -t nfs -o soft,timeo=30,retrans=2 server:/nfs/share /mnt/nfs
> mount | grep /mnt/nfs
> ```
>
> Expect something like:
>
> ```text
> server:/nfs/share on /mnt/nfs type nfs4 (rw,relatime,vers=4.2,...,soft,...,timeo=30,retrans=2,...)
> ```
>
> The option string now shows `soft`, `timeo=30`, and `retrans=2`. This playground does not sever the network, so you will not see the I/O-error behaviour itself — but with these options a dead `server` would make reads fail after roughly `timeo × retrans` tenths of a second instead of hanging forever.

> [!WARNING]
> **Common pitfalls**
>
> - **A space between the client and its options.** `/nfs/share 10.10.20.0/24 (rw)` (with a space) is parsed as "export to `10.10.20.0/24` with defaults, and also to *any* host with `rw`". Write `10.10.20.0/24(rw)` with no space.
> - **Editing `/etc/exports` and expecting it to take effect.** Nothing happens until `sudo exportfs -arv` (or an NFS server restart). Removing a line likewise needs `-r` to actually withdraw the export.
> - **Using `async` for convenience.** It trades durability for speed; an acknowledged write can vanish in a server crash. Keep `sync` unless you have measured the need and accept the risk.
> - **`soft` on a read-write mount.** A retry timeout during a write can corrupt data or leave the application with an inconsistent view. Use `soft` only for `ro` mounts; use the `hard` default for anything writable.
> - **Reaching for `intr`.** It has done nothing since Linux 2.6.25. Fatal signals already interrupt NFS waits; for responsiveness tune `soft`/`timeo`/`retrans` instead.
