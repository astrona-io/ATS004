# Question

Solve this question on: `terminal`

A rogue process is hammering the local hard drive with aggressive write operations.

1. Use process-level performance tools (e.g. `iotop -o`) to identify the **PID** of the process responsible for generating the heavy write loads.
2. Use files/processes mappings (e.g. `lsof`) to identify the absolute file path of the log file being written to by this process.
3. Write your findings to `/opt/course/audit/culprit.txt` with:
   - The process PID on the **first** line.
   - The absolute file path of the active log file on the **second** line.
<!-- curriculum-links -->

## Related lessons and assessment

Read [module-02](../../course.md).

The grader checks:

- Confirms proper profiling of the rogue writing process and target file.

Use the inspection commands in the solution to check your work. Submit when you have finished; submission ends this environment.
