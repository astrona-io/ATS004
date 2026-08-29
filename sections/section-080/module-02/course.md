# Navigating Shortcuts: Symbolic Links & FHS

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-080/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-02/playground
> astrona destroy section-080-module-02-playground
> ```

The Filesystem Hierarchy Standard (FHS) is why `/etc` holds configuration, `/var` holds changing data, and programs live under `/usr/bin` on every Linux system. Modern distributions also lean heavily on **symbolic links** to keep that layout stable while the real files move around underneath — most visibly, `/bin`, `/sbin`, and `/lib` are now links into `/usr`.

This module covers finding symlinks, resolving where they point, why `du` treats them as weightless, and a specific `rm` mistake with symlinks that destroys data.

## Learning objectives

After this module you can:

- Locate symlinks in a directory with `find -type l`.
- Resolve a symlink's target with `ls -ld`, `readlink`, `readlink -f`, and `realpath`.
- Explain why `du` reports a symlink as ~0 bytes.
- Remove a symlink without touching its target, and explain what a trailing slash changes.

## Before you start

You should know basic navigation (`ls`, `cd`), and `du` from the previous module helps but is not required.

The linked playground gives you an Ubuntu server VM with the distro's usrmerge symlinks in place (`/bin`, `/sbin`, `/lib` → `/usr/...`), a sample `/srv/www/active → /srv/releases/v2` to inspect, and a **disposable** `/tmp/rmdemo` (a real directory `real/` plus `link → real`) with a `reset-symlink-demo` command to rebuild it. Run the command blocks below in that VM after `astrona ssh section-080-module-02-playground`.

## What a symlink is

A **symbolic link** is a small file whose contents are a path. When a program opens the link, the kernel substitutes that path and continues. The link and its target are separate objects: deleting one does not delete the other, and the link can point at something that does not exist (a "dangling" link).

> As an analogy: a symlink is a signpost that reads "Records — this way". Follow it and you reach the records room. Take the signpost down and the room is untouched; move the room and the signpost now points at nothing. The analogy breaks down because a symlink is followed automatically and invisibly — you do not "choose" to follow it the way you choose to follow a sign.

## Finding symlinks

`find <dir> -maxdepth 1 -type l` lists the symlinks directly inside a directory. `-type l` matches links specifically (not the directories or files they point to); `-maxdepth 1` keeps it to that one level. Adding `-ls` prints each with its target.

> [!TIP]
> **Try it — the symlinks at the root**
>
> ```sh
> find / -maxdepth 1 -type l -ls
> ls -ld /bin /sbin /lib
> ```
>
> Expect something like:
>
> ```text
>    12 0 lrwxrwxrwx 1 root root 7 ... /bin -> usr/bin
>    13 0 lrwxrwxrwx 1 root root 8 ... /sbin -> usr/sbin
>    14 0 lrwxrwxrwx 1 root root 7 ... /lib -> usr/lib
>
> lrwxrwxrwx 1 root root 7 ... /bin -> usr/bin
> ```
>
> `/bin`, `/sbin`, and `/lib` are not directories on this system — they are symlinks into `/usr`. This "usrmerge" keeps decades-old scripts that hard-code `/bin/sh` working while the actual files live in one place under `/usr`.

## Resolving where a link points

Several tools answer "where does this go?", with increasing thoroughness:

- `ls -ld <link>` — shows the target as stored in the link, often a *relative* path (`/bin -> usr/bin`).
- `readlink <link>` — prints just that stored target, nothing else.
- `readlink -f <link>` / `realpath <link>` — follow the chain all the way, including links that point at other links, and print the final **absolute** path.
- `namei -l <path>` — shows every step of resolving a path, link by link, with permissions.

> [!TIP]
> **Try it — raw target versus fully resolved**
>
> ```sh
> readlink /bin
> readlink -f /bin
> realpath /bin
> namei -l /bin/ls
> ```
>
> Expect something like:
>
> ```text
> usr/bin
> /usr/bin
> /usr/bin
> f: /bin/ls
>  dr-xr-xr-x root root /
>  lrwxrwxrwx root root bin -> usr/bin
>  drwxr-xr-x root root   usr
>  drwxr-xr-x root root   bin
>  -rwxr-xr-x root root   ls
> ```
>
> `readlink` alone gives the relative `usr/bin` actually stored in the link; `readlink -f` and `realpath` resolve it to the absolute `/usr/bin`. `namei -l` shows the resolution step where `bin` is followed to `usr/bin` — useful when a path has several links in it.

## `du` and symlinks

A symlink's own size is just the length of the path string it stores — a handful of bytes. `du` does not follow symlinks by default, so measuring a symlinked directory reports essentially nothing.

> [!TIP]
> **Try it — a symlink weighs nothing**
>
> ```sh
> du -sh /bin
> du -sh /usr/bin
> ```
>
> Expect something like:
>
> ```text
> 0       /bin
> 180M    /usr/bin
> ```
>
> `du -sh /bin` reports `0` because `/bin` is a 7-byte link and `du` stops there. The real space is under the target, `/usr/bin`. In a capacity audit this is what you want — otherwise a symlink would make you count the same data twice.

## Removing a symlink safely

To delete a symlink and leave its target alone, name the link with **no trailing slash**:

```sh
rm /tmp/rmdemo/link
```

This removes only the link; `/tmp/rmdemo/real` and its files are untouched. Repointing a link is `ln -sfn <new-target> <link>`.

> [!TIP]
> **Try it — remove the link, keep the data**
>
> ```sh
> reset-symlink-demo
> ls -ld /tmp/rmdemo/link
> rm /tmp/rmdemo/link
> ls /tmp/rmdemo/
> ls /tmp/rmdemo/real/
> ```
>
> Expect something like:
>
> ```text
> rebuilt: /tmp/rmdemo/real (2 files) and /tmp/rmdemo/link -> /tmp/rmdemo/real
> lrwxrwxrwx 1 root root 14 ... /tmp/rmdemo/link -> /tmp/rmdemo/real
> (after rm:)
> real
> a.txt  b.txt
> ```
>
> `link` is gone; `real/` and both files remain. That is the correct way to retire or repoint a symlink.

> [!WARNING]
> **The trailing slash on a symlink is dangerous**
>
> `rm /tmp/rmdemo/link` removes the link. `rm -rf /tmp/rmdemo/link/` — the same path **with a trailing slash** — does not. The slash tells `rm` to resolve the symlink and operate on the **directory it points to**: it deletes the contents of `/tmp/rmdemo/real/` (and, depending on your `rm` version, the `real` directory itself). Shell tab-completion often appends that slash for you.
>
> - Before `rm`-ing a symlink, check what it is and where it points: `ls -ld <path>`.
> - Never let a trailing slash stay on a symlink path you are about to delete.
> - To see your own system's exact behaviour safely, run `reset-symlink-demo`, then `rm -rf /tmp/rmdemo/link/` (with the slash), then `ls /tmp/rmdemo/real/` — and `reset-symlink-demo` again afterwards. Only do this in that disposable directory.
>
> **Other pitfalls**
>
> - **`readlink` without `-f` in a script.** The bare output can be a relative path that only makes sense from the link's own directory. Use `readlink -f` or `realpath` for an absolute path.
> - **Assuming `find -type l` follows the link.** It matches the link itself. `find -L` would make `find` follow links, which is usually not what you want when auditing them.
> - **A dangling symlink.** If the target was moved or deleted, the link remains and points at nothing. `ls -l` shows the target; trying to open it fails with "No such file or directory".
