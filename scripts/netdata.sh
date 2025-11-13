#!/bin/bash

set -e  # Exit on any error

echo "Updating system..."
sudo apt update -y

echo "Installing Netdata..."
sudo apt install netdata -y

echo "Stopping Netdata temporarily..."
sudo systemctl stop netdata

echo "Configuring Netdata for remote access..."
# Backup original config
sudo cp /etc/netdata/netdata.conf /etc/netdata/netdata.conf.bak

# Configure dashboard to be accessible remotely on port 19998
sudo tee /etc/netdata/netdata.conf > /dev/null <<EOF
[global]
    run as user = netdata
    web files owner = netdata
    web files group = netdata
    bind socket to IP = 0.0.0.0
    default port = 19998
    memory mode = dbengine
    page cache size = 64
EOF

echo "Restarting Netdata..."
sudo systemctl restart netdata
sudo systemctl enable netdata

echo "Done! Netdata is now installed and accessible remotely."

echo "Your dashboard is available at:"
echo "   http://YOUR_SERVER_IP:19998"
echo ""
echo "⚠️  Security Note: Make sure to configure firewall rules to restrict access if needed:"
echo "   sudo ufw allow 19998/tcp"
