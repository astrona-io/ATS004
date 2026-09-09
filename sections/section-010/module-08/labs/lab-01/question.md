# Question

Solve this question on: `terminal`

Two spare 1GB disks are attached to this machine: one already holds a sample filesystem and file, the other is blank. Make the blank disk an exact clone of the other.

1. Identify the two raw disks (the source disk carries data; the clone disk is blank).
2. Clone the source disk onto the clone disk with `dd`, byte for byte.
3. Verify the clone is an exact match of the source using a checksum comparison.
