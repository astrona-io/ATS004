#!/usr/bin/env bash
set -euo pipefail
version=v0.5.11
sha=ce4def8be5e9effa6b6b98e9e963eb5e9197896e77309f3f89d3367a609c6414
curl --fail --location --retry 3 "https://github.com/astrona-io/astrona-cli/releases/download/${version}/astrona-linux-amd64" -o /tmp/astrona
printf '%s  %s\n' "$sha" /tmp/astrona | sha256sum --check
sudo install -m 0755 /tmp/astrona /usr/local/bin/astrona

oras_version=1.3.0
oras_sha=6cdc692f929100feb08aa8de584d02f7bcc30ec7d88bc2adc2054d782db57c64
oras_dir=$(mktemp -d)
trap 'rm -rf "$oras_dir"' EXIT
curl --fail --location --retry 3 "https://github.com/oras-project/oras/releases/download/v${oras_version}/oras_${oras_version}_linux_amd64.tar.gz" -o "$oras_dir/oras.tar.gz"
printf '%s  %s\n' "$oras_sha" "$oras_dir/oras.tar.gz" | sha256sum --check
tar -xzf "$oras_dir/oras.tar.gz" -C "$oras_dir" oras
sudo install -m 0755 "$oras_dir/oras" /usr/local/bin/oras
