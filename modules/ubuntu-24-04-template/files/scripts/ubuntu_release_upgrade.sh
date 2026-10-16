#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical

echo "=== Ubuntu LTS Release Upgrade (one hop) ==="

# Configure dpkg to auto-accept config file defaults (avoid prompts)
echo 'Dpkg::Options { "--force-confdef"; "--force-confold"; }' | sudo tee /etc/apt/apt.conf.d/99-upgrade-noninteractive >/dev/null

# Remove needrestart (introduced in 22.04) - it causes hangs during unattended upgrades
sudo apt-get remove --purge -y needrestart 2>/dev/null || true

# Ensure release upgrader is installed
sudo apt-get install -y update-manager-core

# Set upgrade policy to LTS-only
sudo sed -i 's/^Prompt=.*/Prompt=lts/' /etc/update-manager/release-upgrades 2>/dev/null || \
  echo "Prompt=lts" | sudo tee /etc/update-manager/release-upgrades >/dev/null

# Run the upgrade to next LTS
sudo do-release-upgrade -f DistUpgradeViewNonInteractive

echo "=== Upgrade complete ==="
