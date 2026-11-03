# Question

Solve this question on: `terminal`

Astronaut, a new 2 GB disk has just been attached to your ship. It will carry sensitive cargo, so mission control wants a vault door on it before anything is stored there. Lock the disk with LUKS block-level encryption, then make it ready for use.

1. Find the raw 2 GB disk.
2. Create a LUKS encrypted volume on this raw disk. Use the passphrase `securepassword123`.
3. Open the encrypted volume as a mapped block device named `secure_volume`.
4. Format the mapped device with an `ext4` filesystem.
5. Mount the formatted volume at `/mnt/secure-data`.
6. Create an empty file named `/mnt/secure-data/sealed` to prove that the mount is writable.
