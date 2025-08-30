#!/usr/bin/env bash
set -Eeuo pipefail
echo "=== Host Health Summary ($(hostname)) ==="
echo "-- Uptime --"; uptime
echo "-- CPU --"; lscpu | grep -E 'Model name|CPU\(s\)'
echo "-- Memory --"; free -h
echo "-- Disk --"; lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
echo "-- Filesystem usage --"; df -hT | awk 'NR==1 || $7 ~ /^\//'
echo "-- Network --"; ip -brief addr
echo "-- Services (sshd, firewalld, chronyd) --"; systemctl is-active sshd firewalld chronyd || true
echo "-- Top 5 CPU processes --"; ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
