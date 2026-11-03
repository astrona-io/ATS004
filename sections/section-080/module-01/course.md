# Directory Capacity Auditing

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-080/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-080/module-01/playground
> astrona destroy section-080-module-01-playground
> ```

`df -h` tells you a filesystem is full. It does not tell you *what* filled it. To find the oversized log, backup, or cache directory, you measure consumption from the top down with `du` — and you have to keep `du` from wandering into other filesystems and pseudo-filesystems while it works, and know which of its several possible answers you're actually looking at.

## The parts of this module

1. [df vs du, and Reading du at a Sensible Depth](./course-01-df-vs-du-depth-and-units.md): what each command reads, and getting `du` down to a sorted, readable depth.
2. [Staying on One Filesystem & Allocated vs Apparent Size](./course-02-one-filesystem-and-apparent-size.md): the device-ID boundary that `-x` will not cross, and sparse files.
3. [When df and du Disagree](./course-03-when-df-and-du-disagree.md): deleted files that are still open, reserved blocks and hidden mounts.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.

## Learning objectives

After this module you can:

- Explain the difference between what `df` reports and what `du` reports, including the unlinked-but-open-file mechanism behind their most common disagreement.
- Run `du -h -d 1` on a directory and sort the result largest-first with `sort -hr`.
- Use `du -x` to keep the scan on a single filesystem, explain the device-ID mechanism behind it, and say why that matters at `/`.
- Explain why `du` (allocated blocks) can differ from `--apparent-size` and from `df`, and identify a sparse file as the cause.
- Use `lsof +L1` to find a deleted-but-still-open file inflating `df` without showing up in `du`.
- Name the other reasons `df` and `du` differ: reserved blocks, metadata and files hidden under a mount.

## Before you start

You should be comfortable with pipes and reading sizes like `256M` / `1.4G`.

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`. It has a second filesystem mounted at `/data` (so `du -x` has a boundary to hit). It also has seeded files on the root filesystem: `/opt/reports/big-real.bin` (256 MiB of real blocks), `/opt/archive/sparse.img` (512 MiB apparent, near-zero on disk), and `/opt/logs/` (200 tiny files). Start the playground and connect to it with `astrona ssh section-080-module-01-playground`. Run every command in the parts in that shell.
