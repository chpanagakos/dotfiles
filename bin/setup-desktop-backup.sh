#!/usr/bin/env bash
# setup-desktop-backup.sh — install the nightly desktop→NAS backup on this machine.
# Safe to run again: it only creates what's missing and rewrites the timer units.
# Requires: ~/dotfiles/bin/desktop-backup.sh, rsync, openssh-client, systemd.
set -euo pipefail

NAS="cpan@192.168.1.40"
KEY="$HOME/.ssh/nas_backup"
SCRIPT="$HOME/dotfiles/bin/desktop-backup.sh"
UNITS="$HOME/.config/systemd/user"

[[ -x "$SCRIPT" ]] || { echo "Missing or not executable: $SCRIPT" >&2; exit 1; }
command -v rsync >/dev/null || { echo "Install rsync first: sudo apt install rsync" >&2; exit 1; }

# 1. SSH key: reuse if present, otherwise create one and install it on the NAS
if [[ ! -f "$KEY" ]]; then
  echo "Creating backup key $KEY (no passphrase, for unattended runs)…"
  ssh-keygen -t ed25519 -f "$KEY" -N "" -C "desktop-backup@$(hostname)"
  echo "Installing the key on the NAS (asks for your UGOS password once)…"
  ssh-copy-id -i "$KEY.pub" "$NAS"
fi

echo "Testing key login…"
ssh -i "$KEY" -o BatchMode=yes "$NAS" true \
  || { echo "Key login failed. Run: ssh-copy-id -i $KEY.pub $NAS" >&2; exit 1; }

# 2. systemd user units
mkdir -p "$UNITS"

cat > "$UNITS/desktop-backup.service" <<EOF
[Unit]
Description=Back up selected desktop folders to the NAS
StartLimitIntervalSec=2h
StartLimitBurst=4

[Service]
Type=oneshot
ExecStart=$SCRIPT
Restart=on-failure
RestartSec=10min
EOF

cat > "$UNITS/desktop-backup.timer" <<'EOF'
[Unit]
Description=Nightly desktop backup to the NAS

[Timer]
OnCalendar=*-*-* 22:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now desktop-backup.timer

# 3. Keep the user session alive so the timer fires even when logged out
loginctl enable-linger "$USER"

echo
systemctl --user list-timers desktop-backup.timer --no-pager
echo
echo "Done. Test now with:  systemctl --user start desktop-backup.service"
echo "Check the result:     journalctl --user -u desktop-backup -n 5 --no-pager"
