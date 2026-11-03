# Question

Solve this question on: `terminal`

Astronaut, mission control has fitted your ship with a new 2 GB cargo hold: a raw secondary disk with no partition table. Draw its deck plan before anyone stores cargo in it.

1. Find the newly attached 2 GB raw disk with the usual discovery commands. It is also reachable as `/dev/disk/by-id/virtio-lab011-raw`.
2. Write a GUID Partition Table (GPT) label on this disk.
3. Create one partition, partition 1, that starts at sector 2048 (1 MiB, for correct alignment) and ends at 1 GiB (1024 MiB).
4. Leave the partition unformatted and unmounted.
