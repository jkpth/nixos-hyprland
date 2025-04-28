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

# Partition /dev/sda (512M ESP, 60G root, remaining swap)
echo "Partitioning /dev/sda..."
echo -e "g\nn\n1\n\n+512M\nt\n1\nn\n2\n\n+60G\nn\n3\n\n\nt\n3\n82\nw" | fdisk /dev/sda
if [ $? -ne 0 ]; then
    echo "Failed to partition /dev/sda."
    exit 1
fi

# Ensure /dev/sda1 (ESP) is not mounted before formatting
echo "Checking if /dev/sda1 is mounted..."
if mountpoint -q /dev/sda1 2>/dev/null || grep -q "/dev/sda1" /proc/mounts; then
    echo "Unmounting /dev/sda1..."
    umount /dev/sda1 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to unmount /dev/sda1. Please unmount manually and rerun the script."
        exit 1
    fi
fi

# Format /dev/sda1 as vfat for ESP
echo "Formatting ESP partition (/dev/sda1) as vfat..."
mkfs.vfat /dev/sda1
if [ $? -ne 0 ]; then
    echo "Failed to format /dev/sda1."
    exit 1
fi

# Ensure /dev/sda2 (root) is not mounted before formatting
echo "Checking if /dev/sda2 is mounted..."
if mountpoint -q /dev/sda2 2>/dev/null || grep -q "/dev/sda2" /proc/mounts; then
    echo "Unmounting /dev/sda2..."
    umount /dev/sda2 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to unmount /dev/sda2. Please unmount manually and rerun the script."
        exit 1
    fi
fi

# Format root partition
echo "Formatting root partition (/dev/sda2) as ext4..."
mkfs.ext4 /dev/sda2
if [ $? -ne 0 ]; then
    echo "Failed to format /dev/sda2."
    exit 1
fi

# Ensure /dev/sda3 is not mounted or in use as swap
echo "Checking if /dev/sda3 is mounted or in use as swap..."
if mountpoint -q /dev/sda3 2>/dev/null || grep -q "/dev/sda3" /proc/mounts; then
    echo "Unmounting /dev/sda3..."
    umount /dev/sda3 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to unmount /dev/sda3. Please unmount manually and rerun the script."
        exit 1
    fi
fi
if grep -q "/dev/sda3" /proc/swaps; then
    echo "Disabling swap on /dev/sda3..."
    swapoff /dev/sda3 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to disable swap on /dev/sda3. Please disable swap manually and rerun the script."
        exit 1
    fi
fi

# Format swap partition
echo "Formatting swap partition (/dev/sda3)..."
mkswap /dev/sda3
if [ $? -ne 0 ]; then
    echo "Failed to set up swap on /dev/sda3."
    exit 1
fi

echo "Enabling swap on /dev/sda3..."
swapon /dev/sda3
if [ $? -ne 0 ]; then
    echo "Failed to enable swap on /dev/sda3."
    exit 1
fi

# Log UUIDs for debugging
echo "Logging UUIDs of partitions..."
blkid /dev/sda1
blkid /dev/sda2
blkid /dev/sda3

# Mount the root partition
echo "Mounting /dev/sda2 to /mnt..."
mkdir -p /mnt
mount /dev/sda2 /mnt
if [ $? -ne 0 ]; then
    echo "Failed to mount /dev/sda2."
    exit 1
fi

# Mount the ESP partition
echo "Mounting /dev/sda1 to /mnt/boot..."
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
if [ $? -ne 0 ]; then
    echo "Failed to mount /dev/sda1 to /mnt/boot."
    exit 1
fi

# Generate initial NixOS configuration
echo "Generating NixOS configuration..."
nixos-generate-config --root /mnt
if [ $? -ne 0 ]; then
    echo "Failed to generate NixOS configuration."
    exit 1
fi

# Log the generated hardware-configuration.nix for debugging
echo "Contents of generated hardware-configuration.nix:"
cat /mnt/etc/nixos/hardware-configuration.nix

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