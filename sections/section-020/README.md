# Section 020: Remote Filesystems (SSHFS and NFS)

Welcome to Section 020. This section explores how to mount and manage filesystems over a network, bridging the gap between local storage and remote servers. You will learn the mechanics behind ad-hoc user-space mounting and robust, permanent enterprise sharing.

## Section Objectives

By the end of this section, you will master the following competencies:
* Understand the architectural differences between kernel-space and user-space filesystems.
* Confidently mount and manage remote directories using SSHFS for ad-hoc access.
* Configure, export, and secure NFS shares on a server.
* Mount NFS exports on clients with the correct safety parameters to prevent system hangs.

## Modules

### [Module 1: Ad-Hoc Mounting with SSHFS](./module-01/course.md)
* **Analogy:** The personal bicycle courier.
* **Core Topics:** FUSE vs kernel space, context-switching overhead, `sshfs` mounting, permission security, and critical flags like `-o allow_other` and `default_permissions`.

### [Module 2: Enterprise Sharing with NFS](./module-02/course.md)
* **Analogy:** Constructing the direct cargo pipeline.
* **Core Topics:** NFS server exports (`/etc/exports`), permission syntax, reloading exports (`exportfs -arv`), querying shares (`showmount -e`), client-side mounts, and client protection flags (`soft`, `intr`).

## Lab Exercise

Apply your knowledge in a practical environment:
* **[Lab 020: Remote Filesystems](../../labs/lab-020/README.md)**: Practice creating and mounting both SSHFS and NFS shares, managing permissions, and testing client-side safety limits.
