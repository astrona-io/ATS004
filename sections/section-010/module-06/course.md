# systemd Mount and Automount Units

Astronaut, on your ship the duty officer, systemd, handles every docking. Each mount is a duty order on its list, called a unit, just like a service. The logbook `/etc/fstab` is only a short way to write those orders: at every launch, a small program turns each logbook line into a `.mount` unit.

In this module you look at the orders your ship already has, then write your own by hand. You pair a mount with an `.automount` unit, so a cargo hold docks the moment someone knocks on its hatch and undocks again when nobody uses it. Finally, you get the same result from a single logbook line.

## Learning objectives

After this module you can:

- Explain how lines in `/etc/fstab` become `.mount` units, say when `systemd-fstab-generator` runs, and list mount units with `systemctl`.
- Name the order in which systemd searches for unit files, and predict which file wins when a hand-written unit and a generated one share a name.
- Work out a `.mount` unit's required filename from its mount path with `systemd-escape`.
- Write and start a native `.mount` unit, and explain what `daemon-reload`, `enable` and `start` each change.
- Add an `.automount` unit for on-demand mounting with an idle timeout, and describe how it moves between waiting, mounting and mounted.
- Get the same on-demand mounting from `/etc/fstab` with `x-systemd.automount` and related options.
- Explain why an fstab line and a hand-written unit for the same path do not combine, and which one wins.

## Before you start

Every mission starts with a pre-flight check. Make sure you know the basics below, and know what waits for you in your training ship.

### What you should already know

- The six fields of an `/etc/fstab` line, and why a device is named by `UUID=` rather than by `/dev/vdb`.
- Basic `systemctl` use: `start`, `status` and `enable`.

### What is in your playground

Your playground is one training spaceship: an Ubuntu 24.04 virtual machine with passwordless `sudo`.

- One spare 1 GB disk already carries an ext4 filesystem with the label `DATA`. It is usually `/dev/vdb`, and it is also reachable as `/dev/disk/by-id/virtio-s015m02-a`. Always confirm the name with `lsblk`.
- The original `/etc/fstab` is saved as `/etc/fstab.orig`, so you can roll back any change.
- No units or fstab lines for the spare disk exist yet. Writing them is your job.
- `systemctl`, `systemd-escape`, `findmnt` and `blkid` are installed.

Start the playground and connect to it with `astrona ssh section-010-module-06-playground`. Run every command in the parts in that shell.

<!-- astrona:playground -->

## The parts of this module

1. [How /etc/fstab Becomes systemd Units](./course-01-fstab-generated-units-and-naming.md): what the fstab generator does and when, which copy of a unit wins, and the filename rule for mount units.
2. [Writing Native .mount and .automount Units](./course-02-native-mount-and-automount-units.md): write a `.mount` and an `.automount` unit by hand, and see what `daemon-reload`, `enable` and `start` each do.
3. [The fstab Shortcut and Common Pitfalls](./course-03-fstab-shortcut-and-pitfalls.md): get on-demand mounting from one `/etc/fstab` line, and why it never mixes with a hand-written unit.
4. [Wrap-Up: Mission Debrief](./course-04-wrap-up.md): what you learned, your mission, questions to check yourself, and cleanup.
