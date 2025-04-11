#!/bin/bash
set -e

echo "Activating feature 'miktex'"
if ! [ -f /etc/debian_version ]; then
    echo "Error: This script only supports Debian-based distributions."
    exit 1
fi
if command -v miktexsetup &> /dev/null; then
    echo "MiKTeX is already installed. Skipping installation."
    exit 0
fi
if command -v curl &> /dev/null; then
    CURL_INSTALLED=1
else
    CURL_INSTALLED=0
fi
if command -v lsb_release &> /dev/null; then
    LSB_INSTALLED=1
else
    LSB_INSTALLED=0
fi
if [ $CURL_INSTALLED -eq 0 -o $LSB_INSTALLED -eq 0 ]; then
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        apt-get update
    fi
    if [ $CURL_INSTALLED -eq 0 ]; then
        apt-get update && apt-get install -y --no-install-recommends curl ca-certificates
    fi
    if [ $LSB_INSTALLED -eq 0 ]; then
        apt-get update && apt-get install -y --no-install-recommends lsb-release
    fi
fi
if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
    apt-get update
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
apt-get update && apt-get install -y --no-install-recommends miktex
miktexsetup finish --shared
initexmf --admin --set-config-value [MPM]AutoInstall=1
if [ $CURL_INSTALLED -eq 0 ]; then
    apt-get remove -y curl
fi
if [ $LSB_INSTALLED -eq 0 ]; then
    apt-get remove -y lsb-release
fi

apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*

