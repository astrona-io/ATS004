# Block Queue Attributes & udev Rules

Every disk has a set of dials under `/sys/block/<dev>/queue/`. This part reads them, changes one, and then shows why the change vanishes at the next launch and how a udev rule fixes that.

## The disk dials in `/sys/block/<dev>/queue/`

Think of the cargo lift between the ship and one hold. The lift has a queue and a rule for which request goes first. This section names the dials that describe that queue.

### What the files mean

- `scheduler` lists the I/O schedulers the kernel offers for this disk. The one in use is shown in square brackets. The scheduler is the rule that orders waiting requests.
- `rotational` is `1` for a spinning disk and `0` for flash. The kernel uses it to choose sensible defaults.
- `read_ahead_kb` is how much extra data the kernel reads ahead when it sees a sequential read.
- `nr_requests` is how many requests the queue can hold.

Each of these is a `/sys` attribute with a `show` function. `scheduler` and the others in the list also have a `store` function, so you can write a new value.

<!-- astrona:playground:renew -->

### See it in your playground

Print the dials of the spare disk. Confirm that it is `vdb` with `lsblk`.

```sh
cat /sys/block/vdb/queue/scheduler
cat /sys/block/vdb/queue/rotational
cat /sys/block/vdb/queue/read_ahead_kb
cat /sys/block/vdb/queue/nr_requests
```

The first command prints the names of the available schedulers on one line, with the active one in brackets. The other three print one number each. The values depend on the virtual disk, so write down what you see before you change anything.

## Changing a dial for the running ship

A write to a `store` file takes effect at once. This section shows the safe way to write one, and why the plain `sudo echo` pattern fails here too.

### Use `tee`, not a redirect

The shell opens a `>` redirect as your own user before `sudo` starts. So `sudo echo value > file` fails with "Permission denied". Let `tee` do the writing instead, because `tee` is the program that runs under `sudo`.

### See it in your playground

Pick a scheduler name from the list you printed above (for example `none` or `mq-deadline`, whichever your list shows), write it, and read the file again.

```sh
echo mq-deadline | sudo tee /sys/block/vdb/queue/scheduler
cat /sys/block/vdb/queue/scheduler
```

If `mq-deadline` is not in your list, the write fails with an error. Use a name from your own list. The second command shows the brackets moved to the new name. Write your original value back when you finish.

## Making a `/sys` change survive a reboot

The kernel sets every `/sys` value again at each launch, so your write is gone after a restart. Persistence needs something that replays the write each time the disk appears. On Ubuntu that something is a udev rule, a standing order for the ship's device manager.

### Write the rule

Save this as `/etc/udev/rules.d/60-vdb-scheduler.rules`. A file under `/etc` is saved with `sudo`, for example `sudo nano /etc/udev/rules.d/60-vdb-scheduler.rules`:

```text
ACTION=="add|change", KERNEL=="vdb", ATTR{queue/scheduler}="mq-deadline"
```

Apply it:

```sh
sudo udevadm control --reload
sudo udevadm trigger --action=change --name-match=vdb
```

Then check the result:

```sh
cat /sys/block/vdb/queue/scheduler
```

The brackets sit around `mq-deadline`. The rule matches on the kernel name `vdb`, so it fits only while that disk keeps that name. Remove the rule file and write your original scheduler back when you finish.

## Common pitfalls

> [!WARNING]
> - **`sudo echo value > /sys/...`.** The redirect runs as your user and fails. Use `echo value | sudo tee /sys/...`.
> - **Expecting a `/sys` write to last.** It is lost at reboot. A udev rule or a unit that replays the write is what lasts.
> - **Matching on a device name that can move.** `vdb` can become `vdc` if disks attach in another order. Real rules often match on a serial number or an ID instead.
> - **Writing a value the driver rejects.** A scheduler name that is not in the list gives an error, and the old value stays.
