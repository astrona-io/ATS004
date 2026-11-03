# Making a Swap File Survive a Reboot

A swap file that you switch on with `swapon` is gone at the next launch. The ship's logbook, `/etc/fstab`, is what brings it back. The exam checks this: the swap must be active after a restart, not only right now.

## The swap line in /etc/fstab

Every fstab line has six fields. For a swap file they look like this:

```text
/swapfile  none  swap  sw  0  0
```

- **device**: the path of the file, `/swapfile`. A swap partition would use `UUID=` here, but a file is named by its path.
- **mount point**: `none`. Swap is not docked into the directory tree.
- **type**: `swap`.
- **options**: `sw`, the usual placeholder for "swap with defaults".
- **dump and pass**: `0` and `0`. Neither backup nor `fsck` applies to swap.

When the ship launches, systemd turns each swap line into a swap unit and starts it. You do not need any other file.

## Proving it before you reboot

Do not reboot to find out whether the line works. Switch all swap off, then ask the system to read the logbook and switch on everything it lists. `swapoff -a` stops every swap area. `swapon -a` starts every swap line in `/etc/fstab` that is not active yet. If the line is wrong, `swapon -a` tells you now.

<!-- astrona:playground:renew -->

### See it in your playground

The commands below need `/swapfile` to exist as a formatted swap file. If you removed it earlier, build it again and leave it switched off:

```sh
sudo fallocate -l 512M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
```

Add the line to the logbook with a one-line append, and look at it:

```sh
echo '/swapfile  none  swap  sw  0  0' | sudo tee -a /etc/fstab
grep swapfile /etc/fstab
```

Now run the safe check:

```sh
sudo swapoff -a
sudo swapon -a
swapon --show
```

`swapon --show` lists `/swapfile` as a `file` of 512M, although you never ran `swapon /swapfile` yourself. `swapon -a` found the line in `/etc/fstab` and started the swap. That is the same thing the system does at launch.

> [!TIP]
> Make `swapoff -a` followed by `swapon -a` your habit after every swap edit in `/etc/fstab`. It proves the line in seconds, and it catches a typo while the machine is still running.

## Common pitfalls

> [!WARNING]
> - **Editing `/etc/fstab` and never testing it.** A typo shows up at the next reboot. Run `sudo swapoff -a` and `sudo swapon -a` right away.
> - **Adding the line before the file is formatted.** `swapon -a` cannot use a file without a swap header. Run `mkswap` first.
> - **Forgetting `chmod 600`.** The line works either way, but the file would then be readable by every user.
> - **Writing the line twice.** Two lines for the same file make `swapon -a` complain that the area is already in use. Check with `grep swapfile /etc/fstab`.
> - **Using `swapon /swapfile` and calling it done.** That only lasts until the next launch.

## Your mission: Swap File Allocation & Security

You can now allocate, secure, format, activate and persist a swap file. The mission asks you to do all of that on a fresh ship, from scratch, and leave a swap file that survives a reboot.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-040-module-01-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-040/module-01/labs/lab-01
astrona ssh ats-004-lab-041
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-040/module-01/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-041
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-040/module-01/playground
```
