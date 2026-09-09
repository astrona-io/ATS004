# Network Automount Maps & Tuning

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-050/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-050/module-02/playground
> astrona destroy section-050-module-02-playground
> ```

The master map says *which* directory `autofs` watches. The sub-map it points at says *what to mount* when a request comes in. This module covers sub-map syntax — mapping a requested name to a remote NFS export with mount options — the idle unmount in action, and wildcard entries that cover many targets with one line.

## How this module is organised

1. **[Part 1 — Discovering Exports & Writing a Sub-map](./course-01-discovering-and-submap.md)** — querying an NFS server with `showmount -e`, and mapping explicit keys to NFS targets.
2. **[Part 2 — Idle Unmount & Wildcards](./course-02-wildcards-and-idle-unmount.md)** — the NFS idle-timeout unmount, and the `*`/`&` wildcard syntax with its lookup precedence against explicit keys.

## Learning objectives

After this module you can:

- Query an NFS server's exports with `showmount -e`.
- Write a sub-map entry that maps a key to an NFS target with mount options.
- Trigger an on-demand NFS mount and confirm it with `mount`.
- Observe the idle-timeout unmount.
- Write a wildcard sub-map using `*` and `&` to cover many targets with one line, and state which wins when a wildcard and an explicit key could both match.

## Before you start

You need the previous module's material: how `autofs` intercepts access, the `/etc/auto.master` line format, and `systemctl reload autofs`. Familiarity with NFS exports and `mount -t nfs` from Section 020 helps.

The linked playground gives you two VMs on a private network: `client` (where every command in Parts 1–2 runs — `astrona ssh client`) with `autofs` running and `/etc/auto.master` backed up to `/etc/auto.master.orig`, and `nfs` (10.10.50.10) exporting `/export/eng` and `/export/mkt` read-only, each holding one file. `client` resolves `nfs` from `/etc/hosts`.
