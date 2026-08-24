# Question

Solve this question on: `terminal`

Secure the newly attached 2GB secondary disk using block-level encryption.

1. Locate the raw disk of size 2GB.
2. Initialize a LUKS encrypted volume on this raw disk. Use the passphrase `securepassword123`.
3. Open the encrypted volume as a mapped block device named `secure_volume`.
4. Format the mapped device with an `ext4` filesystem.
5. Mount the formatted volume at `/mnt/secure-data`.
6. Create an empty file named `/mnt/secure-data/sealed` to prove the mount is writable.
