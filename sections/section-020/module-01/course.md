# Ad-Hoc Mounting with SSHFS

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-020/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-020/module-01/playground
> astrona destroy section-020-module-01-playground
> ```

Sometimes you need a remote directory mounted on your machine *right now* — to read a colleague's logs, edit files on a build box, copy data off a server — and setting up a real file server would be overkill. If you can already SSH to the machine, SSHFS lets you mount any directory you can reach over that same SSH connection, with no server-side software to install and no root required on either end.

This module covers how SSHFS works (the FUSE mechanism underneath it), why it is fine for ad-hoc use but poor for heavy workloads, and the mount options that control who on your local machine can see the mounted files.

## Learning objectives

After this module you can:

- Explain what FUSE is and how an SSHFS read turns into an SSH request to the remote host.
- Mount a remote directory with `sshfs` and confirm the mount with `mount`.
- Explain why an SSHFS mount is private to the mounting user by default, and open it up with `-o allow_other`.
- Describe what `-o default_permissions` changes about where file permissions are enforced.
- Unmount an SSHFS filesystem with `umount` or `fusermount -u`.

## Before you start

You should know how to mount and unmount a local filesystem and be comfortable with `sudo` and basic SSH.

The linked playground gives you two VMs on a private network: `client` (where you run every command below, reached with `astrona ssh astro-section-020-module-01-playground` — choose `client` when prompted) and `srv` (a plain SSH host exposing `/srv/logs`). On `client`, `sshfs` and FUSE are installed, `/etc/fuse.conf` already has the `user_allow_other` opt-in, there is a spare local user `bob`, and your **login user on `client` has passwordless SSH to `srv`** (the playground wires this up), so `sshfs srv:...` works with no password and no `sudo`. `~` is your login user's home — for example `/home/ubuntu` — and the bootstrap already created `~/remote` there for you to use as the mount point. `/srv/logs` on `srv` holds `app.log` and `access.log` (world-readable) plus `secret.txt` (mode 600, readable on `srv` only by your login user).

## What SSHFS is for

> As an analogy: SSHFS is a bicycle courier. It is quick to dispatch, needs no loading dock, and uses roads that already exist. It is not a freight line — you would not move a datacentre's worth of data through it. The analogy breaks down because a courier makes one trip, while SSHFS handles every `open`, `read`, and `write` your programs make against the mount, indefinitely.

Concretely: `sshfs alice@db-server:/var/log/app ~/app-logs` makes the remote `/var/log/app` appear at your local `~/app-logs`. Listing, reading, and (if permitted) writing all work through the existing SSH channel. Nothing is installed on `db-server` beyond the SSH server it already runs.

## The FUSE mechanism underneath

Traditionally a filesystem driver is kernel code. A bug in it can crash the whole machine, and only root can load one.

**FUSE** — Filesystem in Userspace — changes that. It is a kernel module that forwards filesystem requests *back out* to an ordinary user-space program. When a program reads a file under a FUSE mount, the kernel does not answer directly; it hands the request to the user-space program that owns that mount and waits for its reply.

SSHFS is one such program. The chain for a single directory listing on `~/app-logs` is:

```text
ls  ->  kernel (VFS)  ->  FUSE  ->  sshfs process  ->  SSH  ->  remote sshd  ->  remote directory
```

and the answer travels back the same way. Because the `sshfs` process runs as a normal user, you can create the mount without root.

> [!TIP]
> **Try it — mount a remote directory and see the FUSE type**
>
> On `client`:
>
> ```sh
> sshfs srv:/srv/logs ~/remote
> mount | grep fuse.sshfs
> ls -l ~/remote
> cat ~/remote/app.log
> ```
>
> Expect something like:
>
> ```text
> srv:/srv/logs on /home/ubuntu/remote type fuse.sshfs (rw,nosuid,nodev,relatime,user_id=1000,group_id=1000)
> -rw-r--r-- 1 root   root   18 Aug 29 12:00 app.log
> -rw-r--r-- 1 root   root   21 Aug 29 12:00 access.log
> -rw------- 1 ubuntu ubuntu 20 Aug 29 12:00 secret.txt
> srv app.log line 1
> ```
>
> The filesystem type is `fuse.sshfs`, not a kernel filesystem like `ext4` or `nfs`. Every `ls` and `cat` you just ran was answered by the local `sshfs` process — running as your login user, no `sudo` anywhere — fetching the data from `srv` over SSH. `ls -l` shows each file's owner as it is *on `srv`*: the two logs belong to `root` there, `secret.txt` to your user.

## Why SSHFS is slow for many small files

Each of those hops crosses the boundary between user space and kernel space — a **context switch** — and then waits for a network round trip to `srv`.

Streaming one large file is fine: the round trips amortise over a lot of data. But an operation like compiling a source tree, which does thousands of tiny `open`/`read`/`close` sequences, pays the context-switch-plus-round-trip cost thousands of times and crawls. Use SSHFS for ad-hoc access and light editing; use NFS (the next module) or a local copy for anything throughput-sensitive.

## Who can see the mount: `allow_other`

By default a FUSE mount is readable only by the user who created it. You ran `sshfs`, so only you can enter `~/remote`; every other local user, including `bob`, gets "Permission denied" from the kernel — even for a harmless directory listing. This is a deliberate safety default — it stops one user from exposing another user's remote credentials' reach.

To let other local users and service accounts into the mount, add `-o allow_other`. On most systems this also requires a one-time root opt-in: the line `user_allow_other` in `/etc/fuse.conf` (already set in the playground).

> [!TIP]
> **Try it — the private-by-default rule, then open it up**
>
> On `client`, with the mount from the previous checkpoint still active:
>
> ```sh
> sudo -u bob ls ~/remote
> fusermount -u ~/remote
> sshfs -o allow_other srv:/srv/logs ~/remote
> sudo -u bob ls ~/remote
> ```
>
> (`~/remote` expands to your login user's home before `sudo` runs, so `bob` is being pointed at *your* mount point.)
>
> Expect something like:
>
> ```text
> ls: cannot access '/home/ubuntu/remote': Permission denied
>
> (after remounting with allow_other:)
> access.log  app.log  secret.txt
> ```
>
> As user `bob`, the first `ls` fails even though the directory listing itself is harmless — the mount is private to you, the user who ran `sshfs`. After remounting with `-o allow_other`, `bob` can list it. The `mount` line now includes `allow_other` in its options.

## Where permissions are enforced: `default_permissions`

There is a subtlety in *how* access is checked. Without `default_permissions`, the local kernel does **not** consult each file's mode; it only gated the mount as a whole (that is what `allow_other` relaxed). The `sshfs` process then reads whatever the remote server lets *it* read — and it connects to `srv` as whoever ran `sshfs`, here your login user.

So with `-o allow_other` alone, local user `bob` reading `secret.txt` succeeds: the local kernel does not check the `600` mode, and the `sshfs` process is connected to `srv` as your login user, who *owns* `secret.txt` there and *can* read it.

Adding `-o default_permissions` tells the local kernel to enforce the file modes it sees before the request ever reaches `sshfs`. Now `bob` reading a `600` file owned by your user is denied locally, matching what you would expect from the permission bits.

> [!TIP]
> **Try it — flip where the check happens**
>
> On `client`:
>
> ```sh
> sudo -u bob cat ~/remote/secret.txt
> fusermount -u ~/remote
> sshfs -o allow_other,default_permissions srv:/srv/logs ~/remote
> sudo -u bob cat ~/remote/secret.txt
> ```
>
> Expect something like:
>
> ```text
> credentials: hunter2
>
> (after remounting with default_permissions:)
> cat: /home/ubuntu/remote/secret.txt: Permission denied
> ```
>
> Same file, same user, opposite result. Without `default_permissions` the `600` mode was never checked locally and the `sshfs` process — connected to `srv` as your login user, which owns the file there — happily read it for `bob`. With `default_permissions`, the local kernel applied the mode and stopped `bob` first.

## Unmounting

You mounted as your normal user, so detach it with the FUSE-specific unmount, which does not need root:

```sh
fusermount -u ~/remote
```

`umount` works too, but as a system call it needs root:

```sh
sudo umount ~/remote
```

Either way, a "target is busy" error means something still has the mount open — the same diagnosis (`lsof +D`, `fuser -mv`, `cd` out of the directory) as for a local disk applies.

> [!WARNING]
> **Common pitfalls**
>
> - **Expecting others to see your mount.** A FUSE mount is private to the mounting user unless you pass `-o allow_other` *and* `/etc/fuse.conf` contains `user_allow_other`. Missing either one keeps everyone else locked out.
> - **Assuming `allow_other` also enforces file permissions.** It does not. Without `default_permissions`, the local kernel skips per-file mode checks and the `sshfs` process's own remote access decides what is readable. Add `default_permissions` when you want the mode bits honoured locally.
> - **Using SSHFS for build trees or databases.** The per-operation context switch plus network round trip makes many-small-file workloads extremely slow. It is an ad-hoc tool.
> - **Reaching for `sudo umount` out of habit.** These mounts are non-root; `fusermount -u <dir>` takes them down without `sudo`. `umount` still works but needs root.
> - **Leaving stale mounts after the remote host goes away.** If `srv` disappears, the mount can hang on access. Unmount it (`fusermount -u`, add `-z` for a lazy detach if it resists) rather than leaving processes stuck on it.
