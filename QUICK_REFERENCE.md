# Quick Reference - MagicMirror Pi Zero

## One-Line Install Commands

### Fresh Installation
```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/install-magicmirror-pi-zero.sh)"
```

### Upgrade Existing
```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/dakomi/MagicMirror_scripts-PiZero/main/upgrade-magicmirror-pi-zero.sh)"
```

## Service Management

```bash
# Check status
sudo systemctl status magicmirror.service
sudo systemctl status magicmirror-python.service

# Restart services
sudo systemctl restart magicmirror.service
sudo systemctl restart magicmirror-python.service

# View logs
journalctl -u magicmirror.service -f
journalctl -u magicmirror-python.service -f
```

## Troubleshooting Commands

```bash
# Check memory usage
free -h
htop

# Check GPU memory
vcgencmd get_mem arm
vcgencmd get_mem gpu

# Check for GPU errors
journalctl -b | grep -E "Failed to allocate|vc4|GPU"

# Test MagicMirror server
curl http://localhost:8080

# Test browser manually
DISPLAY=:0 python3 ~/mm-browser.py

# Kill stuck browser
pkill -9 python3
```

## Configuration Files

```bash
# MagicMirror config
nano ~/MagicMirror/config/config.js

# System memory settings
sudo nano /etc/sysctl.conf

# GPU settings
sudo nano /boot/firmware/config.txt

# Browser service
sudo nano /etc/systemd/system/magicmirror-python.service

# Server service
sudo nano /etc/systemd/system/magicmirror.service
```

## Network Access URLs

- Local: `http://localhost:8080`
- IP: `http://YOUR_PI_IP:8080`
- Hostname: `http://raspberrypi.local:8080`

Replace `raspberrypi` with your actual hostname (`hostname` command)

## Memory Optimization Settings

Add to `/etc/sysctl.conf`:
```bash
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.overcommit_memory=1
```

Apply: `sudo sysctl -p`

## GPU Settings (config.txt)

Add to `/boot/firmware/config.txt`:
```ini
gpu_mem=64
dtoverlay=vc4-kms-v3d
```

Reboot required: `sudo reboot`
