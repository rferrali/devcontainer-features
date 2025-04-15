#!/bin/bash

# This script installs MiKTeX on a Debian-based Linux distribution.
# 
# Features:
# - Verifies that the script is running on a Debian-based system.
# - Checks if MiKTeX is already installed and skips installation if it is.
# - Ensures required dependencies (curl and lsb-release) are installed.
# - Adds the MiKTeX repository and imports its GPG key.
# - Installs MiKTeX and performs initial setup.
# - Cleans up unnecessary packages and temporary files after installation.
# 
# Usage:
# - Run this script as root or with sudo privileges.
# - Ensure the system has internet access to download required packages and keys.
# 
# Notes:
# - The script removes curl and lsb-release if they were installed as part of the process.
# - It performs an `apt-get update` only if the package lists are empty.
# - MiKTeX is configured to auto-install missing packages during runtime.
# - The script is designed for minimal impact on the system by using `--no-install-recommends`.

set -e

echo "Activating feature 'miktex'"

# Basic checks
if ! [ -f /etc/debian_version ]; then
    echo "Error: This script only supports Debian-based distributions."
    exit 1
fi

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
    echo "Error: This script only supports x86_64 architectures."
    exit 1
fi

# Skip if already installed
if command -v miktexsetup &>/dev/null; then
    echo "MiKTeX is already installed. Skipping installation."
    exit 0
fi

# Install prerequisites
MISSING_PACKAGES=()
! command -v curl &>/dev/null && MISSING_PACKAGES+=(curl ca-certificates)
! command -v lsb_release &>/dev/null && MISSING_PACKAGES+=(lsb-release)

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo "Installing missing dependencies: ${MISSING_PACKAGES[*]}"
    apt-get update
    apt-get install -y --no-install-recommends "${MISSING_PACKAGES[@]}"
fi

# Add MiKTeX repo
curl -fsSL https://miktex.org/download/key | tee /usr/share/keyrings/miktex-keyring.asc > /dev/null
SYSTEM_VERSION=$(lsb_release -cs)
if [ -f /etc/lsb-release ]; then
    echo "deb [signed-by=/usr/share/keyrings/miktex-keyring.asc] https://miktex.org/download/ubuntu $SYSTEM_VERSION universe" > /etc/apt/sources.list.d/miktex.list
else
    echo "deb [signed-by=/usr/share/keyrings/miktex-keyring.asc] https://miktex.org/download/debian $SYSTEM_VERSION universe" > /etc/apt/sources.list.d/miktex.list
fi

# Install MiKTeX
apt-get update
apt-get install -y --no-install-recommends miktex
miktexsetup finish --shared
if AUTOINSTALLPACKAGES="true"; then
    echo "Setting up MiKTeX to auto-install missing packages"
    initexmf --admin --set-config-value [MPM]AutoInstall=1
else
    echo "Setting up MiKTeX to not auto-install missing packages"
    initexmf --admin --set-config-value [MPM]AutoInstall=0
fi

if INSTALLTEXFMT="true"; then
    # install tex-fmt if not already present
    if ! command -v tex-fmt &>/dev/null; then
        echo "Installing tex-fmt using Rust"

        if ! command -v cargo &>/dev/null; then
        echo "Rust not found. Installing Rust toolchain..."

        # Check if build-essential is already installed
        if dpkg -s build-essential &>/dev/null; then
            BUILD_ESSENTIAL_ALREADY_PRESENT=true
        else
            apt-get install -y --no-install-recommends build-essential
            BUILD_ESSENTIAL_INSTALLED_NOW=true
        fi

        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        RUST_INSTALLED_NOW=true
    fi

        cargo install tex-fmt
        install -m 755 "$HOME/.cargo/bin/tex-fmt" /usr/local/bin/tex-fmt
    fi
fi


# Cleanup
echo "Cleaning up"
[ "${MISSING_PACKAGES[*]}" != "" ] && apt-get remove -y "${MISSING_PACKAGES[@]}"
[ "$RUST_INSTALLED_NOW" = true ] && rm -rf "$HOME/.cargo" "$HOME/.rustup"
[ "$BUILD_ESSENTIAL_INSTALLED_NOW" = true ] && apt-get purge -y build-essential
apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*