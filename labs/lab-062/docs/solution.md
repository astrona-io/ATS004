# Solution Guide: sysctl IPv4 Forwarding Tuning

Follow this guide to enable kernel-level IP forwarding dynamically and persistently.

---

## Step 1: Enable live packet forwarding

Instruct the active kernel to enable packet forwarding:
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```
Verify the live value using `cat`:
```bash
cat /proc/sys/net/ipv4/ip_forward
```
It should print `1`.

---

## Step 2: Persist the configuration

1. Edit `/etc/sysctl.conf` or create a new file `/etc/sysctl.d/99-ip-forward.conf`:
   ```bash
   sudo nano /etc/sysctl.conf
   ```
2. Uncomment or append the following line:
   ```text
   net.ipv4.ip_forward = 1
   ```
3. Load the configuration file to confirm no errors:
   ```bash
   sudo sysctl -p
   ```
