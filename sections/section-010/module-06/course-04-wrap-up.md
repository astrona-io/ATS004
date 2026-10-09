# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the duty orders that dock cargo holds on a systemd ship: `.mount` units, `.automount` units, and the fstab lines that become them.

**From [How /etc/fstab Becomes systemd Units](./course-01-fstab-generated-units-and-naming.md):**

- Every mount is a systemd unit. `systemctl list-units --type=mount` lists them, and the root filesystem is `-.mount`.
- `systemd-fstab-generator` runs early in boot and on every `systemctl daemon-reload`. It writes one `.mount` unit per `/etc/fstab` line into `/run/systemd/generator/`.
- `/run/` is wiped at every reboot, so an edit to a generated unit is lost. Change `/etc/fstab` or write your own unit in `/etc/systemd/system/`.
- systemd loads the first file with a unit's name that it finds. `/etc/systemd/system/` comes before `/run/systemd/generator/`, so a hand-written unit wins.
- A mount unit's filename is its path, escaped: `/srv/data` is `srv-data.mount`. `systemd-escape -p --suffix=mount` works it out.

**From [Writing Native .mount and .automount Units](./course-02-native-mount-and-automount-units.md):**

- A `.mount` unit's `[Mount]` section holds `What=`, `Where=`, `Type=` and `Options=`, the same facts as an fstab line.
- `daemon-reload` reads unit files again, `enable` creates the boot link from `[Install]`, and `start` mounts now. `enable --now` does both of the last two.
- An `.automount` unit with the same base name watches the mount point and starts the `.mount` on first access. `TimeoutIdleSec=` unmounts it again when idle.
- Enable the `.automount`, not the `.mount`. Before access, `findmnt` shows `autofs`; after access, the real filesystem type.

**From [The fstab Shortcut and Common Pitfalls](./course-03-fstab-shortcut-and-pitfalls.md):**

- `x-systemd.automount` and `x-systemd.idle-timeout=30` on an fstab line make the generator write the `.automount` unit for you.
- An fstab line and a hand-written unit for the same path do not merge. The hand-written unit wins, and the fstab options are never read.
- systemd automount has no wildcards and no map files. For many similar mounts, autofs is still the tool.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [systemd .mount and .automount Units](./labs/lab-01/README.md) | Writing Native .mount and .automount Units | write a `.mount` and an `.automount` unit for `/srv/appdata`, enable the automount, and trigger an ext4 mount by accessing the path |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You edit the unit file in <code>/run/systemd/generator/</code> for one of your fstab mounts. When is your change lost?</summary>

At the next boot or the next `systemctl daemon-reload`. The generator writes the file again from `/etc/fstab` each time, and `/run/` is wiped at every reboot. Change `/etc/fstab` instead, or write your own unit in `/etc/systemd/system/`.
</details>

<details>
<summary>2. What must the unit file for the mount point <code>/srv/app/logs</code> be called?</summary>

`srv-app-logs.mount`, with `Where=/srv/app/logs` inside it. `systemd-escape -p --suffix=mount /srv/app/logs` prints the name.
</details>

<details>
<summary>3. You change <code>Options=</code> in a mount unit and run <code>systemctl restart</code>. Nothing changes. Why?</summary>

`restart` reuses the copy of the unit that systemd holds in memory. Run `sudo systemctl daemon-reload` first, so systemd reads the file from disk again.
</details>

<details>
<summary>4. You want <code>/srv/data</code> mounted only when someone uses it. Which unit do you enable?</summary>

The `.automount` unit, `srv-data.automount`. Enabling `srv-data.mount` would mount it at every boot, whether anyone needs it or not.
</details>

<details>
<summary>5. Before anyone touches <code>/srv/data</code>, <code>findmnt</code> shows the type <code>autofs</code>. Is something wrong?</summary>

No. That is the automount trigger that systemd placed on the mount point. The first access starts `srv-data.mount`, and then `findmnt` shows the real type, such as ext4.
</details>

<details>
<summary>6. <code>/srv/data2</code> has an fstab line with <code>x-systemd.automount</code> and also a hand-written <code>/etc/systemd/system/srv-data2.mount</code>. Which one does systemd use?</summary>

The hand-written unit. systemd searches `/etc/systemd/system/` before `/run/systemd/generator/` and stops at the first match, so the unit the generator wrote from the fstab line is never loaded.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-010-module-06-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-016
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission; it always starts clean, so nothing you broke carries over.
