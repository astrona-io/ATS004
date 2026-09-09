# Part 3 — The fstab Shortcut and Common Pitfalls

> Prerequisite: [Part 2 — Writing Native .mount and .automount Units](./course-02-native-mount-and-automount-units.md). Next: [Section 010 Knowledge Check](../quiz.md).

Part 2 hand-wrote two units — a `.mount` and a paired `.automount` — to get on-demand mounting. This part gets the same result from a single `/etc/fstab` line, using the `x-systemd.*` options the generator (Part 1) understands, then closes the module with the mistakes that trip people up across all three parts.

## `x-systemd.*`: fstab options that drive the generator

You rarely need to hand-write automount units. `x-systemd.*` options in an `/etc/fstab` line tell `systemd-fstab-generator` to build the `.automount` and its dependencies for you, the same as if you had written the two files from Part 2 by hand:

- `x-systemd.automount` — create a paired `.automount`, mount on first access.
- `x-systemd.idle-timeout=30` — unmount after 30 s idle.
- `x-systemd.device-timeout=10` — give up waiting for the device after 10 s.
- `x-systemd.requires=<unit>` — order this mount after another unit.
- `_netdev` — already covered in Section 015: wait for the network.

> [!TIP]
> **Try it — automount straight from fstab**
>
> ```sh
> sudo systemctl disable --now srv-data.automount
> sudo rm /etc/systemd/system/srv-data.mount /etc/systemd/system/srv-data.automount
> UUID=$(sudo blkid -s UUID -o value /dev/vdb)
> sudo mkdir -p /srv/data2
> echo "UUID=$UUID  /srv/data2  ext4  defaults,nofail,x-systemd.automount,x-systemd.idle-timeout=30  0  2" | sudo tee -a /etc/fstab
> sudo systemctl daemon-reload
> ls /srv/data2
> findmnt /srv/data2
> ```
>
> Expect something like:
>
> ```text
> (ls output)
>
> TARGET      SOURCE    FSTYPE OPTIONS
> /srv/data2  /dev/vdb  ext4   rw,relatime,nofail
> ```
>
> One fstab line produced the same on-demand mount as the two unit files from Part 2, and `daemon-reload` was enough to activate it — no `enable` needed, because the *generator* wrote the `[Install]` wiring for you this time. Roll back with `sudo cp /etc/fstab.orig /etc/fstab && sudo systemctl daemon-reload`.

## When an fstab line and a hand-written unit target the same path

Part 1's unit search order answers a question this raises immediately: what if `/srv/data2` had *both* the `x-systemd.automount` fstab line above *and* a hand-written `/etc/systemd/system/srv-data2.mount`? They do not merge. `/etc/systemd/system/` is checked first in the search order, so the hand-written unit wins outright — the generator still writes its version into `/run/systemd/generator/`, but systemd never loads it. The fstab line's options are not "overridden", they are simply never read for that path. This is why the two approaches in this module are alternatives, not layers: pick fstab options for a mount, or hand-written units for it, never both.

## Common pitfalls

- **Unit filename not matching the path.** `/srv/data` *must* be `srv-data.mount` with `Where=/srv/data`. Any mismatch and systemd never associates the file with that path at all. Generate the name with `systemd-escape -p --suffix=mount`.
- **Editing a unit and not reloading.** systemd only re-reads unit files on `daemon-reload` — a plain `restart` reuses what was already loaded in memory. Run `sudo systemctl daemon-reload` after every create or edit, including changes to `/etc/fstab`.
- **Enabling the `.mount` instead of the `.automount`.** For on-demand behaviour, enable and start the `.automount`; leave the `.mount` to be triggered. Enabling the `.mount` mounts it unconditionally at boot instead.
- **Assuming systemd automount replaces autofs.** It has no wildcards, no map files, no LDAP/NIS maps. For many similar mounts (user home directories, per-host maps) autofs (Section 050) is still the tool; for a handful of fixed mounts, `x-systemd.automount` is simpler.
- **Leaving `nofail` off a `.mount` unit.** Same rule as fstab — a required-but-missing device fails the unit, and anything ordered `After=` it may not start.
- **Writing both an fstab line and a hand-written unit for one mount point.** They do not combine. `/etc/systemd/system/` always wins the search, so the fstab options for that path are silently unused — confusing to debug later, since nothing errors.

> *`x-systemd.*` options don't change what fstab does — they change what the generator writes, so anything hand-written for the same path always wins over them.*

## Reference

- `man 5 fstab` — the `x-systemd.*` option list and their generator-facing meaning.
- `man systemd-fstab-generator` — how these options translate into generated `.automount` units.
- `man systemd.automount` — the automount unit's own directives, for comparing against the fstab-option shortcut.
