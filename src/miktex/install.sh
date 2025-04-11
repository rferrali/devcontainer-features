#!/bin/bash
set -e

echo "Activating feature 'miktex'"
if ! [ -f /etc/debian_version ]; then
    echo "Error: This script only supports Debian-based distributions."
    exit 1
fi
if ! command -v curl &> /dev/null; then
    apt-get update && apt-get install -y curl
fi
if ! command -v lsb_release &> /dev/null; then
    apt-get update && apt-get install -y lsb-release
fi
curl -fsSL https://miktex.org/download/key | tee /usr/share/keyrings/miktex-keyring.asc > /dev/null
SYSTEM_VERSION=$(lsb_release -cs)
if [ -f /etc/lsb-release ]; then
    # Ubuntu
    echo "deb [signed-by=/usr/share/keyrings/miktex-keyring.asc] https://miktex.org/download/ubuntu $SYSTEM_VERSION universe" | tee /etc/apt/sources.list.d/miktex.list
else
    # Debian
    echo "deb [signed-by=/usr/share/keyrings/miktex-keyring.asc] https://miktex.org/download/debian $SYSTEM_VERSION universe" | tee /etc/apt/sources.list.d/miktex.list
fi
apt-get update && apt-get install -y miktex
miktexsetup finish --shared
initexmf --admin --set-config-value [MPM]AutoInstall=1
apt-get clean && rm -rf /var/lib/apt/lists/*
