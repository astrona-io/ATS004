#!/usr/bin/env bash
# OS prep for the "Inside /proc" playground.
# Runs once at startup. Environment preparation only — no task, no grading.
# Seeds two files for a demo process to hold open, plus a helper that starts
# a `tail -f` on both so /proc/<PID>/fd/ has something interesting to show.
set -euo pipefail

sudo mkdir -p /srv/demo
echo "log line A" | sudo tee /srv/demo/one.log >/dev/null
echo "log line B" | sudo tee /srv/demo/two.log >/dev/null
sudo chmod 644 /srv/demo/*.log

sudo tee /usr/local/bin/start-demo-proc >/dev/null <<'EOF'
#!/usr/bin/env bash
# Start a long-lived process that holds a few file descriptors open, and
# print its PID. Re-run to start another; `pkill -f 'tail -F /srv/demo'` to stop.
tail -F /srv/demo/one.log /srv/demo/two.log >/tmp/demo-proc.out 2>&1 &
echo "demo process PID: $!"
EOF
sudo chmod +x /usr/local/bin/start-demo-proc

echo "[playground] ready. Run 'start-demo-proc' to launch a process to inspect under /proc/<PID>/."
