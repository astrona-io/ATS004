# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and land the playground cleanly.

## What you learned

This module was about reaching a hold on another ship through your own secure channel: SSHFS and the FUSE relay beneath it.

**From [SSHFS and the FUSE Mechanism](./course-01-sshfs-and-fuse.md):**

- SSHFS is an ordinary program that serves a filesystem. The kernel relays each request through `/dev/fuse` to it, and it forwards the request over SSH.
- The mount type is `fuse.sshfs`, and an unprivileged user can create it.
- Nothing is needed on the server except a working SSH login.

**From [Performance, Sharing & Unmounting](./course-02-performance-sharing-and-unmounting.md):**

- Each call is one relay and one network round trip, so many small files are slow.
- A FUSE mount is private to the mounting user. `-o allow_other` opens it, and it needs `user_allow_other` in `/etc/fuse.conf`.
- `-o default_permissions` makes the local kernel check file modes. `allow_other` alone does not.
- `fusermount -u` unmounts without root.

**From [Keeping an SSHFS Mount Alive](./course-03-reconnecting-and-persistent-sshfs.md):**

- `reconnect`, `ServerAliveInterval` and `ServerAliveCountMax` let the mount notice a dead link and recover.
- An fstab line uses type `fuse.sshfs`, `_netdev`, and an `IdentityFile=` that root can read.
- `findmnt --verify` checks `/etc/fstab` without mounting, and `fusermount -u -z` removes a dead mount.

## Your missions

You proved the skills in graded missions, right after the part that taught them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [SSHFS Mounting Lab](./labs/lab-01/README.md) | SSHFS and the FUSE Mechanism, Performance, Sharing & Unmounting | mount a remote directory with `sshfs` at `/mnt/sshfs-share` and let other users access it, with no permanent configuration |

If you skipped one, go back to it now. They are short, and the exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. `bob` gets "Permission denied" on your SSHFS mount. What is the most likely cause?</summary>

The mount is private to the user who made it. Remount with `-o allow_other`, after `user_allow_other` is set in `/etc/fuse.conf`.
</details>

<details>
<summary>2. `allow_other` is set, yet `bob` can read a file that is mode 600 on the other ship. Why?</summary>

Without `default_permissions` the local kernel does not check file modes. The `sshfs` process reads the file with your login on the other ship. Add `-o default_permissions`.
</details>

<details>
<summary>3. Why is compiling a source tree on an SSHFS mount slow?</summary>

Each `open`, `read` and `close` is one relay through `/dev/fuse` and one network round trip. The cost grows with the number of calls, not with the size of the data.
</details>

<details>
<summary>4. Why does an fstab line for SSHFS need `IdentityFile=` and `_netdev`?</summary>

`root` makes the mount at boot, so it needs its own readable key. `_netdev` makes systemd wait for the network first.
</details>

<details>
<summary>5. The other ship has vanished and `fusermount -u` says the target is busy. What now?</summary>

Use a lazy unmount: `fusermount -u -z <dir>`. It detaches the mount at once.
</details>

## Clean up the playground

Land your training ship before you leave. First see what is still running:

```sh
astrona list
```

Remove the playground. The command takes its name, not its folder path:

```sh
astrona destroy section-020-module-01-playground
```

If `astrona list` also showed a mission, remove it the same way:

```sh
astrona destroy ats-004-lab-021
```

Then check again:

```sh
astrona list
```

The list should no longer show the playground or the missions from this module. You can start the playground again at any time with the `astrona run` command from the end of a mission; it always starts clean, so nothing you broke carries over.

<!-- astrona:playground:destroy -->
