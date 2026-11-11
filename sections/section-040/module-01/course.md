# Temporary Safety Valves: Swap Files

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-040/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-040/module-01/playground
> astrona destroy section-040-module-01-playground
> ```

Astronaut, a ship's working memory (RAM) is its flight deck: fast, but small. When the deck is full and nothing can be moved out, the kernel's emergency crew, the Out-Of-Memory (OOM) killer, picks a process and ends it. Swap is a spare cargo hold where the kernel parks idle memory pages instead. A spike then slows the ship down. It no longer costs you a crew member.

In this module you add swap to a running ship with a swap file. You allocate it, lock it down, format it, switch it on and off, make it return after a reboot, and tune how eagerly the kernel uses it.

## Learning objectives

After this module you can:

- Explain what swap does and describe the kernel's page-reclaim mechanism (`kswapd`, active and inactive lists) that decides when it is used.
- Allocate a swap file with `fallocate` and explain why `chmod 600` on it matters.
- Format a file for swap with `mkswap` and state what its header contains.
- Activate it with `swapon`, read the result from `swapon --show` and `free`, and deactivate it with `swapoff`.
- Make a swap file persistent with an `/etc/fstab` line and prove it with `swapoff -a` and `swapon -a`.
- Read and change `vm.swappiness`, and keep the value across a reboot with a file in `/etc/sysctl.d/`.

## Before you start

Every mission starts with a pre-flight check. Know the basics below, and know what waits for you in your training ship.

### What you should already know

- Basic file commands (`ls`, `chmod`, `rm`) and `sudo`.
- How to read sizes in command output.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with 2 GB of memory, an ext4 root filesystem with room to spare and passwordless `sudo`. The swap tools are installed, and no swap is active at the start. The bootstrap script prints the starting memory and swap picture and removes any old `/swapfile`.

Start the playground and connect to it with `astrona ssh section-040-module-01-playground`. Run every command in the parts in that shell.

## The parts of this module

1. [What Swap Is and Checking What You Have](./course-01-what-swap-is-and-checking-it.md): why the kernel swaps and how to read the current picture.
2. [Allocating, Activating and Deactivating a Swap File](./course-02-allocating-activating-deactivating.md): the full life of a swap file, from `fallocate` to `swapoff`.
3. [Making a Swap File Survive a Reboot](./course-03-persisting-a-swap-file.md): the `/etc/fstab` line, the safe check, and your first graded mission.
4. [Tuning Swap Behaviour with swappiness](./course-04-swappiness-tuning.md): read the dial, turn it, and keep it across reboots.
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.

<!-- curriculum-practice -->
## Practice and assessment

- [Swap File Allocation & Security Lab](labs/lab-01/question.md): Create a 512MB swap file at /swapfile that only root can read and write; Format and activate /swapfile as swap space; Add /swapfile to /etc/fstab so it survives a reboot.
- [Swap Space Management Capstone Lab](../capstone/labs/lab-01/question.md): Create, secure and activate a 2G swap file and persist it in /etc/fstab; Find the unformatted partition with lsblk and activate it as swap; Prefer the partition by giving it priority 10 and the swap file priority 5.
