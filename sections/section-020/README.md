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

## The Learning & Lab Path

This section is divided into two modules, both paired with hands-on practice within the remote network laboratory environment:

### 1. Ad-Hoc Mounting with SSHFS
*   **Module Reader:** **[Module 1: Ad-Hoc Mounting with SSHFS](./module-01/course.md)**
    1. [SSHFS and the FUSE Mechanism](./module-01/course-01-sshfs-and-fuse.md)
    2. [Performance, Sharing & Unmounting](./module-01/course-02-performance-sharing-and-unmounting.md)
*   **Practice Lab Sandbox:** **`sections/section-020/module-01/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-020/module-01/labs/lab-01
    ```
*   **Hands-on Objective:** Mount directory `/data-export` from server `app-srv1` to your local path `/app-srv1/data-export` on the client `terminal` using SSHFS, with read-write permissions and user-space sharing (`allow_other`) active.

### 2. Enterprise Sharing with NFS
*   **Module Reader:** **[Module 2: Enterprise Sharing with NFS](./module-02/course.md)**
    1. [Client-Server Model & Exports](./module-02/course-01-client-server-and-exports.md)
    2. [Mounting, Read-Only & a Down Server](./module-02/course-02-mounting-readonly-and-server-down.md)
*   **Practice Lab Sandbox:** **`sections/section-020/module-02/labs/lab-01`**
*   **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS004.git -c sections/section-020/module-02/labs/lab-01
    ```
*   **Hands-on Objective:** Set up the NFS server on `terminal` to export `/nfs/share` as read-only to client networks. On the client `app-srv1`, mount the shared directory stably under `/nfs/terminal/share`.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning before tackling the network lab mission:

*   **[Take the Section 020 Knowledge Check Quiz](./quiz.md)**
