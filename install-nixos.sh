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

# Disable automatic mounting services (e.g., udisks) to prevent remounting
echo "Disabling automatic mounting services..."
systemctl stop udisks2 2>/dev/null
systemctl stop udisksd 2>/dev/null

# Partition /dev/sda (512M ESP, 60G root, remaining swap)
echo "Partitioning /dev/sda..."
# Create all partitions first, then set types
echo -e "g\nn\n1\n\n+512M\nn\n2\n\n+60G\nn\n3\n\n\nt\n1\n1\nt\n2\n83\nt\n3\n82\nw\n" | fdisk /dev/sda
if [ $? -ne 0 ]; then
    echo "Failed to partition /dev/sda."
    exit 1
fi

# Notify the kernel of partition table changes
echo "Notifying kernel of partition table changes..."
partprobe /dev/sda 2>/dev/null || blockdev --rereadpt /dev/sda 2>/dev/null
sleep 2  # Wait for the kernel to update

# Verify that /dev/sda3 exists
echo "Verifying partition devices..."
ls /dev/sda* || echo "Failed to list /dev/sda devices."
if [ ! -b /dev/sda3 ]; then
    echo "/dev/sda3 does not exist as a block device. Partition table update may have failed."
    exit 1
fi

# Log partition table for debugging
echo "Current partition table:"
fdisk -l /dev/sda

# Ensure /dev/sda1 (ESP) is not mounted or in use as swap
echo "Checking if /dev/sda1 is mounted or in use as swap..."
mount | grep /dev/sda1 || echo "/dev/sda1 not found in mount list."
lsblk /dev/sda1 -o MOUNTPOINT | grep -v MOUNTPOINT || echo "/dev/sda1 has no mountpoint in lsblk."
if mountpoint -q /dev/sda1 2>/dev/null || grep -q "/dev/sda1" /proc/mounts || [ -n "$(lsblk -no MOUNTPOINT /dev/sda1)" ]; then
    if [ "$(lsblk -no MOUNTPOINT /dev/sda1)" = "[SWAP]" ]; then
        echo "Disabling swap on /dev/sda1..."
        swapoff /dev/sda1 2>&1
        if [ $? -ne 0 ]; then
            echo "Failed to disable swap on /dev/sda1. Please disable swap manually and rerun the script."
            exit 1
        fi
    else
        echo "Unmounting /dev/sda1..."
        lsof /dev/sda1 2>/dev/null || echo "No processes using /dev/sda1."
        fuser -m /dev/sda1 2>/dev/null || echo "No processes using /dev/sda1 (fuser)."
        umount /dev/sda1 2>&1
        if [ $? -ne 0 ]; then
            echo "Regular unmount failed, attempting lazy unmount..."
            umount -l /dev/sda1 2>&1
            if [ $? -ne 0 ]; then
                echo "Lazy unmount failed, attempting forced unmount..."
                umount -f /dev/sda1 2>&1
                if [ $? -ne 0 ]; then
                    echo "Failed to unmount /dev/sda1. Please unmount manually and rerun the script."
                    exit 1
                fi
            fi
        fi
    fi
fi

# Format /dev/sda1 as vfat for ESP
echo "Formatting ESP partition (/dev/sda1) as vfat..."
mkfs.vfat /dev/sda1
if [ $? -ne 0 ]; then
    echo "Failed to format /dev/sda1."
    exit 1
fi

# Ensure /dev/sda2 (root) is not mounted or in use as swap
echo "Checking if /dev/sda2 is mounted or in use as swap..."
mount | grep /dev/sda2 || echo "/dev/sda2 not found in mount list."
lsblk /dev/sda2 -o MOUNTPOINT | grep -v MOUNTPOINT || echo "/dev/sda2 has no mountpoint in lsblk."
if mountpoint -q /dev/sda2 2>/dev/null || grep -q "/dev/sda2" /proc/mounts || [ -n "$(lsblk -no MOUNTPOINT /dev/sda2)" ]; then
    if [ "$(lsblk -no MOUNTPOINT /dev/sda2)" = "[SWAP]" ]; then
        echo "Disabling swap on /dev/sda2..."
        swapoff /dev/sda2 2>&1
        if [ $? -ne 0 ]; then
            echo "Failed to disable swap on /dev/sda2. Please disable swap manually and rerun the script."
            exit 1
        fi
    else
        echo "Unmounting /dev/sda2..."
        lsof /dev/sda2 2>/dev/null || echo "No processes using /dev/sda2."
        fuser -m /dev/sda2 2>/dev/null || echo "No processes using /dev/sda2 (fuser)."
        umount /dev/sda2 2>&1
        if [ $? -ne 0 ]; then
            echo "Regular unmount failed, attempting lazy unmount..."
            umount -l /dev/sda2 2>&1
            if [ $? -ne 0 ]; then
                echo "Lazy unmount failed, attempting forced unmount..."
                umount -f /dev/sda2 2>&1
                if [ $? -ne 0 ]; then
                    echo "Failed to unmount /dev/sda2. Please unmount manually and rerun the script."
                    exit 1
                fi
            fi
        fi
    fi
