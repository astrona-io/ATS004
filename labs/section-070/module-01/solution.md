# Solution Guide: iostat Wait Latency Analysis

This guide explains how to isolate and identify disk bottleneck issues.

---

## Step 1: Install sysstat

Ensure diagnostic tools are available:
```bash
sudo apt-get update -y
sudo apt-get install -y sysstat
```

---

## Step 2: Analyze Device Statistics

Run `iostat` with extended details:
```bash
iostat -xz 1 5
```
Watch the output columns:
- **await**: The average time (in milliseconds) for I/O requests issued to the device to be served.
- **%util**: Bandwidth utilization. A value close to 100% indicates device saturation.

Locate which device shows extremely high values (e.g. `%util` is 99% or `await` is in hundreds of ms).

---

## Step 3: Document Findings

Compare the slow device to `lsblk` names, and write the name (e.g., `vdc`) to the target file:
```bash
sudo mkdir -p /opt/course/audit
echo "vdc" | sudo tee /opt/course/audit/slow_device.txt
```
