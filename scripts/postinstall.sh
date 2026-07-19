#!/bin/bash
# ==============================================================================
# Postinstall hook for the aravinds-productive-terminal package.
#
# apt/dnf run this as root, so we can't rely on $HOME. Instead we detect the
# real invoking user (the person who ran `sudo apt install` / `sudo dnf
# install`) and apply the shell environment to *their* home directory.
# ==============================================================================
set -euo pipefail

INSTALL_SCRIPT="/usr/share/aravinds-productive-terminal/install.sh"

# Determine the real (non-root) user who triggered the install.
TARGET_USER="${SUDO_USER:-}"
if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
    TARGET_USER="$(logname 2>/dev/null || true)"
fi

if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
    echo "=========================================================="
    echo "⚠️  Could not detect a non-root invoking user."
    echo "Skipping automatic shell setup."
    echo "Run it yourself with:"
    echo "    bash $INSTALL_SCRIPT"
    echo "=========================================================="
    exit 0
fi

TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
if [ -z "$TARGET_HOME" ] || [ ! -d "$TARGET_HOME" ]; then
    echo "⚠️  Could not resolve home directory for user '$TARGET_USER'. Skipping automatic setup."
    exit 0
fi

echo "=========================================================="
echo "🌟 Configuring aravinds-productive-terminal for user: $TARGET_USER"
echo "=========================================================="

# Run the installer as the target user so all files land in their home
# directory (and asdf/npm/etc. state lives with the right owner).
runuser -u "$TARGET_USER" -- bash "$INSTALL_SCRIPT" || {
    echo "⚠️  Automatic setup failed. You can re-run it manually with:"
    echo "    bash $INSTALL_SCRIPT"
    exit 0
}

exit 0
