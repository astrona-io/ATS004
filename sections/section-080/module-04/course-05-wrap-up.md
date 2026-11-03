# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the signs on the hatches of the ship, and the standard deck plan they help to keep stable.

**From [What a Symlink Is & Finding Them](./course-01-what-a-symlink-is-and-finding-them.md):**

- A symlink is a small file that stores a path. The kernel swaps in that path while it resolves a name.
- `find <dir> -maxdepth 1 -type l -ls` lists links without following them.
- On Ubuntu 24.04, `/bin`, `/sbin` and `/lib` are links into `/usr`.

**From [Creating Links, Hard Links & Dangling Links](./course-02-creating-links-hard-links-and-dangling.md):**

- A hard link is a second name for one inode. A symlink has its own inode and stores a path.
- If you delete the original name, a hard link still works and a symlink dangles.
- `ln -sfn <new target> <link>` repoints a link. `find -xtype l` finds dangling links.

**From [Resolving, du's Blind Spot & Removing Safely](./course-03-resolving-du-and-removing-safely.md):**

- `readlink` shows the stored text. `readlink -f` and `realpath` show the final absolute path. `namei -l` shows each hop.
- `du` does not follow links, so a link weighs almost nothing.
- Remove a link with `rm <link>`. A trailing slash or a glob goes through the link into the target.

**From [The Filesystem Hierarchy](./course-04-the-filesystem-hierarchy.md):**

- `/etc` holds configuration, `/var` changing data, `/usr` programs, `/opt` add-on software, `/srv` served data, `/home` users, `/tmp` temporary files, `/run` runtime data and `/boot` startup files.
- `find -xdev` keeps a search on one filesystem.

## Your missions

You proved the skills in graded missions, right after the parts that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Navigating Shortcuts: Symbolic Links Lab](./labs/lab-01/README.md) | Resolving, du's Blind Spot & Removing Safely | find links, read their targets and record the matching ones in sorted order |
| [Place Files by FHS and Link Them Lab](./labs/lab-02/README.md) | The Filesystem Hierarchy | place files where the standard puts them, and make a hard link and two symbolic links |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You delete <code>original.txt</code>. A hard link and a symlink to it exist. Which one still works?</summary>

The hard link. It is another name for the same inode, so the data stays. The symlink stores the path of the deleted name, so it dangles.
</details>

<details>
<summary>2. What is the difference between <code>readlink</code> and <code>readlink -f</code>?</summary>

`readlink` prints the text stored in the link, which may be relative. `readlink -f` resolves the whole chain and prints the absolute path.
</details>

<details>
<summary>3. Why does <code>du -sh /bin</code> print 0 on Ubuntu 24.04?</summary>

`/bin` is a small link, and `du` does not follow links by default. The data is under `/usr/bin`.
</details>

<details>
<summary>4. What does <code>rm -rf mylink/*</code> do when <code>mylink</code> points to a directory?</summary>

It deletes the files inside the target directory. The shell expands the glob through the link. The link itself stays.
</details>

<details>
<summary>5. Which directory holds logs, and which holds configuration?</summary>

Logs are under `/var/log`. Configuration is under `/etc`.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-080-module-04-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-082
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