else
    echo "No mount detected for /dev/sda2, but double-checking..."
    umount /dev/sda2 2>/dev/null
    if [ -n "$(lsblk -no MOUNTPOINT /dev/sda2)" ]; then
        echo "Mount still detected after umount attempt:"
        lsblk /dev/sda2
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
mount | grep /dev/sda3 || echo "/dev/sda3 not found in mount list."
lsblk /dev/sda3 -o MOUNTPOINT | grep -v MOUNTPOINT || echo "/dev/sda3 has no mountpoint in lsblk."
if mountpoint -q /dev/sda3 2>/dev/null || grep -q "/dev/sda3" /proc/mounts || [ -n "$(lsblk -no MOUNTPOINT /dev/sda3)" ]; then
    if [ "$(lsblk -no MOUNTPOINT /dev/sda3)" = "[SWAP]" ]; then
        echo "Disabling swap on /dev/sda3..."
        swapoff /dev/sda3 2>&1
        if [ $? -ne 0 ]; then
            echo "Failed to disable swap on /dev/sda3. Please disable swap manually and rerun the script."
            exit 1
        fi
    else
        echo "Unmounting /dev/sda3..."
        lsof /dev/sda3 2>/dev/null || echo "No processes using /dev/sda3."
        fuser -m /dev/sda3 2>/dev/null || echo "No processes using /dev/sda3 (fuser)."
        umount /dev/sda3 2>&1
        if [ $? -ne 0 ]; then
            echo "Regular unmount failed, attempting lazy unmount..."
            umount -l /dev/sda3 2>&1
            if [ $? -ne 0 ]; then
                echo "Lazy unmount failed, attempting forced unmount..."
                umount -f /dev/sda3 2>&1
                if [ $? -ne 0 ]; then
                    echo "Failed to unmount /dev/sda3. Please unmount manually and rerun the script."
                    exit 1
                fi
            fi
        fi
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

# Verify bootloader installation
echo "Verifying bootloader installation..."
if [ -d "/mnt/boot/grub" ] || [ -f "/mnt/boot/loader/loader.conf" ]; then
    echo "Bootloader appears to be installed (GRUB or systemd-boot detected)."
else
    echo "Warning: Bootloader installation could not be verified. You may need to reinstall the bootloader manually."
fi

# Clean up mounts before finishing
echo "Cleaning up mounts..."
umount /mnt/boot 2>/dev/null
umount /mnt 2>/dev/null
swapoff /dev/sda3 2>/dev/null

# Check for any remaining mounts
echo "Checking for remaining mounts..."
mount | grep -E "/mnt|/dev/sda" || echo "No remaining mounts on /mnt or /dev/sda."
if mountpoint -q /mnt 2>/dev/null || grep -q "/mnt" /proc/mounts; then
    echo "Unmounting /mnt again..."
    umount /mnt 2>&1
fi

# Inform the user
echo "NixOS installation complete!"
echo "Next steps:"
echo "1. Shut down the VM: Run 'poweroff' or shut down via your VM software."
echo "2. Remove the NixOS ISO from the VM's CD/DVD drive in your VM settings."
echo "   - In VirtualBox/VMware/QEMU, go to the VM settings, set the CD/DVD drive to 'Empty'."
echo "3. Ensure the VM is set to boot from the disk (/dev/sda):"
echo "   - In VM settings, set the boot order to prioritize the hard disk over the CD/DVD drive."
echo "4. Start the VM to boot into the installed system."
echo "After booting, log in as 'jkpth' with password 'password' (change it in configuration.nix)."
echo "Select the Hyprland session at the login screen to start your desktop environment."

# Do not reboot automatically; let the user handle it
exit 0