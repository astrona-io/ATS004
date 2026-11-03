# Where Per-Process I/O Numbers Come From

`pidstat -d` reads one file for each process: `/proc/<PID>/io`. This part opens that file, explains each counter, and shows why two of them differ so much for the same process.

## The counters in `/proc/<PID>/io`

Each crew member keeps a small logbook of what they asked the cargo lift for. Like `/proc/diskstats`, the values are totals that only grow, from the start of the process. This section lists the fields.

### The fields

| Field | What it counts |
| --- | --- |
| `rchar` | Bytes the process asked to read through `read` calls, even if the data came from the page cache |
| `wchar` | Bytes the process asked to write through `write` calls, even if they only reached the cache |
| `syscr` | Number of read calls |
| `syscw` | Number of write calls |
| `read_bytes` | Bytes the process caused to be fetched from the storage layer |
| `write_bytes` | Bytes the process caused to be sent to the storage layer |
| `cancelled_write_bytes` | Bytes of writes that were cancelled, for example when a file was truncated before the data left the cache |

### Why `rchar` and `read_bytes` differ

A read answered from the page cache counts in `rchar` but never reaches the disk, so it does not count in `read_bytes`. A write is counted in `wchar` the moment the process hands it over, and in `write_bytes` only when the kernel sends it on to the disk. The `_bytes` fields are the ones that tell you about real disk work. The `char` fields tell you about the program's own behaviour.

The columns of `pidstat -d` come from these fields: `kB_rd/s` from `read_bytes`, `kB_wr/s` from `write_bytes` and `kB_ccwr/s` from `cancelled_write_bytes`. Reading another user's `/proc/<PID>/io` needs `sudo`.

<!-- astrona:playground:renew -->

### See it in your playground

Start the writer, read its counters twice, and compare.

```sh
start-io-load
PID=<PID>
sudo cat /proc/$PID/io
sleep 2
sudo cat /proc/$PID/io
```

Replace `<PID>` with the number that `start-io-load` printed. Each `cat` prints one line per field, as `name: value`. In the second reading `write_bytes` is larger than in the first, because the writer is still working. Subtract the two values and divide by 2 to get bytes per second, which is the figure `pidstat -d` shows as `kB_wr/s` after a division by 1024.

## Common pitfalls

> [!WARNING]
> - **Reading `wchar` as disk work.** It counts bytes handed to the kernel, not bytes that reached the disk. Use `write_bytes`.
> - **Reading the totals as rates.** The values only grow. A rate needs two reads and a subtraction.
> - **Forgetting `sudo`.** For a process of another user the read fails with "Permission denied".
> - **Expecting the counters after the process ends.** They live and die with `/proc/<PID>/`.
