# MagicMirror for Raspberry Pi Zero W & Zero 2W

Complete installation and troubleshooting resources for running [MagicMirror²](https://magicmirror.builders/) on ultra-low-memory Raspberry Pi Zero devices (256MB - 512MB RAM).

## Overview

This repository provides **automated installation scripts** that:
- Download and patch [sdetweil's MagicMirror installer scripts](https://github.com/sdetweil/MagicMirror_scripts) with Pi Zero optimizations
- Install a lightweight Python WebKit2 browser by [MerlinElMago](https://forum.magicmirror.builders/topic/18200/mm-on-a-raspberry-zero-w-in-2023)
- Apply critical memory optimizations for ultra-low-RAM devices
- Configure auto-start services for seamless operation

**Result:** MagicMirror running smoothly on devices with as little as 256MB RAM!*  
*\* Pi Zero (256MB RAM) may need a more lightweight OS*

---

## 📋 Table of Contents

- [Quick Start](#-quick-start)
  - [Fresh Installation](#fresh-installation)
  - [Upgrading Existing Installation](#upgrading-existing-installation)
- [What's Included](#-whats-included)
- [Installation Guide](#-installation-guide)
  - [Prerequisites](#prerequisites)
  - [Automated Installation](#automated-installation)
  - [Manual Installation](#manual-installation)
- [Troubleshooting](#-troubleshooting)
  - [Out of Memory Errors](#out-of-memory-errors)
  - [Browser Crashes](#browser-crashes)
  - [Display Issues](#display-issues)
- [Technical Details](#-technical-details)
  - [Memory Optimizations](#memory-optimizations)
  - [Python WebKit2 Browser](#python-webkit2-browser)
  - [System Configuration](#system-configuration)
- [Credits](#-credits)
- [License](#-license)

---

## 🚀 Quick Start

### Fresh Installation

**One-line automated install:**
```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/MagicMirror%20RPi%200%20Script%20Patches/install-magicmirror-pi-zero.sh)"
```

**Or download and run locally:**
```bash
git clone https://github.com/dakomi/MagicMirror_scripts-PiZero.git
cd "MagicMirror_scripts-PiZero/MagicMirror RPi 0 Script Patches"
bash install-magicmirror-pi-zero.sh
```

### Upgrading Existing Installation

```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/MagicMirror%20RPi%200%20Script%20Patches/upgrade-magicmirror-pi-zero.sh)"
```

---

## 📦 What's Included

| File | Description |
|------|-------------|
| `install-magicmirror-pi-zero.sh` | Automated installer with Pi Zero optimizations |
| `upgrade-magicmirror-pi-zero.sh` | Automated upgrade script for existing installations |
| `mm-browser.py` | Lightweight Python WebKit2 browser (proven to work on 256MB RAM!) |
| `raspberry-pi-zero.patch` | Patch for raspberry.sh installer script |
| `upgrade-pi-zero.patch` | Patch for upgrade-script.sh |
| `QUICK_REFERENCE.md` | Command cheat sheet for quick lookups |
| `README.md` | This file |

---

## 📖 Installation Guide

### Prerequisites

**Hardware:**
- Raspberry Pi Zero W (256MB RAM) or Pi Zero 2W (512MB RAM)
- MicroSD card (16GB+ recommended)
- HDMI display (for local viewing)
- Power supply

**Software:**
- Raspberry Pi OS Lite or Desktop (64-bit recommended for Pi Zero 2W)
- Internet connection during installation

### Automated Installation

The automated installer handles everything:

1. **Download and run the installer:**
   ```bash
   bash -c "$(curl -sL https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/MagicMirror%20RPi%200%20Script%20Patches/install-magicmirror-pi-zero.sh)"
   ```

2. **Wait for completion (30-60 minutes on Pi Zero)**
   - The script applies memory optimizations automatically
   - Downloads and patches the official MagicMirror installer
   - Installs MagicMirror in server mode
   - Sets up the Python WebKit2 browser
   - Configures auto-start services

3. **Access your MagicMirror:**
   - Local display: Should show automatically
   - Network: `http://YOUR_PI_IP:8080`
   - Hostname: `http://raspberrypi.local:8080`

### Manual Installation

If you prefer manual control or the automated script fails:

#### Step 1: System Optimization

Apply memory optimizations before installation:

```bash
# Reduce swap usage and cache pressure
sudo sysctl vm.swappiness=10 vm.vfs_cache_pressure=50 vm.overcommit_memory=1

# Make persistent
echo 'vm.swappiness=10
vm.vfs_cache_pressure=50
vm.overcommit_memory=1' | sudo tee -a /etc/sysctl.conf
```

#### Step 2: Install MagicMirror

**Option A: Using patched installer**

```bash
# Download official installer
curl -sL https://raw.githubusercontent.com/sdetweil/MagicMirror_scripts/master/raspberry.sh -o raspberry.sh

# Download and apply patch
curl -sL https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/MagicMirror%20RPi%200%20Script%20Patches/raspberry-pi-zero.patch | patch raspberry.sh

# Run installer
bash raspberry.sh
```

**Option B: Manual npm install (if installer fails)**

```bash
# Clone MagicMirror
git clone --depth=1 https://github.com/MagicMirrorOrg/MagicMirror.git
cd MagicMirror

# Install with extreme memory constraints
export NODE_OPTIONS="--max-old-space-size=192"
export npm_config_jobs=1
export npm_config_maxsockets=1
npm install --production --omit=dev --no-audit --no-fund --prefer-offline

# Copy sample config
cp config/config.js.sample config/config.js
```

#### Step 3: Configure Server Mode

Edit `~/MagicMirror/config/config.js`:

```javascript
let config = {
    address: "0.0.0.0",    // Listen on all interfaces
    port: 8080,
    ipWhitelist: [],       // Allow all IPs
    // ... rest of config
};
```

#### Step 4: Install Python Browser

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y gir1.2-webkit2-4.1 libgtk-3-dev libwebkit2gtk-4.1-dev python3-gi

# Download browser script
curl -sL https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/MagicMirror%20RPi%200%20Script%20Patches/mm-browser.py -o ~/mm-browser.py
chmod +x ~/mm-browser.py

# Test browser
DISPLAY=:0 python3 ~/mm-browser.py
```

#### Step 5: Setup Auto-Start Services

**Create MagicMirror server service:**

```bash
sudo tee /etc/systemd/system/magicmirror.service > /dev/null << 'EOF'
[Unit]
Description=MagicMirror Server
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/MagicMirror
Environment="NODE_OPTIONS=--max-old-space-size=192"
Environment="NODE_ENV=production"
ExecStart=/usr/bin/npm run server
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```

**Create browser service:**

```bash
sudo tee /etc/systemd/system/magicmirror-python.service > /dev/null << 'EOF'
[Unit]
Description=MagicMirror Python WebKit2 Browser
After=magicmirror.service
Wants=magicmirror.service

[Service]
Type=simple
User=pi
Environment="DISPLAY=:0"
ExecStartPre=/bin/sleep 60
ExecStart=/usr/bin/python3 /home/pi/mm-browser.py
Restart=always
RestartSec=10

[Install]
WantedBy=graphical.target
EOF
```

**Enable and start services:**

```bash
sudo systemctl daemon-reload
sudo systemctl enable magicmirror.service magicmirror-python.service
sudo systemctl start magicmirror.service magicmirror-python.service
```

---

## 🔧 Troubleshooting

### Out of Memory Errors

**Symptom:** Installation crashes with "ENOMEM" or "killed" errors

**Solutions:**

1. **Verify memory optimizations are applied:**
   ```bash
   sysctl vm.swappiness vm.vfs_cache_pressure vm.overcommit_memory
   ```

2. **Check NODE_OPTIONS is set:**
   ```bash
   echo $NODE_OPTIONS  # Should show --max-old-space-size=192
   ```

3. **Increase swap space (temporary):**
   ```bash
   sudo dphys-swapfile swapoff
   sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile
   sudo dphys-swapfile setup
   sudo dphys-swapfile swapon
   ```

4. **Use single-threaded npm install:**
   ```bash
   export npm_config_jobs=1
   export npm_config_maxsockets=1
   ```

### Browser Crashes

**Symptom:** Display goes black or reloads every few minutes

**Solutions:**

1. **Switch to Python WebKit2 browser** (recommended):
   - More stable than Chromium or Surf on low-memory devices
   - Proven to work on Pi Zero W (256MB RAM)
   - See [Manual Installation Step 4](#step-4-install-python-browser)

2. **Adjust GPU memory** (if using config.txt on SD card):
   ```bash
   # Edit /boot/firmware/config.txt
   gpu_mem=64        # Reduce from default
   dtoverlay=vc4-kms-v3d  # Use full KMS driver
   ```

3. **Check for GPU allocation errors:**
   ```bash
   journalctl -b | grep -E "Failed to allocate|vc4-drm|GPU"
   ```

### Display Issues

**Symptom:** Browser shows blank screen or doesn't start

**Solutions:**

1. **Verify MagicMirror server is running:**
   ```bash
   curl http://localhost:8080
   systemctl status magicmirror.service
   ```

2. **Check DISPLAY environment variable:**
   ```bash
   echo $DISPLAY  # Should show :0
   export DISPLAY=:0  # Set if empty
   ```

3. **Test browser manually:**
   ```bash
   DISPLAY=:0 python3 ~/mm-browser.py
   ```

4. **Check service logs:**
   ```bash
   journalctl -u magicmirror-python.service -f
   journalctl -u magicmirror.service -f
   ```

---

## 🔬 Technical Details

### Memory Optimizations

The patches apply these critical optimizations for Pi Zero devices:

**Detection Logic:**
```bash
if [ $(free -m | grep Mem | awk '{print $2}') -le 512 ]; then
    # Apply Pi Zero optimizations
fi
```

**Node.js Heap Limit:**
- Default: 4096MB (crashes on Pi Zero)
- Pi Zero: 192MB (leaves room for system and browser)

**npm Configuration:**
- `npm_config_jobs=1` - Single-threaded builds
- `npm_config_maxsockets=1` - One connection at a time
- `--no-audit --no-fund --prefer-offline` - Skip unnecessary operations

**System Settings:**
```bash
vm.swappiness=10              # Reduce aggressive swap usage
vm.vfs_cache_pressure=50      # Reduce filesystem cache pressure
vm.overcommit_memory=1        # Allow memory overcommit
```

### Python WebKit2 Browser

**Why Python WebKit2 instead of Chromium/Surf?**

| Browser | RAM Usage | Pi Zero W (256MB) | Pi Zero 2W (512MB) | Notes |
|---------|-----------|-------------------|-------------------|-------|
| Chromium | 200-300MB+ | ❌ Crashes | ⚠️ Unstable | Too heavy |
| Surf | 80-120MB | ⚠️ Crashes | ⚠️ GPU errors | Better but unstable |
| Python WebKit2 | ~84MB | ✅ Stable | ✅ Stable | **Recommended** |
| NetSurf | 5-10MB | ❌ No JS support | ❌ No JS support | Can't render MM |

**Memory Breakdown (Python WebKit2):**
- Python process: ~17MB
- WebKitWebProcess: ~67MB
- WebKitNetworkProcess: ~10MB
- **Total: ~94MB** (vs Chromium's 200-300MB+)

**Technical Implementation:**

The browser uses GTK3's WebKit2 bindings, which provide:
- Full JavaScript support (ES6+, Socket.io, etc.)
- Hardware-accelerated rendering
- Minimal memory overhead
- Native GTK integration

**Source:**
Based on successful implementation by MerlinElMago for Pi Zero W:
https://forum.magicmirror.builders/topic/18200/mm-on-a-raspberry-zero-w-in-2023

### System Configuration

**Recommended Pi Zero 2W config.txt settings:**

```ini
# GPU Memory (in /boot/firmware/config.txt)
gpu_mem=64

# Graphics Driver
dtoverlay=vc4-kms-v3d

# Optional: Disable Bluetooth if not needed
dtoverlay=disable-bt
```

**Service Dependencies:**

```
magicmirror.service (Node.js server)
         ↓
magicmirror-python.service (Display browser)
```

The browser service waits 60 seconds for the server to fully start before launching.

---

## 🙏 Credits

This project builds upon the excellent work of:

### Original Scripts
- **Sam Detweiler (sdetweil)** - Original MagicMirror installation scripts
  - Repository: https://github.com/sdetweil/MagicMirror_scripts
  - These patches modify his scripts with Pi Zero optimizations

### Browser Solution
- **MerlinElMago** - Python WebKit2 browser for Pi Zero W
  - Forum post: https://forum.magicmirror.builders/topic/18200/mm-on-a-raspberry-zero-w-in-2023
  - Proved that MagicMirror can run on 256MB RAM devices

### MagicMirror Project
- **Michael Teeuw** - Creator of MagicMirror²
  - Website: https://magicmirror.builders/
  - Repository: https://github.com/MagicMirrorOrg/MagicMirror

### Community
- **MagicMirror Forum Community** - For troubleshooting discussions and solutions
  - Forum: https://forum.magicmirror.builders/

---

## 📄 License

These patches and scripts are provided as-is under the MIT License.

The original MagicMirror installer scripts by sdetweil maintain their original license.
The MagicMirror² software maintains its original MIT License.

---

## 🤝 Contributing

Found a better optimization? Have a fix for an issue? Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with description of changes

---

## 📞 Support

**Having issues?**

1. Check the [Troubleshooting](#-troubleshooting) section
2. Search the [MagicMirror Forum](https://forum.magicmirror.builders/)
3. Open an issue on GitHub with:
   - Pi model (Zero W or Zero 2W)
   - OS version (`cat /etc/os-release`)
   - Error messages from logs
   - RAM available (`free -h`)

---

**Last Updated:** February 2026  
**Tested On:** Raspberry Pi Zero 2W (512MB), Raspberry Pi OS Bookworm (64-bit)  
**MagicMirror Version:** 2.34.0+
