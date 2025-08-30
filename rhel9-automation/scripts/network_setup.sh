#!/usr/bin/env bash
set -Eeuo pipefail
usage() { echo "Usage: $0 --conn <nm-conn> --ip <CIDR> --gw <gateway> [--dns comma,list]"; }
command -v nmcli >/dev/null || { echo "nmcli not found"; exit 1; }
command -v firewall-cmd >/dev/null || { echo "firewalld not found"; exit 1; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --conn) CONN="$2"; shift 2;;
    --ip) IP="$2"; shift 2;;
    --gw) GW="$2"; shift 2;;
    --dns) DNS="$2"; shift 2;;
    --help) usage; exit 0;;
    *) echo "Unknown $1"; usage; exit 1;;
  esac
done
: "${CONN:?--conn required}"; : "${IP:?--ip required}"; : "${GW:?--gw required}"
nmcli con mod "$CONN" ipv4.addresses "$IP"
nmcli con mod "$CONN" ipv4.gateway "$GW"
nmcli con mod "$CONN" ipv4.method manual
[[ -n "${DNS:-}" ]] && nmcli con mod "$CONN" ipv4.dns "$DNS"
nmcli con down "$CONN" || true
nmcli con up "$CONN"
systemctl enable --now firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
echo "Network configured on $CONN ($IP gw=$GW dns=${DNS:-system}). Opened firewall for ssh/http."
