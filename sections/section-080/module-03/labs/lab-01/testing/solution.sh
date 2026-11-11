#!/usr/bin/env bash
set -euo pipefail
sudo xfs_quota -x -c 'limit bsoft=40m bhard=50m alice' /srv/xfs
printf '%s
' '42:/srv/xfs/webdata' | sudo tee -a /etc/projects
printf '%s
' 'webdata:42' | sudo tee -a /etc/projid
sudo xfs_quota -x -c 'project -s webdata' /srv/xfs
sudo xfs_quota -x -c 'limit -p bhard=100m webdata' /srv/xfs
