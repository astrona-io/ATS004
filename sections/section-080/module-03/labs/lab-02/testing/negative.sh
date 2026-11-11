#!/usr/bin/env bash
set -euo pipefail
sudo xfs_quota -x -c 'limit -g bhard=90m engineers' /srv/xfs-teams
