# Part 1 — What a Symlink Is & Finding Them

> Prerequisite: [Module landing page](./course.md). Next: [Part 2 — Resolving, du's Blind Spot & Removing Safely](./course-02-resolving-du-and-removing-safely.md).

Before touching any symlink command, it helps to be precise about what the kernel is actually doing when it "follows" one — that mechanism is what the rest of this module keeps coming back to.

## What a symlink is

A **symbolic link** is a small file whose contents are a path — nothing more. It is not a pointer to an inode the way a hard link is; it is a name that, when the kernel resolves a path through it, gets substituted in place and resolution continues from there. That substitution happens for *every* path component the kernel resolves, not just the last one: if `/a/b/c` has `b` as a symlink to `/x/y`, the kernel splices `/x/y` in for `b` and keeps resolving `/x/y/c` — Part 2 comes back to this exact substitution step when it explains what a trailing slash changes.

The link and its target are separate objects: deleting one does not delete the other, and the link can point at something that does not exist (a "dangling" link) with no error until something actually tries to follow it.

> As an analogy: a symlink is a signpost that reads "Records — this way". Follow it and you reach the records room. Take the signpost down and the room is untouched; move the room and the signpost now points at nothing. The analogy breaks down because a symlink is followed automatically and invisibly by the kernel during path resolution — you do not "choose" to follow it the way you choose to follow a sign.

## Finding symlinks

`find <dir> -maxdepth 1 -type l` lists the symlinks directly inside a directory. `-type l` matches links specifically (not the directories or files they point to) — critically, `find -type l` does **not** perform the substitution described above; it inspects each directory entry's own type without following it, which is exactly why it can find links at all instead of silently resolving through them. `-maxdepth 1` keeps it to that one level. Adding `-ls` prints each with its target.

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
> `/bin`, `/sbin`, and `/lib` are not directories on this system — they are symlinks into `/usr`. This "usrmerge" keeps decades-old scripts that hard-code `/bin/sh` working while the actual files live in one place under `/usr`: every reference to `/bin/sh` gets substituted to `/usr/bin/sh` during resolution, transparently, at the mechanism level Part 2 builds on.

> *A symlink is a stored path the kernel splices into resolution at the moment it's reached — `find -type l` is one of the few tools that looks at the link itself instead of letting that splice happen.*

## Reference

- `man 7 symlink` — the kernel's own description of symlink resolution semantics, including the `ELOOP` case for a resolution cycle.
- `man find` — `-type l` versus `-L` (follow links), the distinction Part 2's pitfall list returns to.
