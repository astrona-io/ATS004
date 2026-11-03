# Network Automount Maps and Tuning

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS004/tree/main/sections/section-050/module-02/playground)
>
> ```sh
> astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-050/module-02/playground
> astrona destroy section-050-module-02-playground
> ```

The master map says which directory the docking robot guards. The map it points at says what to dock when someone knocks. In this module the holds sit on another ship: an NFS server on the communications array. You map names to NFS exports with mount options, watch the robot undock them when idle, and cover many exports with one wildcard line.

## Learning objectives

After this module you can:

- Query an NFS server's exports with `showmount -e`.
- Write a map entry that maps a key to an NFS target with mount options.
- Trigger an on-demand NFS mount and confirm it with `mount`.
- Explain the idle unmount, and what `soft` and `hard` mean when the server stops answering.
- Write a wildcard map with `*` and `&`, and set the idle timeout on the master line.
- State which entry wins when an explicit key and a wildcard could both match, and give one key its own options.

## Before you start

Every mission starts with a pre-flight check. Know the basics below, and know what waits for you in your training ships.

### What you should already know

- How `autofs` works: a trigger mount point, a daemon that runs the mount on the first request, and an idle timeout.
- The master line format `/mnt/dep  /etc/auto.dep  --timeout=15` and `sudo systemctl reload autofs`.
- What an NFS export is, and what `mount -t nfs` does.

### What is in your playground

Your playground is two training spaceships on a private communications array, `10.10.50.0/24`.

- `client` (10.10.50.5) is the ship where every command runs. Its `autofs` service is running, `/etc/auto.master` is backed up to `/etc/auto.master.orig`, and the name `nfs` resolves from `/etc/hosts`.
- `nfs` (10.10.50.10) exports `/export/eng` and `/export/mkt` read-only to the array. Each holds one file, `eng-readme.txt` and `mkt-readme.txt`.

Start the playground and connect with `astrona ssh section-050-module-02-playground`. Choose `client` when asked. Run every command in the parts on `client`.

## The parts of this module

1. [Discovering Exports and Writing a Map](./course-01-discovering-and-submap.md): `showmount -e` and map entries with explicit keys.
2. [Idle Unmount and a Server That Stops Answering](./course-02-idle-unmount-and-server-loss.md): the timeout in action, and `soft` against `hard`.
3. [Wildcards: One Line for Many Exports](./course-03-wildcards.md): `*` and `&`, the timeout on the master line, and your graded mission.
4. [Exceptions: One Key With Its Own Options](./course-04-exceptions-and-precedence.md): explicit keys beat the wildcard.
5. [Wrap-Up: Mission Debrief](./course-05-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
