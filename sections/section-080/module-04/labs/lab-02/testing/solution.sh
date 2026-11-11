#!/usr/bin/env bash
set -euo pipefail
sudo mkdir -p /etc/acme /var/log/acme /var/lib/acme
sudo mv /srv/staging/acme.conf /etc/acme/
sudo mv /srv/staging/acme-report /usr/local/bin/
sudo mv /srv/staging/acme.log /var/log/acme/
sudo mv /srv/staging/inventory.db /var/lib/acme/
sudo ln /etc/acme/acme.conf /var/lib/acme/acme.conf.keep
sudo ln -s /usr/local/bin/acme-report /usr/local/bin/acme
sudo ln -s /var/log/acme/acme.log /var/lib/acme/current.log
