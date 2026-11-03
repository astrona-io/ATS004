# Solution Walkthrough

Two jobs: find and release the hidden space, then pin the scheduler. After each step you can run `astrona submit -c sections/section-070/module-02/labs/lab-02` to see what the grader still misses.

---

## Step 1: See that two gauges disagree

```sh
df -h /mnt/spool
sudo du -sh /mnt/spool
```

`df` asks the filesystem how much is used and says about 300M. `du` adds up the names it can walk to and finds almost nothing. A file that has no name but still uses space is the cause.

---

## Step 2: Find the holder and record its PID

```sh
sudo lsof +L1 /mnt/spool
```

`+L1` lists open files whose link count is below one, which means they are deleted. The `NAME` column ends with `(deleted)`, and the `PID` column names the process. Write that number down in the file (replace `1234` with your PID):

```sh
echo 1234 | sudo tee /root/holder-pid.txt
```

---

## Step 3: Stop the holder

```sh
sudo kill 1234
df -h /mnt/spool
sudo lsof +L1 /mnt/spool
```

The data of a deleted file stays until the last process closes it. Stopping the process closes the file, so the space returns at once, and `lsof` prints nothing.

---

## Step 4: Write the udev rule

Find the kernel name of the spool disk, for example with `lsblk`. Then save a rule file. A file under `/etc` is saved with `sudo`, for example `sudo nano /etc/udev/rules.d/60-spool-scheduler.rules`. Use your own disk name in place of `vdb`:

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

The brackets sit around `mq-deadline`. The udev rule is the standing order that sets the value again every time the disk appears, so it also holds after a restart. Run `astrona submit` for the final grade.
