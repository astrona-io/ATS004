# Solution Guide: iotop and lsof Profiling

This guide shows you how to isolate a rogue process and find its locked active file handles.

---

## Step 1: Install Diagnostics

Ensure required profiling packages are ready:
```bash
sudo apt-get update -y
sudo apt-get install -y iotop lsof
```

---

## Step 2: Locate the Rogue Process PID

Run `iotop` showing only active writing processes:
```bash
sudo iotop -o
```
Look at the **DISK WRITE** column to find the process generating high percentages (e.g., several MB/s). Note down its **PID** (for instance, `1432`).

---

## Step 3: Find the Saturated File Path

Run `lsof` with the PID of your culprit process to display its open files:
```bash
sudo lsof -p 1432
```
Look through the list under the **NAME** column for an active writing handle, typically located under `/var/log` (such as `/var/log/rogue_activity.log`).

---

## Step 4: Write Audit Results

Create `/opt/course/audit/culprit.txt` and populate it:
```bash
sudo mkdir -p /opt/course/audit
sudo nano /opt/course/audit/culprit.txt
```
Enter values like:
```text
1432
/var/log/rogue_activity.log
```
