#!/usr/bin/env bash
set -euo pipefail
sudo xfs_quota -x -c 'limit -g bhard=80m engineers' /srv/xfs-teams
