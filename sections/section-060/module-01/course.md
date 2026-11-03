# The Process Blueprint: Inside /proc

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-060/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-060/module-01/playground
> astrona destroy section-060-module-01-playground
> ```

Astronaut, the ship's core keeps live status screens. `/proc` is the directory where you read them. It is not on any disk. Each time you read a file under `/proc`, the kernel builds the answer from its own live data and hands it back as text. You need no special tools, only `cat`, `grep` and `ls`.

In this module you learn why those files report a size of 0, read the facts about the whole ship, open the screen for one crew member (a process), count the open lines that crew member holds, and read the limits that cap them.

## Learning objectives

After this module you can:

- Explain what a pseudo-filesystem is, why `/proc` files report a size of 0, and what actually runs when you read one.
- Read system-wide facts from `/proc/meminfo`, `/proc/cpuinfo`, and `/proc/cmdline`.
- Find a running process's directory under `/proc/<PID>/` and read its launch command from `cmdline`.
- Explain why `/proc/<PID>/` disappears the instant a process exits, with no separate cleanup step.
- List and count a process's open file descriptors under `/proc/<PID>/fd/`.
- Describe how `/proc/<PID>/fd/` is used to find a file-descriptor leak.
- Read a process's state and memory use from `/proc/<PID>/status`, and its open-file cap from `/proc/<PID>/limits`.
- Read the system-wide open-file limit from `/proc/sys/fs/file-max` and the current usage from `/proc/sys/fs/file-nr`.
- Read the raw disk counters in `/proc/diskstats` and the mount list in `/proc/mounts`.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to use `cat`, `ls -l` and `grep`, and how to read command output. `tr` and `wc` appear too, and each is explained where it is used.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- Almost nothing here needs `sudo`. `/proc` is readable by everyone.
- The helper command `start-demo-proc` starts a long-lived process (a `tail -F` on two seeded log files in `/srv/demo/`) and prints its PID. That gives you a crew member to inspect.
- `pkill -f 'tail -F /srv/demo'` stops it again.

Start the playground and connect to it with `astrona ssh section-060-module-01-playground`. Run every command in the parts in that shell.

## The parts of this module

1. [/proc as a Live View & System-wide Files](./course-01-live-view-and-system-wide-files.md): the generator-function mechanism behind every `/proc` file, why `stat` reports 0 bytes, and reading global facts.
2. [Per-Process Directories & Open File Descriptors](./course-02-per-process-and-file-descriptors.md): `/proc/<PID>/` as a live view of one process, and counting `fd/` entries to catch a leak.
3. [Limits, Status and Storage Counters](./course-03-limits-status-and-storage-counters.md): the open-file limits, the process status screen, and the disk counters and mount list that storage tools read.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
