#!/bin/bash

# Install Fail2Ban
sudo apt update
sudo apt install fail2ban -y

# Enable and start service
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Create jail.local with safe basic settings
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[DEFAULT]
bantime = 10m
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
backend = systemd
EOF

# Restart Fail2Ban
sudo systemctl restart fail2ban

# Show status
sudo fail2ban-client status sshd
