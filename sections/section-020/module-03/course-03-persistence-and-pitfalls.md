# Making the Disk Come Back After a Restart

The exam checks what survives a restart. A network disk is harder than a local one, because the network must be up before the disk can appear. This part makes the iSCSI disk from the last part come back by itself.

## Why `_netdev` matters

At launch, systemd docks the holds in `/etc/fstab` in order. A local hold is ready at once. A hold on another ship needs the communications array first, and the array is not up yet when the first docking orders run.

The mount option `_netdev` tells systemd: "this device needs the network". systemd then orders the mount after the network is online. Use `nofail` separately when boot should continue if the disk is unavailable. Without it, a boot can hang on a mount that cannot work yet.

## The fstab line

Use the filesystem's `UUID=`, as for every disk. Get it first. These steps assume the disk is logged in and formatted as in the last part:

### See it in your playground

<!-- astrona:playground:renew -->

```sh
sudo blkid /dev/disk/by-path/<ISCSI-DISK-PATH>
```

`blkid` prints the `UUID` of the ext4 filesystem. Now save this line at the end of `/etc/fstab` (a file under `/etc` is edited with `sudo`, for example `sudo nano /etc/fstab`), with your own value for `<UUID>`:

```text
UUID=<UUID> /mnt/cargo ext4 _netdev,nofail 0 2
```

`nofail` lets the launch go on if the disk cannot be reached. Check the file before any restart:

```sh
sudo findmnt --verify
sudo umount /mnt/cargo
sudo mount -a
findmnt /mnt/cargo
```

`findmnt --verify` reads the whole file and reports problems. `umount` then `mount -a` proves that the line alone is enough to dock the hold.

## Logging in automatically

The fstab line cannot work if the login did not happen first. The login is stored in the record that discovery created. Its `node.startup` value says whether the login happens at launch.

```sh
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 | grep node.startup
```

If it shows `manual`, change it:

```sh
sudo iscsiadm -m node -T iqn.2026-01.io.astrona:storage.cargo -p 10.10.60.10 --op update -n node.startup -v automatic
```

At boot, `open-iscsi.service` logs in to the records marked `automatic`, using the `iscsid` daemon. Check both services:

```sh
systemctl is-active iscsid open-iscsi
```

Both should report `active`. A `nofail` mount can finish after SSH becomes available; inspect `systemctl list-jobs` and `systemctl status mnt-cargo.mount` before diagnosing a missing mount. The two settings work as a pair: `automatic` logs in, `_netdev` makes the mount wait for it.

## Common pitfalls

> [!WARNING]
> - An fstab line without `_netdev` for a network disk. It can slow down or hang the launch.
> - Using `/dev/sda` instead of `UUID=` in `/etc/fstab`. The device name can change between launches.
> - Setting only the fstab line. Without `node.startup = automatic` there is no login, so the mount fails at launch.
> - Restarting the machine without running `findmnt --verify` first.

## Your mission: iSCSI Disk on a Remote Server

You can now discover an iSCSI target, log in, format its disk, mount it and make it persistent. The mission asks you to do all of that on a fresh pair of machines, with a target name given to you.

The mission runs on its own pair of training ships. A playground cannot be paused, so remove it first to free memory; it always starts clean again:

```sh
astrona destroy section-020-module-03-playground
```

Then start the mission and connect to it. Choose `client` when asked:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-020/module-03/labs/lab-01
astrona ssh ats-004-lab-100
```

Read the task in [`question.md`](./labs/lab-01/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-03/labs/lab-01
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-100
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-020/module-03/playground
```
