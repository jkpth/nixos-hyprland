#!/bin/bash

# Script to install NixOS with Hyprland configuration on a VM disk (/dev/sda)
# WARNING: This script will erase all data on /dev/sda!

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

# Prompt for GitHub username
echo "Enter your GitHub username to clone the nixos-hyprland repository:"
read github_username

# Clone the repository
echo "Cloning repository from https://github.com/$github_username/nixos-hyprland.git..."
git clone "https://github.com/$github_username/nixos-hyprland.git" /root/nixos-hyprland
if [ $? -ne 0 ]; then
    echo "Failed to clone repository. Please check your GitHub username and repository access."
    exit 1
fi
cd /root/nixos-hyprland

# Warn about disk erasure
echo "WARNING: This script will erase all data on /dev/sda and create new partitions."
echo "Press Enter to continue, or Ctrl+C to abort."
read

# Partition /dev/sda (60G root, 4G swap)
echo "Partitioning /dev/sda..."
echo -e "g\nn\n1\n\n+60G\nn\n2\n\n\nt\n2\n82\nw" | fdisk /dev/sda
if [ $? -ne 0 ]; then
    echo "Failed to partition /dev/sda."
    exit 1
fi

# Ensure /dev/sda1 is not mounted before formatting
echo "Checking if /dev/sda1 is mounted..."
if mountpoint -q /dev/sda1 2>/dev/null || grep -q "/dev/sda1" /proc/mounts; then
    echo "Unmounting /dev/sda1..."
    umount /dev/sda1 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to unmount /dev/sda1. Please unmount manually and rerun the script."
        exit 1
    fi
fi

# Format partitions
echo "Formatting root partition (/dev/sda1) as ext4..."
mkfs.ext4 /dev/sda1
if [ $? -ne 0 ]; then
    echo "Failed to format /dev/sda1."
    exit 1
fi

echo "Formatting swap partition (/dev/sda2)..."
mkswap /dev/sda2
swapon /dev/sda2
if [ $? -ne 0 ]; then
    echo "Failed to set up swap on /dev/sda2."
    exit 1
fi

# Mount the root partition
echo "Mounting /dev/sda1 to /mnt..."
mkdir -p /mnt
mount /dev/sda1 /mnt
if [ $? -ne 0 ]; then
    echo "Failed to mount /dev/sda1."
    exit 1
fi

# Generate initial NixOS configuration
echo "Generating NixOS configuration..."
nixos-generate-config --root /mnt
if [ $? -ne 0 ]; then
    echo "Failed to generate NixOS configuration."
    exit 1
fi

# Copy the repository files to /mnt/etc/nixos
echo "Copying repository files to /mnt/etc/nixos..."
cp -r ./* /mnt/etc/nixos/
if [ $? -ne 0 ]; then
    echo "Failed to copy repository files."
    exit 1
fi

# Install NixOS using the flake
echo "Installing NixOS with flake..."
nixos-install --flake /mnt/etc/nixos#nixos --no-root-passwd
if [ $? -ne 0 ]; then
    echo "Failed to install NixOS."
    exit 1
fi

# Inform the user
echo "NixOS installation complete! The system will reboot in 10 seconds."
echo "After reboot, log in as 'jkpth' with password 'password' (change it in configuration.nix)."
sleep 10

# Reboot
reboot