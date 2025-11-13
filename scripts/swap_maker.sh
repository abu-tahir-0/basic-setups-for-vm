#!/bin/bash

# Swap Setup Script
# This script creates and configures a swap file for your system

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Default swap size (in GB)
SWAP_SIZE=${1:-16}
SWAP_FILE="/swapfile"

echo -e "${GREEN}=== Swap Setup Script ===${NC}"
echo -e "Swap size: ${SWAP_SIZE}GB"
echo -e "Swap file: ${SWAP_FILE}\n"

# Check if swap file already exists
if [ -f "$SWAP_FILE" ]; then
    echo -e "${YELLOW}Warning: Swap file already exists at $SWAP_FILE${NC}"
    read -p "Do you want to remove it and create a new one? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Disabling existing swap..."
        swapoff "$SWAP_FILE" 2>/dev/null || true
        rm -f "$SWAP_FILE"
    else
        echo "Aborted."
        exit 0
    fi
fi

# Check available disk space
AVAILABLE_SPACE=$(df / | tail -1 | awk '{print $4}')
REQUIRED_SPACE=$((SWAP_SIZE * 1024 * 1024))

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    echo -e "${RED}Error: Not enough disk space. Required: ${SWAP_SIZE}GB${NC}"
    exit 1
fi

# Create swap file
echo -e "${GREEN}Step 1:${NC} Creating ${SWAP_SIZE}GB swap file..."
fallocate -l ${SWAP_SIZE}G "$SWAP_FILE"

# Set correct permissions
echo -e "${GREEN}Step 2:${NC} Setting permissions..."
chmod 600 "$SWAP_FILE"

# Format as swap
echo -e "${GREEN}Step 3:${NC} Formatting as swap space..."
mkswap "$SWAP_FILE"

# Enable swap
echo -e "${GREEN}Step 4:${NC} Enabling swap..."
swapon "$SWAP_FILE"

# Verify swap is active
echo -e "${GREEN}Step 5:${NC} Verifying swap status..."
swapon --show
echo ""
free -h

# Make swap permanent (add to fstab if not already present)
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo -e "${GREEN}Step 6:${NC} Making swap permanent (adding to /etc/fstab)..."
    echo "$SWAP_FILE none swap sw 0 0" | tee -a /etc/fstab
else
    echo -e "${YELLOW}Swap entry already exists in /etc/fstab${NC}"
fi

# Configure swappiness (prefer RAM over swap)
echo -e "${GREEN}Step 7:${NC} Configuring swappiness..."
sysctl vm.swappiness=10

# Make swappiness permanent
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | tee -a /etc/sysctl.conf
    echo "vm.vfs_cache_pressure=50" | tee -a /etc/sysctl.conf
else
    echo -e "${YELLOW}Swappiness already configured in /etc/sysctl.conf${NC}"
fi

echo -e "\n${GREEN}=== Swap setup completed successfully! ===${NC}"
echo -e "Swap file: $SWAP_FILE"
echo -e "Size: ${SWAP_SIZE}GB"
echo -e "Swappiness: 10 (prefers RAM)"
echo -e "Persistent: Yes (survives reboots)\n"
