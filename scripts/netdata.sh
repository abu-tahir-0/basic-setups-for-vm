#!/bin/bash

set -e  # Exit on any error

echo "Updating system..."
sudo apt update -y

echo "Installing Netdata..."
sudo apt install netdata -y

echo "Stopping Netdata temporarily..."
sudo systemctl stop netdata

echo "Hardening Netdata configuration..."
# Backup original config
sudo cp /etc/netdata/netdata.conf /etc/netdata/netdata.conf.bak

# Force dashboard to be accessible ONLY from localhost (safe mode)
sudo tee /etc/netdata/netdata.conf > /dev/null <<EOF
[global]
    run as user = netdata
    web files owner = netdata
    web files group = netdata
    bind socket to IP = 127.0.0.1
    memory mode = dbengine
    page cache size = 64
EOF

echo "Restarting Netdata..."
sudo systemctl restart netdata
sudo systemctl enable netdata

echo "Done! Netdata is now safely installed."

echo "Your dashboard is ONLY available on this server via:"
echo "   http://127.0.0.1:19999"
echo ""
echo "If you want to access it remotely, use SSH tunnel:"
echo "   ssh -L 19999:localhost:19999 YOUR_USER@YOUR_SERVER_IP"
