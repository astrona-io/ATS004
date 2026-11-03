# Network Block Devices: NBD and iSCSI - Playground

- **ID:** PLAYGROUND
- **Slug:** section-020-module-03-playground
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading

A two-VM sandbox (`server` and `client` on a private subnet) that spins up,
runs OS prep, and stays running so you can practise the client side of
network block devices on a clean machine. Nothing to submit. See
[`docs/overview.md`](docs/overview.md) for the topology.

## Run it

```sh
astrona run -c .
astrona destroy section-020-module-03-playground
```

`astrona destroy` takes the environment name (`metadata.name` =
`section-020-module-03-playground`), not the config path. `astrona submit` and
`astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (two-VM runtime and per-VM bootstrap) |
| `bootstrap/server/` | OS prep for the target VM (iSCSI and NBD) |
| `bootstrap/client/` | OS prep for the client VM |
| `docs/overview.md` | Topology, what is installed, ideas to try |
