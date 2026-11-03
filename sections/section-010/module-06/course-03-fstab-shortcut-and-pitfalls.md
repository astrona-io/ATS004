# The fstab Shortcut and Common Pitfalls

Astronaut, two hand-written unit files are one way to dock a hold on demand. There is a shorter way: a single line in `/etc/fstab`, the ship's logbook. On this page you get the same on-demand mount from that one line, using `x-systemd.*` options that the fstab generator understands. Then you see why a logbook line and a hand-written unit for the same hatch never mix.

## `x-systemd.*`: fstab options for the generator

`systemd-fstab-generator` is the small program that systemd runs at boot and on every `daemon-reload` to turn each `/etc/fstab` line into a unit. Options that start with `x-systemd.` are notes for that program. They tell it to write an `.automount` unit and extra dependencies for you, just as if you had written the unit files yourself.

### The options that matter

- `x-systemd.automount`: write a paired `.automount` unit, so the hold is mounted on first access.
- `x-systemd.idle-timeout=30`: unmount after 30 seconds with nobody using it.
- `x-systemd.device-timeout=10`: give up waiting for the device after 10 seconds.
- `x-systemd.requires=<unit>`: require another unit, and mount only after it.
- `_netdev`: the filesystem needs the network, so wait for the network before mounting.

### Automount straight from fstab

The spare disk is usually `/dev/vdb`; confirm it with `lsblk`. If you wrote `srv-data.mount` and `srv-data.automount` by hand earlier, remove them first so they do not hold the disk. In a fresh playground these files do not exist, and you can skip these two commands:

<!-- astrona:playground:renew -->

```sh
sudo systemctl disable --now srv-data.automount
sudo rm /etc/systemd/system/srv-data.mount /etc/systemd/system/srv-data.automount
```

Now add one line to `/etc/fstab` for a new mount point, `/srv/data2`, reload, and knock on the hatch:

```sh
UUID=$(sudo blkid -s UUID -o value /dev/vdb)
sudo mkdir -p /srv/data2
echo "UUID=$UUID  /srv/data2  ext4  defaults,nofail,x-systemd.automount,x-systemd.idle-timeout=30  0  2" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
ls /srv/data2
findmnt /srv/data2
```

Expect something like:

```text
(ls output)

TARGET      SOURCE    FSTYPE OPTIONS
/srv/data2  /dev/vdb  ext4   rw,relatime,nofail
```

One logbook line gave the same on-demand mount as the two hand-written unit files. You did not need `enable`, because the generator links the units it writes into the boot order itself.

`daemon-reload` writes the new `srv-data2.automount` unit, but it does not always start it before the next boot. If `findmnt` prints nothing, start the trigger with `sudo systemctl start srv-data2.automount` and run `ls /srv/data2` again. `findmnt` may also list the `systemd-1` `autofs` line next to the ext4 line.

### Roll back

Your playground saved the original logbook as `/etc/fstab.orig`. Put it back and reload:

```sh
sudo cp /etc/fstab.orig /etc/fstab && sudo systemctl daemon-reload
```

## When an fstab line and a hand-written unit target the same path

What if `/srv/data2` had both the `x-systemd.automount` line above and a hand-written `/etc/systemd/system/srv-data2.mount`? The two do not merge.

systemd looks for a unit's filename in a fixed list of directories and loads only the first match. `/etc/systemd/system/` comes before `/run/systemd/generator/`, so the hand-written unit wins outright. The generator still writes its own version into `/run/systemd/generator/`, but systemd never loads it. The options on the fstab line are not "overridden": for that path, they are simply never read.

That is why the two ways in this module are alternatives, not layers. For each mount, pick fstab options or hand-written units, never both.

> *`x-systemd.*` options do not change what fstab does. They change what the generator writes, so anything hand-written for the same path always wins over them.*

## Common pitfalls

> [!WARNING]
> - **Assuming systemd automount replaces autofs.** It has no wildcards, no map files and no maps from a directory service such as LDAP or NIS. For many similar mounts, such as user home directories or one mount per server, autofs (the docking robot with its maps) is still the tool. For a handful of fixed mounts, `x-systemd.automount` is simpler.
> - **Writing both an fstab line and a hand-written unit for one mount point.** They do not combine. `/etc/systemd/system/` always wins the search, so the fstab options for that path go unused. Nothing prints an error, which makes this confusing to debug later.
> - **Forgetting `daemon-reload` after editing `/etc/fstab`.** The generator only reads the file at boot and on `daemon-reload`. Until then, systemd still uses the old units.
