#!/usr/bin/env bash
set -Eeuo pipefail
usage() {
  cat <<'USAGE'
Usage: user_mgmt.sh [command] [options]
Commands:
  create-user   --user <name> [--groups <g1,g2>] [--shell /bin/bash] [--home /home/name]
  add-to-group  --user <name> --group <group>
  lock          --user <name>
  unlock        --user <name>
  expire        --user <name> --date YYYY-MM-DD
  help
USAGE
}
ensure_cmds() { for c in useradd usermod chage getent; do command -v "$c" >/dev/null || { echo "Missing $c"; exit 1; }; done; }
create_user() {
  local user="" groups="" shell="/bin/bash" home=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --user) user="$2"; shift 2;;
      --groups) groups="$2"; shift 2;;
      --shell) shell="$2"; shift 2;;
      --home) home="$2"; shift 2;;
      *) echo "Unknown: $1"; exit 1;;
    esac
  done
  [[ -n "$user" ]] || { echo "--user required"; exit 1; }
  if id "$user" &>/dev/null; then echo "User $user exists"; else
    if [[ -n "$home" ]]; then useradd -m -d "$home" -s "$shell" "$user"; else useradd -m -s "$shell" "$user"; fi
    echo "Created $user"
  fi
  if [[ -n "$groups" ]]; then IFS=',' read -ra gs <<<"$groups"; for g in "${gs[@]}"; do getent group "$g" >/dev/null || groupadd "$g"; usermod -aG "$g" "$user"; done; fi
}
add_to_group() { local user="" group=""; while [[ $# -gt 0 ]]; do case "$1" in --user) user="$2"; shift 2;; --group) group="$2"; shift 2;; *) echo "Unknown $1"; exit 1;; esac; done; [[ -n "$user" && -n "$group" ]] || { echo "need --user and --group"; exit 1; }; getent group "$group" >/dev/null || groupadd "$group"; usermod -aG "$group" "$user"; }
lock_user() { local user="$2"; passwd -l "$user"; }
unlock_user() { local user="$2"; passwd -u "$user"; }
expire_user() { local user="$2"; local date="$4"; chage -E "$date" "$user"; }
main() { ensure_cmds; local cmd="${1:-help}"; shift || true; case "$cmd" in create-user) create_user "$@";; add-to-group) add_to_group "$@";; lock) lock_user "$@";; unlock) unlock_user "$@";; expire) expire_user "$@";; help|*) usage;; esac; }
main "$@"
