# Navigating Shortcuts: Symbolic Links & FHS

Linux organizes files according to the Filesystem Hierarchy Standard (FHS). This standard ensures that binaries live in `/usr/bin`, system configurations in `/etc`, and variable data (like logs and databases) in `/var`. You can log into any Linux distribution and know generally where things are.

However, modern distributions have shifted this layout over time. To maintain compatibility with scripts written 20 years ago, they rely heavily on symbolic links (symlinks).

Think of standard directories as physical inventory shelves. Think of a symlink as a teleporter portal. When you walk into the portal, you instantly arrive at a different physical shelf, even though the sign on the portal says something else.

## Identifying Symlinks

In the root of a modern Linux system, several classic directories are no longer real directories. They are symlinks. You find them using the `find` command, looking specifically for the link type (`l`).

```bash
find / -maxdepth 1 -type l
```

You will see that directories like `/bin` and `/sbin` are actually symlinks. If you try to run `du` against them to see how big they are, it will report 0 bytes, because a teleporter portal weighs nothing.

To see where the portal leads, you resolve the link. The simplest way is to use `ls -ld`.

```bash
ls -ld /bin
```

The output points directly to the target: `lrwxrwxrwx 1 root root 7 /bin -> usr/bin`. This means any script trying to write to `/bin/script.sh` is physically writing to `/usr/bin/script.sh`.

If you need to extract just the target path for use in a script, you use `readlink`.

```bash
readlink -f /bin
```

The `-f` (canonicalize) flag follows the link all the way to its final, absolute physical destination, even if the target is itself another symlink.

## The Trailing Slash Disaster

Symlinks act like directories when you `cd` into them, but they act like files when you modify them. This dual nature causes one of the most common, destructive mistakes in Linux administration.

Imagine you have a symlink at `/var/www/active` pointing to a release folder at `/opt/releases/v2/`.

You want to delete the symlink to point it somewhere else.

If you type this:

```bash
rm -rf /var/www/active
```

You delete the symlink. The portal vanishes. The data at `/opt/releases/v2/` is perfectly safe.

If you type this (perhaps relying on bash autocomplete, which automatically appends a slash):

```bash
rm -rf /var/www/active/
```

You destroy the application. The trailing slash tells the `rm` command, "Do not delete this item. Walk *through* this item into the directory behind it, and delete everything inside." The symlink portal survives, but the physical `/opt/releases/v2/` folder is entirely emptied of all data.

Always verify your paths. Never append a trailing slash to a symlink unless you intend to destroy the target.

## Self-Check and Verification

To prove you understand symbolic links:

1. Create a physical directory named `/tmp/real_data` and put a text file inside it.
2. Create a symlink in your home directory pointing to it: `ln -s /tmp/real_data ~/fake_data`.
3. Run `ls -ld ~/fake_data` to verify the link points to the correct location.
4. Run `readlink -f ~/fake_data` to print the absolute canonical path.
5. Run `rm ~/fake_data` (without a trailing slash) to delete the symlink.
6. Verify the `/tmp/real_data` directory and its contents survived the deletion.
