# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about the cargo lift's gauges: how to tell that a hold is the bottleneck, and how to read the numbers that prove it.

**From [I/O Wait, IOPS & Throughput](./course-01-io-wait-iops-throughput.md):**

- I/O wait is time spent waiting on the disk. A process waiting on it sleeps in state `D` and cannot be killed until the I/O finishes.
- A high `wa` with idle user CPU is a storage problem.
- A disk has one ceiling for operations per second and another for bytes per second.

**From [Where iostat Gets Its Numbers](./course-02-where-iostat-gets-its-numbers.md):**

- `/proc/diskstats` holds totals since boot. `iostat` reads them twice, subtracts and divides by the time.
- `await` is delta milliseconds over delta requests, `%util` is the share of time with a request in flight, and `aqu-sz` is the average queue length.
- The first `iostat` report is the average since boot.

**From [Reading iostat Columns](./course-03-reading-iostat-columns.md):**

- Use `iostat -xz 1` for live work.
- `%util` can mislead on SSDs and RAID, so read `aqu-sz` and `await` with it.
- Compare `w/s` with `wkB/s` to tell IOPS-bound from throughput-bound.

**From [Watching a Device Saturate](./course-04-watching-a-device-saturate.md):**

- A sequential load shows high `wkB/s` with moderate `w/s`. A random small-write load shows high `w/s` with low `wkB/s`.
- Stop one load before you start the other.

## Your missions

You proved the skill in a graded mission, right after the part that taught it:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [iostat Wait Latency](./labs/lab-01/README.md) | Watching a Device Saturate | find the saturated device with `iostat` and record its name |

If you skipped it, go back to it now. It is short, and the exam asks for exactly this skill.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. The CPU line in <code>top</code> shows high <code>wa</code> and little user time. What is the likely cause?</summary>

The cores are waiting on the disk. It is a storage bottleneck, so check `iostat`, not the CPU.
</details>

<details>
<summary>2. Why can <code>kill -9</code> fail on a process in state <code>D</code>?</summary>

The process sleeps inside a block-layer wait. The kernel delivers no signal until the I/O finishes.
</details>

<details>
<summary>3. Which file does <code>iostat</code> read, and how does it get a rate from it?</summary>

It reads `/proc/diskstats`. The values are totals, so it reads twice, subtracts the first reading from the second and divides by the seconds between them.
</details>

<details>
<summary>4. Why is the first report of <code>iostat -xz 1</code> not useful for a live problem?</summary>

It is the average since boot. Read the second and later reports.
</details>

<details>
<summary>5. An SSD shows <code>%util</code> 100, <code>aqu-sz</code> 0.5 and <code>w_await</code> 0.2 ms. Is it saturated?</summary>

Probably not. An SSD serves requests in parallel, so `%util` alone can read 100 with headroom left. The short queue and low delay say it is keeping up.
</details>

<details>
<summary>6. <code>w/s</code> is 9800 and <code>wkB/s</code> is 39200. Which kind of load is this?</summary>

An IOPS-bound load: many small writes of about 4 KiB each.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-070-module-01-playground
```

If `astrona list` also showed the mission, remove it the same way:

```sh
astrona destroy ats-004-lab-071
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the mission from this module. You can start the playground again at any time with the `astrona run` command from the end of the mission. It always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
