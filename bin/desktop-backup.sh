#!/usr/bin/env bash
# desktop-backup.sh — copy selected desktop folders to the NAS over SSH.
# Destination: /volume1/staging/desktop/ (covered by the nightly mirror and snapshots)
# Usage:  desktop-backup.sh            real run
#         desktop-backup.sh --dry-run  show what would change, copy nothing
set -euo pipefail

NAS="cpan@192.168.1.40"
DEST="staging/desktop/"
KEY="$HOME/.ssh/nas_backup"

# Folders to back up, relative to $HOME
FOLDERS=(mathimata ai dotfiles)

DRY=()
[[ "${1:-}" == "--dry-run" ]] && DRY=(--dry-run --itemize-changes)

# 1. Refresh the list of downloaded models, so it travels with the backup
{
  echo "== Generated $(date -Iseconds)"
  echo "== Hugging Face repos in hf-cache"
  ls "$HOME/ai/hf-cache/hub" 2>/dev/null | sed -n 's/^models--//p' | sed 's/--/\//'
  echo
  echo "== GGUF files (name, size in bytes)"
  find "$HOME/ai/models/gguf" -name '*.gguf' -printf '%f\t%s\n' 2>/dev/null | sort
} > "$HOME/ai/MODELS.txt"

# 2. Build source paths with a "/./" marker so --relative keeps only
#    mathimata/... and ai/... on the NAS (not /home/cpan/...)
SRC=()
for f in "${FOLDERS[@]}"; do
  SRC+=("$HOME/./$f")
done

# 3. Copy. --delete removes files deleted on the desktop; the NAS snapshots
#    keep them for 14 days. Excluded paths are never deleted on the NAS.
set +e
rsync -rltp --relative --delete --human-readable --stats "${DRY[@]}" \
  -e "ssh -i $KEY -o BatchMode=yes" \
  --exclude='/ai/hf-cache/' \
  --exclude='/ai/models/' \
  --exclude='/ai/llama.cpp/' \
  --exclude='/ai/llama/llama.cpp/' \
  --exclude='/ai/tmp/' \
  --exclude='.venv/' \
  --exclude='__pycache__/' \
  --exclude='.mypy_cache/' \
  --exclude='.pytest_cache/' \
  --exclude='node_modules/' \
  --exclude='.cache/' \
  "${SRC[@]}" "$NAS:$DEST"
rc=$?
set -e

# Exit code 24 = some files vanished during the copy (normal for files
# that were being written); treat it as success.
if [[ $rc -eq 0 || $rc -eq 24 ]]; then
  echo "Backup finished OK (rsync exit $rc)."
  exit 0
fi
echo "Backup FAILED (rsync exit $rc)." >&2
exit "$rc"
