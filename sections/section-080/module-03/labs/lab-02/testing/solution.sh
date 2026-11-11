#!/usr/bin/env bash
set -euo pipefail
sudo edquota -p alice bob carol
sudo xfs_quota -x -c 'limit -g bsoft=50m bhard=80m engineers' /srv/xfs-teams
sudo xfs_quota -x -c 'timer -g -b 3days' /srv/xfs-teams
