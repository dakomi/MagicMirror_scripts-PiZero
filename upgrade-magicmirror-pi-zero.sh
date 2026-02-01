#!/bin/bash
# MagicMirror Upgrade Script for Raspberry Pi Zero W/2W
# Automatically downloads, patches, and runs the upgrade script with low-memory optimizations
#
# Usage: bash upgrade-magicmirror-pi-zero.sh
#
# Credits:
# - Original upgrade-script.sh by Sam Detweiler (sdetweil)
#   https://github.com/sdetweil/MagicMirror_scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=$(mktemp -d)
PATCH_URL="https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/MagicMirror%20RPi%200%20Script%20Patches/upgrade-pi-zero.patch"

echo "=========================================="
echo "MagicMirror Pi Zero W/2W Upgrade Script"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Download the official MagicMirror upgrade script"
echo "2. Apply low-memory optimizations for Pi Zero"
echo "3. Upgrade MagicMirror safely"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Upgrade cancelled."
    exit 1
fi

echo ""
echo "Step 1/2: Downloading official upgrade script..."
cd "$TEMP_DIR"
curl -sL https://raw.githubusercontent.com/sdetweil/MagicMirror_scripts/master/upgrade-script.sh -o upgrade-script.sh

echo "Step 2/2: Applying Pi Zero optimizations..."
if [ -f "$SCRIPT_DIR/upgrade-pi-zero.patch" ]; then
    # Use local patch file
    patch upgrade-script.sh < "$SCRIPT_DIR/upgrade-pi-zero.patch"
else
    # Download patch from GitHub
    echo "Downloading patch file..."
    curl -sL "$PATCH_URL" | patch upgrade-script.sh
fi

echo ""
echo "Running upgrade script..."
bash upgrade-script.sh

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "=========================================="
echo "Upgrade Complete!"
echo "=========================================="
echo ""
