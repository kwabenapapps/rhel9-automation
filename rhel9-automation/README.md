# RHEL 9 System Administration & Automation

These Bash scripts are written in a modern, safe style (`set -Eeuo pipefail`) and are idempotent where possible.
Run with care—review before executing.

Scripts:
- user_mgmt.sh — create users/groups, lock/unlock, expiry.
- perms_and_acl.sh — set permissions, ownership, and ACLs.
- network_setup.sh — configure a static IP with nmcli; basic firewall rules.
- storage_stratis_setup.sh — create a Stratis pool/filesystem and mount it persistently via /etc/fstab.
- services_hardening.sh — enable core services, basic SSH hardening, SELinux check.
- system_health.sh — quick host health report.
