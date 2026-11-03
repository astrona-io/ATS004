# lsof: Which File, Which Process

A PID is not enough when the process is a database or a log shipper. You need the exact file. `lsof` lists the open files in the ship's open-file table, and it can read that table in both directions: from a process to its files, and from a file to its users.

## From a process to its files, and back

`lsof` stands for "list open files". Everything a process holds open counts: programs, libraries, sockets and plain files. This section shows the two directions.

### Two directions

`lsof -p <PID>` lists everything one process has open. Filter the `NAME` column for the mount point you care about. `lsof <path>` goes the other way and lists every process using that file. `lsof +D <dir>` does it for every file below a directory. It walks the whole tree, so it is slow on a large one.

In the `FD` column, a number followed by `r`, `w` or `u` means the descriptor is open for reading, writing or both. The `TYPE` `REG` is a regular file.

<!-- astrona:playground:renew -->

### See it in your playground

Start the writer, then look at it from both sides. Replace `<PID>` with the number that `start-io-load` printed.

```sh
start-io-load
sudo lsof -p <PID> | grep /mnt/perf
sudo lsof /mnt/perf/leak.log
```

Expect something like this:

```text
fio     2451 ubuntu    5u   REG  254,16  536870912  12  /mnt/perf/leak.log

COMMAND   PID   USER   FD   TYPE DEVICE  SIZE/OFF NODE NAME
fio      2451 ubuntu    5u   REG  254,16 536870912   12  /mnt/perf/leak.log
```

The first command shows that PID 2451 holds `/mnt/perf/leak.log` open on descriptor 5 for reading and writing. The second command starts from the file and lists its users. Either way you now know the process and the file.

## Network sockets and `-i`

Sockets are open lines too. This section shows the same tool aimed at the network.

### Find who holds a port

`lsof -i` lists open network sockets. `lsof -i :22` limits the list to port 22. It needs `sudo` to show the sockets of other users' processes.

### See it in your playground

List the processes that hold a socket on port 22.

```sh
sudo lsof -i :22
```

The output has the same columns as before. The `NAME` column shows the address and port. You normally see the SSH server and, because you are logged in over SSH, a connection line too.

## Deleted files that still use space

`df` says the hold is full, but `du` cannot find the files. This is a classic puzzle on the exam. This section explains it.

### Why deleted space is not freed

Removing a file name does not free the file while a process still has it open. The name is gone from the directory, so `ls` cannot see it. But the data stays and keeps using space until the last process closes it. `lsof +L1` lists open files with a link count below one, that is, files that are deleted but still open. The `NAME` column shows them marked `(deleted)`. The fix is to restart or signal the process so that it closes the file.

### See it in your playground

Delete the file under the running writer, then look for it.

```sh
rm /mnt/perf/leak.log
sudo lsof +L1 /mnt/perf
df -h /mnt/perf
```

The second command lists the writer with the file marked `(deleted)`. The third shows the space still in use, even though `ls /mnt/perf` no longer shows the file. Run `stop-io-load` when you finish.

## Common pitfalls

> [!WARNING]
> - **`lsof` missing entries.** Without `sudo` you only see your own processes. Run it as root to see another user's or a service's files.
> - **Using `lsof +D` on a big tree.** It walks every file and can take a long time. Use `lsof <path>` for one file.
> - **Deleting a big log and expecting free space.** If a process still holds it open, the space stays used. Look for `(deleted)` with `lsof +L1`.
> - **Acting before tracing.** Stopping the busiest process without checking its file can take down the wrong service.

## Your mission: Free Hidden Space and Pin the Scheduler Lab

You can now find a deleted file that a process still holds open. The mission asks you to find that process with `lsof +L1`, record its PID and stop it to free the space, and then pin the I/O scheduler of a disk with a udev rule.

The mission runs on its own training ship. A playground cannot be paused, so remove it first to free memory. It always starts clean again:

```sh
astrona destroy section-070-module-02-playground
```

Then start the mission and connect to it:

```sh
astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-070/module-02/labs/lab-02
astrona ssh ats-004-lab-070-02-02
```

Read the task in [`question.md`](./labs/lab-02/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-070/module-02/labs/lab-02
```

When the mission is done, remove it and start a fresh playground:

```sh
astrona destroy ats-004-lab-070-02-02
astrona run --git ssh://git@github.com/astrona-io/ATS004.git -c sections/section-070/module-02/playground
```
