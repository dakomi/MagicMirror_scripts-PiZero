#!/bin/bash
# MagicMirror Automated Installer for Raspberry Pi Zero W/2W
# Automatically downloads, patches, and installs MagicMirror with low-memory optimizations
#
# Usage: bash install-magicmirror-pi-zero.sh
#
# Credits:
# - Original raspberry.sh script by Sam Detweiler (sdetweil)
#   https://github.com/sdetweil/MagicMirror_scripts
# - Pi Zero W browser solution by MerlinElMago
#   https://forum.magicmirror.builders/topic/18200/mm-on-a-raspberry-zero-w-in-2023

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=$(mktemp -d)
PATCH_URL="https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/raspberry-pi-zero.patch"

echo "=========================================="
echo "MagicMirror Pi Zero W/2W Installer"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Download the official MagicMirror installer"
echo "2. Apply low-memory optimizations for Pi Zero"
echo "3. Install MagicMirror with server mode"
echo "4. Set up Python WebKit2 browser for display"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

echo ""
echo "Step 1/4: Downloading official installer..."
cd "$TEMP_DIR"
curl -sL https://raw.githubusercontent.com/sdetweil/MagicMirror_scripts/master/raspberry.sh -o raspberry.sh

echo "Step 2/4: Applying Pi Zero optimizations..."
if [ -f "$SCRIPT_DIR/raspberry-pi-zero.patch" ]; then
    # Use local patch file
    patch raspberry.sh < "$SCRIPT_DIR/raspberry-pi-zero.patch"
else
    # Download patch from GitHub
    echo "Downloading patch file..."
    curl -sL "$PATCH_URL" | patch raspberry.sh
fi

echo "Step 3/4: Running installer..."
echo "NOTE: This will take 30-60 minutes on Pi Zero devices due to limited resources."
bash raspberry.sh

echo ""
echo "Step 4/4: Setting up Python WebKit2 browser..."

# Install Python WebKit2 dependencies
echo "Installing browser dependencies..."
sudo apt-get update
sudo apt-get install -y gir1.2-webkit2-4.1 libgtk-3-dev libwebkit2gtk-4.1-dev python3-gi

# Download or create browser script
if [ -f "$SCRIPT_DIR/mm-browser.py" ]; then
    cp "$SCRIPT_DIR/mm-browser.py" ~/mm-browser.py
else
    cat > ~/mm-browser.py << 'EOF'
import gi
gi.require_version("Gtk", "3.0")
gi.require_version("WebKit2", "4.1")
from gi.repository import Gtk, WebKit2

class Minibrowser(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="MagicMirror²")
        self.set_default_size(800, 600)
        
        web_view = WebKit2.WebView()
        web_view.load_uri("http://localhost:8080")
        
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.add(web_view)
        self.add(scrolled_window)
        self.fullscreen()

if __name__ == "__main__":
    win = Minibrowser()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
EOF
fi

chmod +x ~/mm-browser.py

# Create browser systemd service
echo "Creating browser auto-start service..."
sudo tee /etc/systemd/system/magicmirror-python.service > /dev/null << 'EOF'
[Unit]
Description=MagicMirror Python WebKit2 Browser
After=magicmirror.service
Wants=magicmirror.service

[Service]
Type=simple
User=mm
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/home/mm/.Xauthority"
Environment="XDG_RUNTIME_DIR=/run/user/1000"
ExecStartPre=/bin/sleep 60
ExecStart=/usr/bin/python3 /home/mm/mm-browser.py
Restart=always
RestartSec=10

[Install]
WantedBy=graphical.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable magicmirror-python.service
sudo systemctl start magicmirror-python.service

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "MagicMirror is now running on your Pi Zero!"
echo ""
echo "Access it at:"
echo "  - Local display: Should be showing now"
echo "  - Network: http://$(hostname -I | awk '{print $1}'):8080"
echo "  - Hostname: http://$(hostname).local:8080"
echo ""
echo "To check status:"
echo "  sudo systemctl status magicmirror.service"
echo "  sudo systemctl status magicmirror-python.service"
echo ""
echo "Configuration file:"
echo "  ~/MagicMirror/config/config.js"
echo ""
