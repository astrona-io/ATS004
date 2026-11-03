# On-Demand Mounting Fundamentals

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-050/module-01/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-050/module-01/playground
> astrona destroy section-050-module-01-playground
> ```

A line for a network share in `/etc/fstab` means the ship tries to dock it at every launch. If the storage server is down at that moment, the launch can stall waiting for an answer. A share held open around the clock also ties up resources, and it can freeze programs when the link later drops.

`autofs` is a docking robot that avoids both problems. It docks a hold the moment someone asks for it, and it undocks the hold again after a quiet period. In this module you learn how that works, how the maps tell the robot what to dock and where, and how to find out why it did not.

## Learning objectives

After this module you can:

- Explain the trap-and-resume mechanism `autofs` uses to dock on demand, and why it never polls.
- Enable the `autofs` service and check that it runs.
- Write an `/etc/auto.master` entry with an idle timeout, and an indirect map that goes with it.
- Write a direct map with `/-` for one fixed mount point and set its timeout.
- Say which map wins when a direct and an indirect map could claim the same path.
- Use drop-in files in `/etc/auto.master.d/`, reload `autofs`, and debug a map with `automount -m` and `automount -f -v`.

## Before you start

Every mission starts with a pre-flight check. Know the basics below, and know what waits for you in your training ship.

### What you should already know

- How to mount and unmount a filesystem, and how to edit a file with `sudo`.
- How to start and check a service with `systemctl`.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- `autofs` is installed, but the service is not started yet.
- A local directory `/srv/localdata` holds two files, `hello.txt` and `notes.txt`. The examples mount it through `autofs` as a local bind mount, so you see the dock-and-undock behaviour with no NFS server.
- `/etc/auto.master` is backed up to `/etc/auto.master.orig`, so you can roll back with one command.

Start the playground and connect to it with `astrona ssh section-050-module-01-playground`. Run every command in the parts in that shell.

## The parts of this module

1. [How On-Demand Mounting Works, and Enabling autofs](./course-01-mechanism-and-enabling.md): the trap-and-resume mechanism and the service.
2. [The Master Map, Triggering and Idle Unmount](./course-02-master-map-and-triggering.md): an indirect map from the master file to a live mount and back.
3. [Direct Maps and a Fixed Mount Point](./course-03-direct-maps.md): the `/-` form for one fixed path, and your graded mission.
4. [Drop-In Master Files and Debugging autofs](./course-04-drop-ins-and-debugging.md): `/etc/auto.master.d/`, `automount -m` and the foreground debug run.
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
