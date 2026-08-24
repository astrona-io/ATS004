# Section 050: On-Demand Mounting (autofs)

Welcome to Section 050. This section tackles the unreliability of networks when configuring permanent storage mounts. You will learn how to replace fragile, static boot configurations with dynamic, on-demand mount triggers using `autofs`.

## Section Objectives

By the end of this section, you will master the following competencies:
* Understand the architectural flaws of static network mounts in `/etc/fstab`.
* Configure the autofs daemon and understand VFS lookup interception.
* Build master maps to define automated mount boundaries.
* Write complex network automount maps using wildcards and variables to scale access dynamically without manual intervention.

## Modules

### [Module 1: On-Demand Mounting Fundamentals](./module-01/course.md)
* **Analogy:** The library archives' dynamic on-demand retrieval courier.
* **Core Topics:** The risks of static `fstab` entries, autofs VFS lookup interception, daemon management (`systemctl`), direct vs. indirect master maps (`/etc/auto.master`), and idle unmount timeouts (`--timeout=`).

### [Module 2: Network Automount Maps & Tuning](./module-02/course.md)
* **Analogy:** Dynamic routing maps for multiple foreign warehouses.
* **Core Topics:** Integrating `autofs` with NFS, writing custom sub-maps, wildcard directory keys, dynamic mapping variables, mount option tuning, and understanding why manually creating target subdirectories destroys the autofs trigger mechanism.

## Lab Exercise

Apply your knowledge in a practical environment:
* **[Lab 050: On-Demand Mounting (autofs)](../../labs/lab-050/README.md)**: Practice replacing static network mounts with dynamic autofs rules, configuring timeout parameters, and troubleshooting failed map triggers.
