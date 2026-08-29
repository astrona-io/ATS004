# Network Automount Maps {{title}} Tuning — Playground

- **ID:** PLAYGROUND
- **Slug:** section-050-module-02-playground
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading



A two-VM sandbox (`client` + `nfs` on a private subnet) that spins up, runs OS
prep, and stays running so you can explore network automounting. Nothing to
submit. See [`docs/overview.md`](docs/overview.md) for the topology.

## Run it

```sh
astrona run -c .
astrona destroy section-050-module-02-playground
```

`astrona destroy` takes the environment name (`metadata.name` = `section-050-module-02-playground`), not
the config path. `astrona submit` and `astrona test` do not apply — there is no
grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (two-VM runtime + per-VM bootstrap) |
| `bootstrap/client/` | OS prep for the autofs client VM |
| `bootstrap/nfs/` | OS prep for the NFS server VM |
| `docs/overview.md` | Topology, what is installed, ideas to try |
