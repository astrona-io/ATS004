# Question

Solve this question on: `terminal`

You are asked to set up a dedicated swap partition on a newly attached 1GB raw disk and optimize swap scheduling.

1. Format the 1GB raw disk `/dev/disk/by-id/virtio-lab042-swapdisk` as swap.
2. Enable it as swap immediately.
3. Configure the swap priority so that this fast swap partition has priority **10**, while the existing swap file `/swapfile` has priority **5**.
4. Save the configuration in `/etc/fstab` so that both swap zones are persistent and retain their priorities after reboot.
