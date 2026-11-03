# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the core's live status screens: the files under `/proc`, and what they tell you about the ship, its crew and its disks.

**From [/proc as a Live View & System-wide Files](./course-01-live-view-and-system-wide-files.md):**

- `/proc` is procfs. No disk holds its bytes. Each file is a kernel function that builds fresh text every time you read it.
- That is why `stat` reports 0 bytes and why the numbers are always current.
- `/proc/meminfo`, `/proc/cpuinfo` and `/proc/cmdline` hold the global facts. `free` is only a formatter over `/proc/meminfo`.

**From [Per-Process Directories & Open File Descriptors](./course-02-per-process-and-file-descriptors.md):**

- `/proc/<PID>/` is a view of the kernel's record for one process. It disappears the moment the process exits.
- `cmdline` is null-separated. `exe` and `cwd` are symlinks generated on read.
- `/proc/<PID>/fd/` has one link per open descriptor. Counting the links finds a descriptor leak.

**From [Limits, Status and Storage Counters](./course-03-limits-status-and-storage-counters.md):**

- `/proc/<PID>/limits` holds the per-process open-file cap. `/proc/sys/fs/file-max` is the whole-ship cap, and `file-nr` shows current use.
- `/proc/<PID>/status` gives name, state, parent and memory in readable lines.
- `/proc/diskstats` holds growing disk totals, and `/proc/mounts` is the kernel's own mount list.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [proc System Limits & File Descriptors Auditing](./labs/lab-01/README.md) | Limits, Status and Storage Counters | count the open descriptors of a running service through `/proc/<PID>/fd/` and read the system-wide file limit |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. <code>ls -l</code> shows <code>/proc/meminfo</code> with size 0, yet <code>cat</code> prints text. Why?</summary>

No bytes are stored. The kernel runs a function when you read the file and builds the text on the spot. A size needs stored bytes, so it reports 0.
</details>

<details>
<summary>2. How do you see the command a process was started with, in readable form?</summary>

`cat /proc/<PID>/cmdline | tr '\0' ' '; echo`. The arguments are separated by null bytes, and `tr` turns them into spaces.
</details>

<details>
<summary>3. How do you count the files a process has open right now?</summary>

`ls /proc/<PID>/fd/ | wc -l`. Use `sudo` if the process belongs to another user.
</details>

<details>
<summary>4. A process dies. What happens to <code>/proc/&lt;PID&gt;/</code>?</summary>

It disappears at once. The directory was only a view of the kernel's record for that process, and the record is freed.
</details>

<details>
<summary>5. Which file holds the per-process open-file cap, and which holds the whole-ship cap?</summary>

The per-process cap is the "Max open files" line in `/proc/<PID>/limits`. The whole-ship cap is `/proc/sys/fs/file-max`.
</details>

<details>
<summary>6. The numbers in <code>/proc/diskstats</code> never go down. How do tools get a rate from them?</summary>

They read the file twice, subtract the first reading from the second, and divide by the time between the reads.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-060-module-01-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-061
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission. It always starts clean, so nothing you broke carries over.
