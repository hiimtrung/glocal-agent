#!/bin/bash

# Glocal Agent One-Click Installer & Upgrader
# High-performance P2P Tunnel Agent for Linux

set -e

REPO="hiimtrung/glocal-agent"
BINARY_NAME="glocal-agent"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/glocal-agent.service"

# Handle arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -url|--url) SIGNAL_URL="$2"; shift ;;
        -id|--id) DEVICE_ID="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "🚀 Starting Glocal Agent Installer/Upgrader..."

# 1. Detect Architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/glocal-agent-linux-amd64"
        ;;
    aarch64|arm64)
        DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/glocal-agent-linux-arm64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "✅ Detected architecture: $ARCH"

# 2. Ask for Configuration if not provided via args
if [ -z "$SIGNAL_URL" ]; then
    read -p "Enter Signaling URL [https://glocal-p2p.vercel.app]: " SIGNAL_URL
    SIGNAL_URL=${SIGNAL_URL:-https://glocal-p2p.vercel.app}
fi

if [ -z "$DEVICE_ID" ]; then
    read -p "Enter Device ID [rpi-home-01]: " DEVICE_ID
    DEVICE_ID=${DEVICE_ID:-rpi-home-01}
fi

echo "📝 Target URL: $SIGNAL_URL"
echo "📝 Device ID:  $DEVICE_ID"

# 3. Check for existing service and Stop/Cleanup
if systemctl is-active --quiet glocal-agent; then
    echo "🔄 Existing service detected. Stopping for upgrade..."
    sudo systemctl stop glocal-agent
fi

# 4. Download and Overwrite Binary
echo "📥 Downloading latest binary from $DOWNLOAD_URL..."
sudo wget -q --show-progress "$DOWNLOAD_URL" -O "$INSTALL_DIR/$BINARY_NAME"
sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"

# 5. Create/Update Systemd Service
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

# 6. Start/Restart Service
echo "🔄 Starting glocal-agent service..."
sudo systemctl daemon-reload
sudo systemctl enable glocal-agent
sudo systemctl restart glocal-agent

echo "✨ Done! Glocal Agent has been installed/upgraded."
echo "📊 Check status: sudo systemctl status glocal-agent"
echo "📜 View logs:    sudo journalctl -u glocal-agent -f"
