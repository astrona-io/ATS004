# Question

Solve this question on: `terminal`

Configure on-demand dynamic folder mounting for enterprise NFS environments.

1. Configure an indirect map in `autofs` that monitors `/mnt/net/`.
2. Map any subdirectories on-demand so that entering `/mnt/net/<dirname>` automatically mounts `127.0.0.1:/var/nfs/exports/<dirname>`. Use the standard `&` substitution and wildcard `*` syntax.
3. Configure the mount to automatically release and unmount after exactly **120** seconds of inactivity.
4. Verify the setup by accessing `/mnt/net/project-alpha`.
