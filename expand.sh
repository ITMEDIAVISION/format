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

read -p "Do you want to proceed with expanding the partition to its maximum potential? (y/n): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation canceled."
    exit 0
fi

# Resize the partition to occupy the entire disk
parted -s "$DEVICE" resizepart 1 100%

# Refresh the partition table
partprobe "$DEVICE"

# Resize the file system to use the entire partition
resize2fs "${DEVICE}1"

# Display information about the expanded disk
echo "Disk $DEVICE has been expanded to its maximum potential."
