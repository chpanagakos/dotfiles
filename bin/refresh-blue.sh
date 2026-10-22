#!/usr/bin/env bash
# refresh-blue.sh — update the offline WD Blue (label: blue-offline) from the NAS
# Usage: dock the Blue, switch the dock on, run ./refresh-blue.sh, switch the dock off.
set -euo pipefail

NAS_SHARE="//192.168.1.40/staging"
SRC=/mnt/staging
DST=/mnt/blue
NAS_USER=cpan
STAMP=$(date +%F_%H%M)

read -rp "Refresh the Blue from the NAS now? [y/N] " answer
case "$answer" in
  [yY]|[yY][eE][sS]) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

sudo mkdir -p "$SRC" "$DST"

# 1. Mount the Blue by its label (sdX letters change between plug-ins)
if ! mountpoint -q "$DST"; then
  sudo mount LABEL=blue-offline "$DST"
fi

# 2. Mount the NAS share read-only (asks for the UGOS password)
if ! mountpoint -q "$SRC"; then
  sudo mount -t cifs "$NAS_SHARE" "$SRC" \
    -o ro,username="$NAS_USER",vers=3.0,uid="$(id -u)",gid="$(id -g)"
fi

# 3. Safety checks: both must be real mounts, and the source must not be empty.
#    Without these, a failed mount plus --delete could empty the Blue.
if ! mountpoint -q "$SRC" || ! mountpoint -q "$DST"; then
  echo "A mount is missing — aborting." >&2
  exit 1
fi
if [ -z "$(ls -A "$SRC")" ]; then
  echo "Source $SRC is empty — aborting." >&2
  exit 1
fi

# 4. Copy.
#    --delete removes files from the Blue that no longer exist on the NAS,
#    but --backup moves them (and any overwritten files) into _deleted/<date>
#    instead of destroying them.
#    Excluded paths are never deleted: Music lives only on the Blue.
rsync -rlt --delete --info=progress2 \
  --exclude='/Music/' \
  --exclude='/_deleted/' \
  --exclude='/lost+found/' \
  --backup --backup-dir="$DST/_deleted/$STAMP" \
  "$SRC/" "$DST/"

# 5. Flush and unmount both
sync
sudo umount "$SRC" "$DST"
echo "Done. The Blue is up to date — safe to switch off the dock."
