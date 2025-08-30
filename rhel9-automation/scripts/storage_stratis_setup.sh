#!/usr/bin/env bash
set -Eeuo pipefail
# Example: sudo ./storage_stratis_setup.sh --device /dev/vdb --pool pool1 --fs datafs --mount /data
usage() { echo 'Usage: storage_stratis_setup.sh --device /dev/vdb --pool <pool> --fs <fs> --mount </mnt> [--xfs|--ext4]'; }
DEVICE="" POOL="" FS="" MOUNT="" FSTYPE="xfs"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) DEVICE="$2"; shift 2;;
    --pool) POOL="$2"; shift 2;;
    --fs) FS="$2"; shift 2;;
    --mount) MOUNT="$2"; shift 2;;
    --xfs) FSTYPE="xfs"; shift 1;;
    --ext4) FSTYPE="ext4"; shift 1;;
    --help) usage; exit 0;;
    *) echo "Unknown $1"; usage; exit 1;;
  esac
done
[[ -n "$DEVICE" && -n "$POOL" && -n "$FS" && -n "$MOUNT" ]] || { usage; exit 1; }
dnf -y install stratisd stratis-cli >/dev/null 2>&1 || true
systemctl enable --now stratisd
if ! stratis pool list | awk 'NR>1{print $1}' | grep -q "^${POOL}$"; then stratis pool create "$POOL" "$DEVICE"; fi
if ! stratis fs list "$POOL" | awk 'NR>1{print $1}' | grep -q "^${FS}$"; then stratis fs create "$POOL" "$FS"; fi
DEV_PATH=$(stratis fs list "$POOL" | awk -v fs="$FS" '$1==fs{print $5}')
[[ -n "$DEV_PATH" ]] || { echo "Failed to resolve device path"; exit 1; }
if ! blkid "$DEV_PATH" >/dev/null 2>&1; then mkfs."$FSTYPE" -L "${POOL}_${FS}" "$DEV_PATH"; fi
mkdir -p "$MOUNT"
UUID=$(blkid -s UUID -o value "$DEV_PATH")
FSTAB_LINE="UUID=${UUID}  ${MOUNT}  ${FSTYPE}  defaults,x-systemd.requires=stratisd.service  0 0"
grep -q "$UUID" /etc/fstab || echo "$FSTAB_LINE" >> /etc/fstab
mountpoint -q "$MOUNT" || mount "$MOUNT"
echo "Mounted Stratis FS at $MOUNT (UUID=$UUID) and persisted to /etc/fstab."
