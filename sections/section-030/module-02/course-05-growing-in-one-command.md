# Growing in One Command

Growing a volume takes two steps: make the volume bigger, then make the filesystem know about it. This page shows how one command does both, how to ask for "everything that is left" without doing sums, and why XFS needs its own tool when you do the steps by hand.

## One command for both steps

`lvextend -r` is short for `--resizefs`. After it grows the LV, it calls the right resize tool for the filesystem it finds on it: `resize2fs` for ext4, `xfs_growfs` for XFS. You skip the second command, and you cannot forget it.

```text
sudo lvextend -r -L +100M /dev/company_storage/shared_documents
```

The `+` still matters. `-L +100M` adds 100 MiB. `-L 100M` sets the size to 100 MiB, which for a bigger volume means a shrink.

> As an analogy: `-r` is a loading crew that cuts the bigger bay and updates the inventory sheet in one trip. The analogy breaks down because the crew still needs free crates in the pool. If the pool is empty, `lvextend` stops with an error and changes nothing.

## Asking for a share instead of a size

`-L` takes a size. `-l` (lowercase L) takes extents or a percentage of something. These forms are the useful ones:

- `-l +100%FREE` adds every free extent in the volume group to the volume.
- `-l +50%FREE` adds half of what is free right now.
- `-l 100%VG` sets the volume to the full size of the group (only possible if nothing else uses the pool).

`lvs -o +seg_pe_ranges` afterwards shows which extents the volume now holds, and `vgs` shows `VFree` at zero after `+100%FREE`.

### See it in your playground

The playground starts with the volume group `company_storage` and the ext4 volume `shared_documents`, mounted at `/mnt/shared_documents`. The pool still has free space. First look at the numbers:

<!-- astrona:playground:renew -->

```sh
sudo vgs company_storage
df -h /mnt/shared_documents
```

`VFree` is the room you can still hand out. `df` shows the filesystem size, which is the number the programs see. Now grow the volume by a fixed size, in one command, and look again:

```sh
sudo lvextend -r -L +100M /dev/company_storage/shared_documents
df -h /mnt/shared_documents
```

`df` should now report about 100 MiB more than before, and no extra `resize2fs` was needed. Now hand the whole rest of the pool to the volume:

```sh
sudo lvextend -r -l +100%FREE /dev/company_storage/shared_documents
sudo vgs company_storage
df -h /mnt/shared_documents
```

`VFree` should now read `0`, and `df` shows the biggest size the pool allows. Remember that you cannot shrink an XFS volume later, so use `+100%FREE` on XFS only when you are sure.

## XFS by hand

If you leave out `-r`, you grow XFS in two steps. First `lvextend`, then `xfs_growfs` on the **mount point**, not on the device:

```text
sudo lvextend -L +400M /dev/vg_xfs/lv_xfs
sudo xfs_growfs /mnt/xfs
```

`xfs_growfs` works only while the filesystem is mounted, and it can only grow. There is no `xfs_shrink`. With `-r`, `lvextend` runs `xfs_growfs` for you.

## Common pitfalls

> [!WARNING]
> - **Forgetting the `+`.** `-L 500M` on a 600M volume is a shrink request and can destroy data. Always read the size you typed.
> - **Growing the volume but not the filesystem.** Without `-r`, `df` does not change. Run `resize2fs` (ext4) or `xfs_growfs` (XFS).
> - **Running `xfs_growfs` on the device path.** It needs the mount point.
> - **Using `+100%FREE` without thinking.** It takes all free extents. A later `pvmove` or snapshot then has no room to work.

## Your mission: Persistent LVM Mount and One-Command Grow Lab

You can now grow a volume and its filesystem together with one command. The mission asks you to write a persistent `/etc/fstab` line for a logical volume, then grow it by 300M with `lvextend -r` while it stays mounted.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-030-module-02-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-030/module-02/labs/lab-06
astrona ssh ats-004-lab-030-02-06
```

Read the task in [`question.md`](./labs/lab-06/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-02/labs/lab-06
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-030-02-06
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-030/module-02/playground
```
