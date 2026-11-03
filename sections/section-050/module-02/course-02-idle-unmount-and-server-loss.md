# Idle Unmount and a Server That Stops Answering

An NFS hold is docked over the communications array. This part shows the robot undocking it when it is idle, and explains what happens when the other ship goes quiet while a hold is docked.

## The idle unmount

The `--timeout=15` on the master line applies to everything under `/mnt/dep`. Nothing about the countdown is special for NFS. With nothing open on `/mnt/dep/eng` and no shell inside it, the daemon undocks it after about 15 seconds. Real systems use longer values such as 300 seconds. 15 only makes it easy to watch.

The commands below need `/mnt/dep` managed by `autofs`, with the keys `eng` and `mkt` mapped to NFS exports, and `/mnt/dep/eng` docked.

<!-- astrona:playground:renew -->

### See it in your playground

Dock the export, move your shell out, wait, and look again:

```sh
ls /mnt/dep/eng
cd ~
sleep 20
mount | grep /mnt/dep
```

Expect something like this:

```text
/etc/auto.dep on /mnt/dep type autofs (...)
```

Only the `autofs` line remains. The `nfs4` mount is gone. Accessing `/mnt/dep/eng` again docks it on the spot. If the `nfs4` line is still there, a process still holds the mount busy. `cd` out of it and wait again.

## soft or hard when the server is gone

If the NFS ship stops answering while a hold is docked, the client has a choice. A **hard** mount (the default) waits and retries for ever. Programs that touch the hold stop and wait, and they can be woken with a signal. A **soft** mount gives up after a number of tries and returns an input/output error to the program.

Two options set the patience. `timeo` is how long the client waits for one answer, in tenths of a second. `retrans` is how many times it retries before it acts. For a read-only mount, `soft` is a safe choice, because no write can be lost. For a mount that is written to, a soft timeout can cut a write short, and the safe choice is `hard`.

The robot adds one more point. While the hold is docked, a stuck server blocks only the programs that use that hold. When the hold is undocked, the trigger on the client answers locally and never waits on the server. That is the reason to keep the idle timeout short on network mounts.

You can see which of the two a mount uses. `mount | grep /mnt/dep` lists the options of the live mount, and a soft mount shows `soft` in that list, a hard mount shows `hard`.

### See it in your playground

Dock `eng` and read its options:

```sh
ls /mnt/dep/eng
mount | grep /mnt/dep/eng
```

The options on the `nfs4` line include `ro` and `soft`, because the map line said so. The line also shows `timeo` and `retrans` values that the client chose by default.

## Common pitfalls

> [!WARNING]
> - **Using `soft` on a mount you write to.** A timeout can break a write in the middle. Use `hard` for writable data.
> - **Expecting an undocked hold to hang.** With nothing docked, the client does not talk to the server at all.
> - **A shell left in the mount.** It keeps the mount busy, and the idle timeout never fires.
> - **Reading the wait as a crash.** A hard mount that waits for a lost server is working as designed.
