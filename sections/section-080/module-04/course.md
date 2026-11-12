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

## The parts of this module

1. [What a Symlink Is & Finding Them](./course-01-what-a-symlink-is-and-finding-them.md): the path swap the kernel performs, and finding links with `find -type l`.
2. [Creating Links, Hard Links & Dangling Links](./course-02-creating-links-hard-links-and-dangling.md): `ln` and `ln -s`, inode numbers, and what survives a delete.
3. [Resolving, du's Blind Spot & Removing Safely](./course-03-resolving-du-and-removing-safely.md): following a chain, why `du` sees a link as weightless, and removing links without harm.
4. [The Filesystem Hierarchy](./course-04-the-filesystem-hierarchy.md): what each standard directory holds, and the usrmerge on Ubuntu 24.04. A graded mission ends this part.
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.

## Learning objectives

After this module you can:

- Explain the path-substitution mechanism the kernel performs when it follows a symlink, and locate symlinks in a directory with `find -type l`.
- Resolve a symlink's target with `ls -ld`, `readlink`, `readlink -f`, and `realpath`.
- Explain why `du` reports a symlink as ~0 bytes, in terms of that same substitution mechanism.
- Create hard links and symlinks, and say what survives when the original name is deleted.
- Remove a symlink without touching its target, and explain what a trailing slash or a glob changes about path resolution.
- Name what the standard directories (`/etc`, `/var`, `/usr`, `/opt`, `/srv`, `/home`, `/tmp`, `/run`, `/boot`) hold.

## Before you start

You should know basic navigation (`ls`, `cd`).

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`. It has the distro's usrmerge symlinks in place (`/bin`, `/sbin`, `/lib` → `/usr/...`), a sample `/srv/www/active → /srv/releases/v2` to inspect, and a **disposable** `/tmp/rmdemo` (a real directory `real/` plus `link → real`) with a `reset-symlink-demo` command to rebuild it. Start the playground and connect to it with `astrona ssh section-080-module-04-playground`. Run every command in the parts in that shell.

<!-- curriculum-practice -->
## Practice and assessment

- [Navigating Shortcuts: Symbolic Links Lab](labs/lab-01/question.md): Find every symbolic link under /usr/share/lab-links and read its target with readlink; Record the links that point into /etc/alternative or /opt/target, sorted, in symlink_report.txt.
- [Place Files by FHS and Link Them Lab](labs/lab-02/question.md): Move files to the directories the Filesystem Hierarchy Standard names for them; Make a hard link and prove it shares the inode; Make symbolic links that point to the right targets.
- [Filesystem Hierarchy and Directory Sizing Capstone Lab](../capstone/labs/lab-01/question.md): Write a size report of every top-level directory under / sorted largest first, excluding pseudo-filesystems; Keep du on one filesystem so the large mount under /mnt is not counted; List each top-level directory that is a symlink, with its target, in symlinks.txt.
