# Solution Guide (Offline & Exam Friendly)

This step-by-step guide explains how to gather kernel-state facts and make temporary tuning changes directly via the `/proc` filesystem and standard command-line tools.

---

## Step 1: Read Memory Stats from Kernel Memory Accounting

The kernel exposes real-time memory information via `/proc/meminfo`. Run the following to display the top lines, which include total and available memory:

```bash
cat /proc/meminfo | head -5
```
*`MemAvailable` shows the actual memory that can be allocated for new processes, whereas `MemFree` is just completely unused memory.*

---

## Step 2: Count a Process's Open File Descriptors

The kernel tracks every file descriptor (FD) that a process currently has open inside a directory named `/proc/<PID>/fd/`.

1. Get the PID of the target process:
   ```bash
   cat /opt/course/target.pid
   ```
2. If you do not remember how the kernel represents process FDs, check the manual page:
   ```bash
   man 5 proc
   ```
   *Search for `/fd` inside the man page. It explains that `/proc/[pid]/fd` is a subdirectory containing symbolic links for every open file descriptor.*
3. List the entries and count them using `wc -l`:
   ```bash
   PID=$(cat /opt/course/target.pid)
   ls /proc/$PID/fd | wc -l
   ```
4. If you want to see what files or network sockets these descriptors actually point to, list them in long format:
   ```bash
   sudo ls -l /proc/$PID/fd
   ```

---

## Step 3: Temporarily Enable IPv4 Forwarding

Kernel tuning variables are managed under the `/proc/sys/` directory tree.

1. If you forget the exact path to the IP forwarding setting, search the `/proc/sys/` directory:
   ```bash
   find /proc/sys -name "*forward*"
   ```
   *This output lists `/proc/sys/net/ipv4/ip_forward`.*
2. Check the current value (0 means disabled, 1 means enabled):
   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   ```
3. Enable IP forwarding for the current boot only by writing `1` directly into this file:
   ```bash
   echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
   ```
   *Note: Directly writing to files in `/proc/sys/` updates the kernel state instantly in memory. Because we are not writing to `/etc/sysctl.conf` or `/etc/sysctl.d/`, this change will not persist across reboots.*

---

## Step 4: Show the `sysctl` Equivalent Name

The relationship between `/proc/sys/` paths and `sysctl` variables is completely mechanical:
1. Strip the `/proc/sys/` prefix.
2. Replace every remaining slash `/` with a dot `.`.

Therefore, `/proc/sys/net/ipv4/ip_forward` maps to `net.ipv4.ip_forward`.

Verify this using the `sysctl` tool:
```bash
sysctl net.ipv4.ip_forward
```

---

## Step 5: Read the Live Mount Table for `/`

The kernel keeps its live active mount list in `/proc/mounts`. This is generated dynamically by the kernel and represents the ultimate source of truth, avoiding potential drift associated with other command outputs.

1. Filter the live mount table for the root filesystem `/`:
   ```bash
   grep ' / ' /proc/mounts
   ```
2. Compare this raw kernel data with the outputs of user-space tools:
   ```bash
   findmnt /
   mount | grep ' on / '
   ```

---

## Verification

Verify that all facts and states are correct:

```bash
# 1. Confirm memory stats read successfully
cat /proc/meminfo | grep -E 'MemTotal|MemAvailable'

# 2. Check open file descriptor count
ls /proc/$(cat /opt/course/target.pid)/fd | wc -l

# 3. Confirm IP forwarding is enabled
cat /proc/sys/net/ipv4/ip_forward

# 4. Verify sysctl value
sysctl net.ipv4.ip_forward

# 5. Verify the root filesystem details
grep ' / ' /proc/mounts
```
