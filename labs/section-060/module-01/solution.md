# Solution Guide: proc Limits & File Descriptors

This guide explains how to extract active descriptor metrics from the virtual kernel interface.

---

## Step 1: Find Process ID of systemd-journald

Identify the PID of systemd-journald:
```bash
pidof systemd-journald
```
Suppose the PID is `345`.

---

## Step 2: Count Open File Descriptors

Navigate to the process virtual folder:
```bash
sudo ls -1 /proc/345/fd | wc -l
```
Write this number to `/opt/course/audit/fd_count.txt`. You can automate this:
```bash
sudo ls -1 /proc/$(pidof systemd-journald)/fd | wc -l | sudo tee /opt/course/audit/fd_count.txt
```

---

## Step 3: Get System-wide Max Files Limit

Read the active system limit from `/proc/sys/fs/file-max`:
```bash
cat /proc/sys/fs/file-max | sudo tee /opt/course/audit/file_max.txt
```
