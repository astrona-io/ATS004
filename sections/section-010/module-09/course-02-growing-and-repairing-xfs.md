# Growing and Repairing XFS

Astronaut, two things will happen to your XFS holds sooner or later: they run out of room, or they are damaged. XFS has one tool for each. `xfs_growfs` adds shelves while the hold is docked. `xfs_repair` fixes damage, but only on a hold that is undocked.

## Grow a mounted XFS filesystem

Growing has two steps, and two different tools do them. First the **device** under the filesystem must become larger. Then `xfs_growfs` makes the filesystem use the new space.

### What gets bigger first

The device can grow in several ways. A partition can be extended, a logical volume can be extended with `lvextend`, or a virtual disk can be resized by the host. Until that happens, the filesystem cannot see any extra room. `xfs_growfs` never changes the device. It only changes the filesystem inside it.

### Run xfs_growfs

In the playground, the spare 2 GB disk (usually `/dev/vdc`) lets you see the idea. Build XFS on it, dock it, and look at its size:

<!-- astrona:playground:renew -->

```sh
sudo mkfs.xfs -L GROWME /dev/vdc
sudo mkdir -p /srv/growme
sudo mount /dev/vdc /srv/growme
df -h /srv/growme
```

The filesystem already fills its device, so there is nothing to grow. When the device has grown, for example after `sudo lvextend -L +1G /dev/vg_data/lv_data` on a logical volume, you run the next command on the mount point, not on the device:

```sh
sudo xfs_growfs /srv/growme
```

`xfs_growfs` reads the new size of the device and adds new allocation groups to the filesystem. It prints the layout before and after, in the same form as `xfs_info`. Run `df -h` again and the size is larger. The hold stays docked and in use the whole time. Growing needs the filesystem to be mounted: XFS grows only while docked.

## Check and repair an XFS filesystem

A filesystem that was damaged by a power cut or a bad disk needs the repair crew. For XFS the crew is `xfs_repair`.

### Why fsck.xfs does nothing

On boot, the system may call `fsck` for each filesystem. For XFS, the helper `fsck.xfs` exists, but it does nothing and exits at once. XFS replays its log at mount time, so a normal crash needs no check. A real repair is something you start on purpose with `xfs_repair`.

### Dry run, then repair

`xfs_repair` must never run on a docked filesystem. Undock the hold first. Then look without touching, using `-n` (no modify):

```sh
sudo umount /srv/growme
sudo xfs_repair -n /dev/vdc
```

`xfs_repair -n` walks every phase of the check, prints each problem it finds, and changes nothing. A clean filesystem passes every phase without complaints. The exit status tells you the result: `0` means no problems were found, and `1` means the filesystem is damaged and needs a real repair. Read it with `echo $?` right after the command.

When the dry run reports damage, run the real repair on the undocked hold:

```sh
sudo xfs_repair /dev/vdc
```

### The last resort: xfs_repair -L

If the log itself is damaged, `xfs_repair` stops and tells you the log cannot be replayed. The usual fix is to mount the filesystem once, so the kernel replays the log, and then unmount and repair again. Only when the mount fails too, the option `-L` zeroes the log. That throws away the log's notebook, and changes that were not yet written to the main tables are lost for good. Treat `-L` as the last resort, never as the first try.

### Change a label or UUID

`xfs_admin` changes the settings of an undocked XFS filesystem. Set a new label, or print the current one:

```sh
sudo xfs_admin -L NEWNAME /dev/vdc
sudo xfs_admin -l /dev/vdc
```

`xfs_admin -U generate /dev/vdc` gives the filesystem a new UUID. After you change a UUID, every `/etc/fstab` line that used the old one must change too.

## Common pitfalls

> [!WARNING]
> - Never run `xfs_repair` on a mounted filesystem. It refuses, and forcing it risks more damage.
> - `xfs_growfs` takes the mount point, not the device.
> - `xfs_growfs` cannot shrink anything. A smaller size is an error.
> - `xfs_repair -L` throws away the log and the changes in it. Try mounting once first.
> - Do not wait for `fsck.xfs` to repair anything. It does nothing.

## Your mission: XFS Create, Mount and Check Lab

You can now build an XFS filesystem, make it dock at every launch and run a safe repair check. The mission asks you to format a blank disk with XFS, mount it by UUID through `/etc/fstab`, and dry-run a repair check on a second, undocked disk.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-010-module-09-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-010/module-09/labs/lab-01
astrona ssh ats-004-lab-092
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-09/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-092
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-010/module-09/playground
```
