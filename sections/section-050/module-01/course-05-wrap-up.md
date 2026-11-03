# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the docking robot: `autofs`, its maps, and how to find out what it sees.

**From [How On-Demand Mounting Works, and Enabling autofs](./course-01-mechanism-and-enabling.md):**

- The kernel blocks the first request under a trigger and asks the `automount` daemon to run the mount. Nothing is polled.
- `sudo systemctl enable --now autofs` starts the service and keeps it across launches.

**From [The Master Map, Triggering and Idle Unmount](./course-02-master-map-and-triggering.md):**

- A master line has a managed directory, a map file and options such as `--timeout=15`.
- The master map is read at start or reload. Keys are looked up live. Run `sudo systemctl reload autofs` after changes.
- After the idle timeout the daemon undocks the mount. The trigger stays.

**From [Direct Maps and a Fixed Mount Point](./course-03-direct-maps.md):**

- A direct map uses `/-` in the master line and full paths as keys. Its timeout is an option of the master line.
- A direct entry wins over an indirect one for the same path.

**From [Drop-In Master Files and Debugging autofs](./course-04-drop-ins-and-debugging.md):**

- Files ending in `.autofs` in `/etc/auto.master.d/` act as master lines.
- `automount -m` shows what the daemon loaded. `automount -f -v`, with the service stopped, shows live lookups.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [autofs Direct Maps & Timeouts](./labs/lab-01/README.md) | Direct Maps and a Fixed Mount Point | write a direct map for `/mnt/secure_archive` with a bind mount and a 60 second timeout, with no fstab entry |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You create the directory <code>/mnt/auto/data</code> yourself with <code>mkdir</code>. Why does the mount never happen?</summary>

The path already exists as a normal folder, so the kernel never raises the "not found" that `autofs` needs. Let the daemon create and remove those directories.
</details>

<details>
<summary>2. You edit <code>/etc/auto.demo</code> and nothing changes. What did you forget?</summary>

`sudo systemctl reload autofs`. The daemon keeps the maps in memory and does not watch files.
</details>

<details>
<summary>3. What is different about the first field of a direct map?</summary>

It is the full absolute path of the mount point, and the master line uses `/-`.
</details>

<details>
<summary>4. Where does the timeout of a direct map go?</summary>

On the master line, for example `/-  /etc/auto.direct  --timeout=60`. It applies to every key in that map.
</details>

<details>
<summary>5. How do you see the maps the daemon actually loaded?</summary>

Run `sudo automount -m`. For a live view, stop the service and run `sudo automount -f -v`.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-050-module-01-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-051
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission. It always starts clean.
