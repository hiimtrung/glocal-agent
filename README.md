# Glocal Agent

A high-performance P2P tunnel agent written in Go. This agent connects your local hardware (like Raspberry Pi) to the Glocal web platform via WebRTC DataChannels.

## 🚀 Quick Start (Linux / Raspberry Pi)

The easiest way to install and setup the agent as a background service:

```bash
wget -qO- https://github.com/hiimtrung/glocal-agent/raw/main/install.sh | bash
```

This script will:
- Detect your CPU architecture.
- Download the correct binary.
- Ask for your Signaling URL and Device ID.
- Configure and start a `systemd` service (auto-restart).

## 🛠️ Manual Installation

### Pre-built Binaries
You can find binaries for various platforms in the [Releases](https://github.com/hiimtrung/glocal-agent/releases) section:
- `glocal-agent-linux-arm64` (Raspberry Pi)
- `glocal-agent-linux-amd64` (Standard Linux)
- `glocal-agent-windows-amd64.exe` (Windows)

### Manual Setup on RPi
We recommend running this as a systemd service to ensure it starts on boot.

1. Create service file:
```bash
sudo nano /etc/systemd/system/glocal-agent.service
```

2. Paste configuration:
```ini
[Unit]
Description=Glocal P2P Agent
After=network.target

[Service]
ExecStart=/home/pi/glocal-agent -url https://glocal-source-p2p.vercel.app -id rpi-home-01
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
```

3. Enable and start:
```bash
sudo systemctl enable glocal-agent
sudo systemctl start glocal-agent
```

## 🔐 Security
- **End-to-End Encrypted**: Data travels directly between your browser and the agent via WebRTC.
- **No Inbound Ports**: No need to open ports on your router or use complex VPNs.
- **Minimal Footprint**: Lightweight Go binary with low CPU/RAM usage.

---
*Part of the [Glocal P2P Tunnel](https://github.com/hiimtrung/glocal-source) project.*
