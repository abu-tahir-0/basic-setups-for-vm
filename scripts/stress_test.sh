#!/bin/bash

# Stress Test Setup and Execution Script
# This script installs stress-ng and runs various stress tests

set -e

echo "================================"
echo "System Stress Test Setup"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Update package list
echo "[1/4] Updating package list..."
apt-get update -qq

# Install stress-ng
echo "[2/4] Installing stress-ng..."
apt-get install -y stress-ng > /dev/null 2>&1

echo "[3/4] Installation complete!"
echo ""
echo "================================"
echo "System Information"
echo "================================"
echo "CPU Cores: $(nproc)"
echo "Total RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Available RAM: $(free -h | awk '/^Mem:/ {print $7}')"
echo ""

# Run stress tests
echo "================================"
echo "[4/4] Running Stress Tests"
echo "================================"
echo ""

# CPU Stress Test
echo "--- CPU Stress Test (2 minutes) ---"
echo "Running stress on all CPU cores..."
stress-ng --cpu $(nproc) --timeout 2m --metrics-brief

echo ""
echo "--- Memory Stress Test (2 minutes) ---"
echo "Running memory stress test..."
stress-ng --vm 2 --vm-bytes 75% --timeout 2m --metrics-brief

echo ""
echo "--- Swap Stress Test (2 minutes) ---"
echo "Running swap stress test..."
echo "Current Swap Usage: $(free -h | awk '/^Swap:/ {print $3 " / " $2}')"
stress-ng --vm 2 --vm-bytes 90% --timeout 2m --metrics-brief
echo "Swap Usage After Test: $(free -h | awk '/^Swap:/ {print $3 " / " $2}')"

echo ""
echo "--- I/O Stress Test (2 minutes) ---"
echo "Running I/O stress test..."
stress-ng --io 4 --timeout 2m --metrics-brief

echo ""
echo "--- Combined Stress Test (2 minutes) ---"
echo "Running combined CPU, Memory, and I/O stress..."
stress-ng --cpu 2 --vm 1 --vm-bytes 50% --io 2 --timeout 2m --metrics-brief

echo ""
echo "================================"
echo "Stress Test Complete!"
echo "================================"
echo ""
echo "System Status After Tests:"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
echo "Swap Usage: $(free -h | awk '/^Swap:/ {print $3 " / " $2}')"
echo ""
