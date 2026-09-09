# The Process Blueprint: Inside /proc

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-060/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-060/module-01/playground
> astrona destroy section-060-module-01-playground
> ```

`/proc` is a directory that is not on any disk. The kernel generates its contents on the fly: each time you read a file under `/proc`, the kernel assembles the answer from its own live data structures and hands it back as text. It is the plainest possible interface to what the kernel knows — no special tools, just `cat`, `grep`, and `ls`.

## How this module is organised

1. **[Part 1 — /proc as a Live View & System-wide Files](./course-01-live-view-and-system-wide-files.md)** — the generator-function mechanism behind every `/proc` file, why that makes `stat` report 0 bytes, and reading global facts (`meminfo`, `cpuinfo`, `cmdline`).
2. **[Part 2 — Per-Process Directories & Open File Descriptors](./course-02-per-process-and-file-descriptors.md)** — `/proc/<PID>/` as a live view of the kernel's `task_struct`, reading `cmdline`/`exe`/`cwd`, and counting `fd/` entries to catch a file-descriptor leak.

## Learning objectives

After this module you can:

- Explain what a pseudo-filesystem is, why `/proc` files report a size of 0, and what actually runs when you read one.
- Read system-wide facts from `/proc/meminfo`, `/proc/cpuinfo`, and `/proc/cmdline`.
- Find a running process's directory under `/proc/<PID>/` and read its launch command from `cmdline`.
- Explain why `/proc/<PID>/` disappears the instant a process exits, with no separate cleanup step.
- List and count a process's open file descriptors under `/proc/<PID>/fd/`.
- Describe how `/proc/<PID>/fd/` is used to find a file-descriptor leak.

## Before you start

You should be comfortable with `cat`, `ls -l`, `grep`, and reading command output; `tr` and `wc` appear too and are explained where used.

The linked playground gives you an Ubuntu server VM. Almost nothing here needs `sudo` — `/proc` is world-readable. A helper command `start-demo-proc` launches a long-lived process (a `tail -F` on two seeded log files) and prints its PID, giving you a process to inspect. Run the command blocks in Parts 1–2 in that VM after `astrona ssh section-060-module-01-playground`.
