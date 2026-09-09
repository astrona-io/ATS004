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

## How this module is organised

1. **[Part 1 — SSHFS and the FUSE Mechanism](./course-01-sshfs-and-fuse.md)** — what SSHFS is for, and the `/dev/fuse` request/reply relay that lets an unprivileged process serve a filesystem.
2. **[Part 2 — Performance, Sharing & Unmounting](./course-02-performance-sharing-and-unmounting.md)** — why the FUSE relay makes many-small-file workloads slow, the two independent checks (`allow_other`, `default_permissions`) controlling who can read the mount, and how to unmount it.

## Learning objectives

After this module you can:

- Explain what FUSE is and how an SSHFS read becomes a message on `/dev/fuse` and then an SSH request to the remote host.
- Mount a remote directory with `sshfs` and confirm the mount with `mount`.
- Explain why FUSE's per-call relay makes SSHFS slow for many-small-file workloads specifically, not network speed generally.
- Explain why an SSHFS mount is private to the mounting user by default, and open it up with `-o allow_other`.
- Describe what `-o default_permissions` changes about where file permissions are enforced, and why it is a separate setting from `allow_other`.
- Unmount an SSHFS filesystem with `umount` or `fusermount -u`.

## Before you start

You should know how to mount and unmount a local filesystem and be comfortable with `sudo` and basic SSH.

The linked playground gives you two VMs on a private network: `client` (where you run every command below, reached with `astrona ssh astro-section-020-module-01-playground` — choose `client` when prompted) and `srv` (a plain SSH host exposing `/srv/logs`). On `client`, `sshfs` and FUSE are installed, `/etc/fuse.conf` already has the `user_allow_other` opt-in, there is a spare local user `bob`, and your **login user on `client` has passwordless SSH to `srv`** (the playground wires this up), so `sshfs srv:...` works with no password and no `sudo`. `~` is your login user's home — for example `/home/ubuntu` — and the bootstrap already created `~/remote` there for you to use as the mount point. `/srv/logs` on `srv` holds `app.log` and `access.log` (world-readable) plus `secret.txt` (mode 600, readable on `srv` only by your login user). Run the command blocks in Parts 1–2 in that VM.
