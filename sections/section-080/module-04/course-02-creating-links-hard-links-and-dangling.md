# Creating Links, Hard Links & Dangling Links

A symlink is one of two kinds of link. The other is a hard link, and the two behave very differently when you delete or move things. This part builds both, so you can see the difference in the inode numbers and in what survives a delete.

## Two kinds of link

Remember that a file is a name plus an inode, the cargo tag that holds the owner, the size and the blocks. A **hard link** is a second name for the same inode. A symlink is a new small file that stores a path. Use the cargo picture: a hard link is a second label stuck on the same crate, while a symlink is a sign pointing to the crate's shelf.

- A hard link shares the inode. The inode keeps a link count, and the data stays until the count is zero and no process holds the file open.
- A hard link works only inside one filesystem, and not for directories.
- A symlink has its own inode. It may point to a directory, to another filesystem, or to nothing.

<!-- astrona:playground:renew -->

### See it in your playground

Build a small test area and make one of each link:

```sh
mkdir -p ~/linklab && cd ~/linklab
echo "cargo manifest" > original.txt
ln original.txt hard.txt
ln -s original.txt soft.txt
ls -li
```

In the listing, the first column is the inode number. `original.txt` and `hard.txt` show the same inode number and a link count of 2. `soft.txt` has its own inode number, starts with `l` in the mode, and shows `-> original.txt`.

The command `stat` shows the same facts in detail:

```sh
stat original.txt soft.txt
```

For `original.txt` the output lists `Links: 2`. For `soft.txt` it says the file type is a symbolic link.

## What survives a delete

Remove the original name and see which link still works:

```sh
rm original.txt
cat hard.txt
cat soft.txt
```

The hard link still prints `cargo manifest`, because the inode and its data still have one name. The command on the symlink fails with "No such file or directory". It is now a dangling link: it stores the path `original.txt`, and nothing lives there any more.

Find dangling links with `find`. The test `-xtype l` is true for a link whose target cannot be resolved:

```sh
find ~/linklab -xtype l
```

This lists `soft.txt`.

## Creating and repointing links

The form is `ln -s <target> <link name>`. The target is stored exactly as you type it. A relative target is read from the link's own directory, not from your current directory, which is a common source of dangling links. To repoint an existing link to another target, use `ln -sfn <new target> <link>`. The option `-f` replaces the old link and `-n` stops `ln` from entering a link that points to a directory.

```sh
ln -s /srv/releases/v1 ~/linklab/current
ln -sfn /srv/releases/v2 ~/linklab/current
readlink ~/linklab/current
```

The last command prints `/srv/releases/v2`.

## Common pitfalls

> [!WARNING]
> - **A relative target typed from the wrong directory.** The text is stored as given and read from the link's folder. Use an absolute target when you are unsure.
> - **Trying a hard link across filesystems.** It fails, because an inode number exists only inside one filesystem.
> - **Forgetting `-n` when repointing a link to a directory.** Without it, `ln` can create the new link inside the old target directory.
> - **Thinking a hard link is a copy.** Both names are the same file. Changing one changes the other.
