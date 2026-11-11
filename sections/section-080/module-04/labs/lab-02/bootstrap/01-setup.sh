#!/usr/bin/env bash
# Match the account used by astrona ssh, including its home and permissions.
sudo -H -u student bash <<'ASTRONA_STUDENT_SCRIPT'
# Bootstrap: four files for an imaginary "acme" service sit in /srv/staging.
# Moving them to their FHS places and linking them are the graded tasks.
set -eu

if ! command -v quotacheck >/dev/null; then
  sudo apt-get update -y
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y quota
fi

sudo mkdir -p /srv/staging
sudo tee /srv/staging/acme.conf > /dev/null <<'CONF'
# acme settings
listen_port = 8080
CONF
sudo tee /srv/staging/acme-report > /dev/null <<'SCRIPT'
#!/usr/bin/env bash
echo "acme report: all systems nominal"
SCRIPT
echo "2026-01-01 acme started" | sudo tee /srv/staging/acme.log > /dev/null
echo "item-1,item-2,item-3" | sudo tee /srv/staging/inventory.db > /dev/null
sudo chmod 755 /srv/staging/acme-report
sudo chmod 644 /srv/staging/acme.conf /srv/staging/acme.log /srv/staging/inventory.db

# Make sure the target places do not exist yet.
sudo rm -rf /etc/acme /var/log/acme /var/lib/acme /usr/local/bin/acme-report /usr/local/bin/acme
ASTRONA_STUDENT_SCRIPT
