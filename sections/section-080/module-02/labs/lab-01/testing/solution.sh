#!/usr/bin/env bash
set -euo pipefail
sudo quotacheck -cugv /quota
sudo quotaon -v /quota
sudo setquota -u alice 40M 50M 0 0 /quota
sudo setquota -u bob 20M 30M 0 0 /quota
sudo setquota -g team 100M 120M 0 0 /quota
