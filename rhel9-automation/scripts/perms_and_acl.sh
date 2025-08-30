#!/usr/bin/env bash
set -Eeuo pipefail
usage() { echo 'Usage: perms_and_acl.sh --path <dir> --owner <user> --group <group> [--mode <octal>] [--acl "<rules>"]'; }
command -v setfacl >/dev/null || { echo "Installing 'acl' package..."; dnf -y install acl >/dev/null 2>&1 || true; }
path="" owner="" group="" mode="" acl_rules=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) path="$2"; shift 2;;
    --owner) owner="$2"; shift 2;;
    --group) group="$2"; shift 2;;
    --mode) mode="$2"; shift 2;;
    --acl) acl_rules="$2"; shift 2;;
    --help) usage; exit 0;;
    *) echo "Unknown $1"; usage; exit 1;;
  esac
done
[[ -n "$path" && -n "$owner" && -n "$group" ]] || { usage; exit 1; }
mkdir -p "$path"
chown "$owner:$group" "$path"
[[ -n "$mode" ]] && chmod "$mode" "$path"
if [[ -n "$acl_rules" ]]; then IFS=',' read -ra rules <<<"$acl_rules"; for r in "${rules[@]}"; do setfacl -m "$r" "$path"; done; fi
echo "Configured $path (owner=$owner group=$group mode=${mode:-keep} acl=${acl_rules:-none})"
