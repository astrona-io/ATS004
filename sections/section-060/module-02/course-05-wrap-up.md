# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the core's control panel: `/sys` for devices, and `/proc/sys` with `sysctl` for the dials of the kernel.

**From [The Hardware Tree & the Mount List](./course-01-hardware-tree-and-mount-list.md):**

- `/sys` shows the kernel's device model. Each attribute has a `show` function, and a `store` function only when the file is a control.
- `/proc/mounts` is generated from the kernel's live mount list, and `/etc/mtab` is a symlink to it.

**From [Block Queue Attributes & udev Rules](./course-02-block-queue-attributes-and-udev.md):**

- `/sys/block/<dev>/queue/` holds the `scheduler`, `rotational`, `read_ahead_kb` and `nr_requests` dials of one disk.
- A write to a `/sys` file takes effect at once and is lost at reboot. Use `echo value | sudo tee file`, not `sudo echo value > file`.
- A udev rule in `/etc/udev/rules.d/` replays the write when the device appears.

**From [sysctl: Viewing and Changing Parameters](./course-03-sysctl-viewing-and-changing.md):**

- `sysctl` maps dotted names to `/proc/sys/` paths. It reads and writes the same parameter.
- `sudo sysctl -w name=value` changes the running kernel. `sysctl -a` lists all parameters.

**From [sysctl: Persisting and Precedence](./course-04-sysctl-persisting-and-precedence.md):**

- A file in `/etc/sysctl.d/` is replayed at every boot. `sudo sysctl --system` applies the files the way boot does.
- Files are sorted by name across the directories, and the last value for a key wins. `/etc/sysctl.conf` is read last.
- Bare `sysctl -p` reads only `/etc/sysctl.conf`.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [sysctl IPv4 Forwarding Tuning](./labs/lab-01/README.md) | sysctl: Persisting and Precedence | turn on `net.ipv4.ip_forward` in the running kernel and persist it for the next boot |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why does <code>sudo echo 1 &gt; /proc/sys/net/ipv4/ip_forward</code> fail?</summary>

The shell opens the `>` redirect as your own user before `sudo` starts. Use `sudo sysctl -w net.ipv4.ip_forward=1` or `echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward`.
</details>

<details>
<summary>2. Which path is the same parameter as <code>vm.swappiness</code>?</summary>

`/proc/sys/vm/swappiness`. Dots in the name become slashes in the path.
</details>

<details>
<summary>3. You changed a disk's I/O scheduler through <code>/sys</code>. What happens at the next boot?</summary>

The change is gone. To keep it, replay it with a udev rule in `/etc/udev/rules.d/`.
</details>

<details>
<summary>4. Two files in <code>/etc/sysctl.d/</code>, <code>50-a.conf</code> and <code>60-b.conf</code>, set the same key. Which value wins?</summary>

The value in `60-b.conf`. Files are applied in name order and the last value wins.
</details>

<details>
<summary>5. What does a bare <code>sysctl -p</code> read?</summary>

Only `/etc/sysctl.conf`. Use `sudo sysctl --system` to read the drop-in directories too.
</details>

<details>
<summary>6. Which file is the trusted list of mounted filesystems?</summary>

`/proc/mounts`, the same as `/proc/self/mounts`. `/etc/mtab` is only a symlink to it.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-060-module-02-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-062
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission. It always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
