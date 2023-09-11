#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# List available drives and ask the user to select one
echo "Available drives:"
lsblk -o NAME,SIZE -d -n
read -p "Enter the drive to use (e.g., /dev/sda): " DEVICE

# Check if the selected drive exists
if [[ ! -e $DEVICE ]]; then
    echo "Selected drive $DEVICE does not exist."
    exit 1
fi

# Get the size of the selected drive
SIZE=$(lsblk -o SIZE -b "$DEVICE" | tail -n 1)

# Prompt the user to confirm their choice
echo -e "\nSelected drive: $DEVICE"
echo "Drive size: $((SIZE/1024/1024)) MB"

read -p "Do you want to proceed with partitioning and formatting? (y/n): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation canceled."
    exit 0
fi

# Define the mount point (e.g., /mnt/mydrive) for the new disk
MOUNT_POINT="/mnt/mydrive"

# Partition the selected drive (Assuming a single partition using all available space)
parted -s "$DEVICE" mklabel gpt
parted -s "$DEVICE" mkpart primary ext4 0% 100%

# Format the partition as ext4
mkfs.ext4 "${DEVICE}1"

# Create the mount point if it doesn't exist
mkdir -p "$MOUNT_POINT"

# Mount the partition
mount "${DEVICE}1" "$MOUNT_POINT"

# Add an entry to /etc/fstab for automatic mounting at boot
echo "${DEVICE}1 $MOUNT_POINT ext4 defaults 0 0" >> /etc/fstab

# Display the mounted disk information
echo "Disk $DEVICE has been partitioned, formatted as ext4, and mounted at $MOUNT_POINT."
