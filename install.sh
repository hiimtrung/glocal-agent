#!/bin/bash

# Glocal Agent One-Click Installer
# High-performance P2P Tunnel Agent for Linux

set -e

REPO="hiimtrung/glocal-agent"
BINARY_NAME="glocal-agent"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/glocal-agent.service"

echo "🚀 Starting Glocal Agent Installer..."

# 1. Detect Architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        DOWNLOAD_URL="https://github.com/$REPO/raw/main/glocal-agent-linux-amd64"
        ;;
    aarch64|arm64)
        DOWNLOAD_URL="https://github.com/$REPO/raw/main/glocal-agent-linux-arm64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "✅ Detected architecture: $ARCH"

# 2. Ask for Configuration
read -p "Enter Signaling URL [https://glocal-source-p2p.vercel.app]: " SIGNAL_URL
SIGNAL_URL=${SIGNAL_URL:-https://glocal-source-p2p.vercel.app}

read -p "Enter Device ID [rpi-home-01]: " DEVICE_ID
DEVICE_ID=${DEVICE_ID:-rpi-home-01}

# 3. Download Binary
echo "📥 Downloading binary from $DOWNLOAD_URL..."
sudo wget -q --show-progress "$DOWNLOAD_URL" -O "$INSTALL_DIR/$BINARY_NAME"
sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"

# 4. Create Systemd Service
echo "⚙️ Configuring systemd service..."
cat <<EOF | sudo tee $SERVICE_FILE > /dev/null
[Unit]
Description=Glocal P2P Agent
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/$BINARY_NAME -url $SIGNAL_URL -id $DEVICE_ID
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=glocal-agent

[Install]
WantedBy=multi-user.target
EOF

# 5. Start Service
echo "🔄 Starting glocal-agent service..."
sudo systemctl daemon-reload
sudo systemctl enable glocal-agent
sudo systemctl restart glocal-agent

echo "✨ Installation complete!"
echo "📊 Status: sudo systemctl status glocal-agent"
echo "📜 Logs:   sudo journalctl -u glocal-agent -f"
