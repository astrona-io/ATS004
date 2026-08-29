#!/usr/bin/env bash
# OS prep for the "Symbolic Links & FHS" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# The system already has the usrmerge symlinks (/bin, /sbin, /lib -> usr/...).
# This adds a sample release layout to inspect and a DISPOSABLE /tmp/rmdemo
# with a reset helper, so the trailing-slash rm behaviour can be tried safely.
set -euo pipefail

# A realistic "current release" symlink to resolve and inspect (read-only use).
sudo mkdir -p /srv/releases/v1 /srv/releases/v2 /srv/www
echo "v1 index" | sudo tee /srv/releases/v1/index.html >/dev/null
echo "v2 index" | sudo tee /srv/releases/v2/index.html >/dev/null
sudo ln -sfn /srv/releases/v2 /srv/www/active

# Disposable demo for the trailing-slash lesson, plus a rebuild command.
sudo tee /usr/local/bin/reset-symlink-demo >/dev/null <<'EOF'
#!/usr/bin/env bash
# (Re)build /tmp/rmdemo: a real directory with two files, and a symlink to it.
set -eu
rm -rf /tmp/rmdemo
mkdir -p /tmp/rmdemo/real
echo "important A" > /tmp/rmdemo/real/a.txt
echo "important B" > /tmp/rmdemo/real/b.txt
ln -s /tmp/rmdemo/real /tmp/rmdemo/link
echo "rebuilt: /tmp/rmdemo/real (2 files) and /tmp/rmdemo/link -> /tmp/rmdemo/real"
EOF
sudo chmod +x /usr/local/bin/reset-symlink-demo
reset-symlink-demo

echo "[playground] ready:"
echo "  /srv/www/active -> /srv/releases/v2   (sample release symlink)"
echo "  /tmp/rmdemo/{real,link}               (disposable; rebuild with reset-symlink-demo)"
