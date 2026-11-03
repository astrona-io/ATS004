# What a Symlink Is & Finding Them

Before you touch any symlink command, be exact about what the kernel does when it "follows" a link. Every command in this module is a variation on that one step.

## What a symlink is

A **symbolic link** (symlink) is a small file whose contents are a path, and nothing more. It is a sign on one hatch that points to another hatch. When the kernel resolves a path and meets a symlink, it replaces that part of the path with the stored text and keeps resolving. This happens for every part of a path, not only the last one. If `/a/b/c` has `b` as a link to `/x/y`, the kernel swaps in `/x/y` for `b` and carries on with `/x/y/c`.

The link and its target are two separate objects. Deleting one does not delete the other. The link can even point at something that does not exist, which is called a dangling link. Nothing complains until something tries to follow it.

The kernel follows a link on its own and invisibly. You do not choose to follow it, the way you would choose to follow a sign.

## Finding symlinks

The command `find <dir> -maxdepth 1 -type l` lists the symlinks directly inside a directory. The test `-type l` matches links themselves, not the directories or files they point to. It does not do the swap described above. It looks at the entry's own type, which is why it can find links at all. The option `-maxdepth 1` keeps the search to one level, and `-ls` prints each link with its target.

<!-- astrona:playground:renew -->

### See it in your playground

List the symlinks at the root of the ship:

```sh
find / -maxdepth 1 -type l -ls
ls -ld /bin /sbin /lib
```

Expect something like this:

```text
   12 0 lrwxrwxrwx 1 root root 7 ... /bin -> usr/bin
   13 0 lrwxrwxrwx 1 root root 8 ... /sbin -> usr/sbin
   14 0 lrwxrwxrwx 1 root root 7 ... /lib -> usr/lib

lrwxrwxrwx 1 root root 7 ... /bin -> usr/bin
```

On this system `/bin`, `/sbin` and `/lib` are not directories. They are symlinks into `/usr`. The distribution did this so that old scripts with `/bin/sh` keep working while the real files live in one place. Every reference to `/bin/sh` is swapped to `/usr/bin/sh` while the path is resolved.

Look at the sample release link in the playground too:

```sh
ls -l /srv/www/active
```

It shows `/srv/www/active` pointing at `/srv/releases/v2`. Switching a release means pointing this one link at another directory.

## Common pitfalls

> [!WARNING]
> - **Assuming `find -type l` follows links.** It matches the link itself. The option `-L` makes `find` follow links, which is rarely what you want when you audit the links.
> - **Forgetting `-maxdepth 1`.** Without it, `find /` walks the whole system.
> - **Reading `ls -l` size as the target size.** A link's size is the length of its stored path, a handful of bytes.
