#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
USER="u0_a497"
IP="192.168.1.5"
PORT="8022"
# Absolute path to internal storage (avoids symlink issues)
REMOTE_PATH="/storage/emulated/0" 
MOUNT_POINT="$HOME/mnt/tablet"

# ==========================================
# LOGIC
# ==========================================

# Check if mount point exists, create if not
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Check if already mounted
if mount | grep -q "$MOUNT_POINT"; then
    echo "Tablet is currently mounted. Unmounting..."
    fusermount -u "$MOUNT_POINT"
    
    # Notify (Optional - remove if you don't use dunst/notify-send)
    notify-send "Tablet Unmounted" "Connection closed."
else
    echo "Mounting tablet..."
    
    # Mount command
    # -o reconnect: Handles wifi drops
    # -o follow_symlinks: Fixes issues with internal Android links
    sshfs -p $PORT -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,follow_symlinks \
    $USER@$IP:$REMOTE_PATH $MOUNT_POINT

    if [ $? -eq 0 ]; then
        echo "Success!"
        notify-send "Tablet Mounted" "Access at $MOUNT_POINT"
    else
        echo "Failed."
        notify-send "Mount Failed" "Check Wi-Fi, Termux, or SSH keys."
    fi
fi

exit 0

# ==============================================================================
# CLEAN INSTALL / SETUP INSTRUCTIONS
# ==============================================================================
#
# STEP 1: PREPARE ANDROID (TERMUX)
# --------------------------------
# 1. Open Termux on the tablet.
# 2. Update and install SSH:
#    $ pkg update && pkg upgrade
#    $ pkg install openssh
# 3. Set a password (required for first login):
#    $ passwd
# 4. Grant storage permission (Critical for file access):
#    $ termux-setup-storage
# 5. Prevent sleep disconnects (Critical for SSHFS stability):
#    $ termux-wake-lock
# 6. Start the SSH server:
#    $ sshd
# 7. Find your User and IP:
#    $ whoami   (Result goes into USER variable above)
#    $ ifconfig (Look for wlan0 IP, goes into IP variable above)
#
# STEP 2: PREPARE DEBIAN (PC)
# ---------------------------
# 1. Install SSHFS:
#    $ sudo apt install sshfs
# 2. Create the mount folder:
#    $ mkdir -p ~/mnt/tablet
# 3. Generate SSH keys (if you haven't already):
#    $ ssh-keygen -t ed25519
# 4. Copy public key to Tablet (Enables passwordless login):
#    $ ssh-copy-id -p 8022 u0_a497@192.168.1.5
#    (Enter the password you set in Step 1.3)
# 5. Make this script executable:
#    $ chmod +x mount-tablet.sh
#
# STEP 3: USAGE
# -------------
# - Run script once to MOUNT.
# - Run script again to UNMOUNT.
# - If connection freezes, run: fusermount -u ~/mnt/tablet
# ==============================================================================
