# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about finding which crew member is hammering a hold, and which crate they are handling.

**From [From Device to Process: iotop & pidstat](./course-01-iotop-and-pidstat.md):**

- `iotop -o` shows only processes doing I/O. It needs root and kernel task delay accounting, which is off by default from kernel 5.14. Without it every row reads `0.00 B/s`.
- `pidstat -d` reads always-on counters, so it is the fallback.

**From [Where Per-Process I/O Numbers Come From](./course-02-per-process-io-counters.md):**

- `/proc/<PID>/io` holds totals. `rchar` and `wchar` count what the program asked for. `read_bytes` and `write_bytes` count real storage work.
- `pidstat -d` columns come from these fields. A rate needs two readings.

**From [lsof: Which File, Which Process](./course-03-lsof-files-and-processes.md):**

- `lsof -p <PID>` goes from a process to its files. `lsof <path>` goes from a file to its users. `lsof -i` lists sockets.
- `lsof +L1` finds deleted files that are still open. They keep using space until the process closes them.

**From [Closing the Loop](./course-04-closing-the-loop.md):**

- The chain is `iostat` for the device, `findmnt` for the mount, `iotop` or `pidstat` for the PID, and `lsof` for the file.

## Your missions

You proved the skills in graded missions, right after the parts that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [iotop and lsof Active Profiling](./labs/lab-01/README.md) | Closing the Loop | find the PID of a heavy writer and the path of the file it writes |
| [Free Hidden Space and Pin the Scheduler Lab](./labs/lab-02/README.md) | lsof: Which File, Which Process | find a deleted file that is still open with `lsof +L1`, free its space and set a scheduler with a udev rule |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. <code>iotop</code> shows <code>0.00 B/s</code> on every row, yet the disk is busy. What are the two likely causes?</summary>

Task delay accounting is off, or you are not running it as root. Use `sudo`, set `kernel.task_delayacct=1`, or use `pidstat -d`.
</details>

<details>
<summary>2. Why does <code>pidstat -d</code> work when <code>iotop</code> does not?</summary>

It reads the always-on counters in `/proc/<PID>/io`, which have no switch.
</details>

<details>
<summary>3. A process reads the same file again and again. <code>rchar</code> is huge but <code>read_bytes</code> is small. Why?</summary>

The reads are answered from the page cache. They count in `rchar` but never reach the disk.
</details>

<details>
<summary>4. How do you list every process that uses <code>/mnt/perf/leak.log</code>?</summary>

`sudo lsof /mnt/perf/leak.log`.
</details>

<details>
<summary>5. <code>df</code> says a filesystem is full but <code>du</code> cannot find the files. What do you check?</summary>

A deleted file that is still open. `sudo lsof +L1` lists it marked `(deleted)`. Restart or signal the process to free the space.
</details>

<details>
<summary>6. Put these in order: <code>lsof</code>, <code>iostat</code>, <code>findmnt</code>, <code>pidstat</code>.</summary>

`iostat` finds the device, `findmnt` finds its mount, `pidstat` finds the process, and `lsof` finds the file.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-070-module-02-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-072
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission. It always starts clean, so nothing you broke carries over.
