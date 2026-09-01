# Question

Solve this question on: `terminal` (playing the role of `data-002` from the scenario)

Data-processing jobs on `data-002` have become noticeably slower over the past hour, and you suspect disk I/O is the bottleneck rather than CPU or memory. Without changing any configuration, investigate and determine:

Which block device shows high utilization and/or high wait time.

Which running process is generating the I/O load on that device.

Whether the load is read-bound or write-bound.

Which mountpoint/filesystem the busy device backs, so the finding can be reported meaningfully to the team.

Record your findings in `/opt/course/audit/io-report.txt`, one `key: value` line each for `device`, `pid`, `process`, `direction` (read or write), and `mountpoint`.
