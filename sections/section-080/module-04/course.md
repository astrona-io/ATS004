# Navigating Shortcuts: Symbolic Links & FHS

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-080/module-04/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-04/playground
> astrona destroy section-080-module-04-playground
> ```

The Filesystem Hierarchy Standard (FHS) is why `/etc` holds configuration, `/var` holds changing data, and programs live under `/usr/bin` on every Linux system. Modern distributions also lean heavily on **symbolic links** to keep that layout stable while the real files move around underneath — most visibly, `/bin`, `/sbin`, and `/lib` are now links into `/usr`.

## How this module is organised

1. **[Part 1 — What a Symlink Is & Finding Them](./course-01-what-a-symlink-is-and-finding-them.md)** — the path-substitution mechanism every symlink command in this module comes back to, and locating links with `find -type l`.
2. **[Part 2 — Resolving, du's Blind Spot & Removing Safely](./course-02-resolving-du-and-removing-safely.md)** — following a chain to its absolute target, why `du` treats a symlink as weightless, and the trailing-slash `rm` mistake that destroys a link's target.

## Learning objectives

After this module you can:

- Explain the path-substitution mechanism the kernel performs when it follows a symlink, and locate symlinks in a directory with `find -type l`.
- Resolve a symlink's target with `ls -ld`, `readlink`, `readlink -f`, and `realpath`.
- Explain why `du` reports a symlink as ~0 bytes, in terms of that same substitution mechanism.
- Remove a symlink without touching its target, and explain exactly what a trailing slash changes about path resolution.

## Before you start

You should know basic navigation (`ls`, `cd`), and `du` from the previous module helps but is not required.

The linked playground gives you an Ubuntu server VM with the distro's usrmerge symlinks in place (`/bin`, `/sbin`, `/lib` → `/usr/...`), a sample `/srv/www/active → /srv/releases/v2` to inspect, and a **disposable** `/tmp/rmdemo` (a real directory `real/` plus `link → real`) with a `reset-symlink-demo` command to rebuild it. Run the command blocks in Parts 1–2 in that VM after `astrona ssh section-080-module-04-playground`.
