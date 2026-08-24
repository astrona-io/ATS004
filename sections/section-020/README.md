# Section 020: Remote Filesystems (SSHFS and NFS)

Welcome to the world of network-distributed storage. In modern data centers, applications running on your application servers rarely write data directly to their local host drives. Instead, they write to centralized, dedicated storage arrays located elsewhere on the local area network.

In this section, we explore how to bridge filesystems over network wires. We focus on two critical administrative protocols: **SSHFS** (Secure Shell Filesystem), which allows for secure, ad-hoc user-space mounts over standard SSH, and **NFS** (Network File System), the industry-standard kernel-space protocol designed for high-performance, multi-client storage sharing.

---

## What You Will Master

By completing this section, you will acquire three core network storage capabilities:
*   **User-Space Mounts (SSHFS):** How to securely mount remote directories over SSH without requiring root privileges or complex firewall configurations.
*   **Enterprise Share Exporting (NFS):** How to configure the NFS daemon, export directories securely to specific whitelisted networks, and balance sync states for data safety.
*   **Resilient Network Mounting:** How to connect remote exports to client nodes and configure mount parameters to prevent terminal hangs if the storage server goes offline.

---

## The Learning Path

This section is organized into a single comprehensive guide:

*   **[Module 1: Remote Filesystems: SSHFS and NFS](./module-01)**
    Explore the tradeoffs of user-space FUSE context-switching vs. direct kernel RPC pipelines. Master exporting folders via `/etc/exports`, reloading tables on the fly, and securely mounting network volumes.

---

## Hands-On Practice Mission

Once you have read through the narrative guides, you are ready to apply your network storage skills in a multi-VM live scenario:

*   **[Go to Lab 020](../../labs/lab-020)**: Configure a secure SSHFS user-space bridge and export a high-performance read-only NFS share across your network.
