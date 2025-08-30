#!/usr/bin/env bash
set -Eeuo pipefail
systemctl enable --now chronyd
systemctl enable --now firewalld
SSHD_CFG="/etc/ssh/sshd_config"
if ! grep -q "^PermitRootLogin" "$SSHD_CFG"; then echo "PermitRootLogin prohibit-password" >> "$SSHD_CFG"; else sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/' "$SSHD_CFG"; fi
systemctl restart sshd
sestatus || true
echo "Enabled chronyd/firewalld, hardened SSH, checked SELinux."
