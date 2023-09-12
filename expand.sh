#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# List available drives
echo "Available drives:"
lsblk -o NAME,SIZE -d -n
read -p "Enter the drive to use (e.g., /dev/sda): " DRIVE

# Check if the selected drive exists
if [[ ! -e $DRIVE ]]; then
    echo "Selected drive $DRIVE does not exist."
    exit 1
fi

# List partitions on the selected drive
echo -e "\nPartitions on $DRIVE:"
lsblk -o NAME,SIZE -n $DRIVE
read -p "Enter the partition to expand (e.g., ${DRIVE}1): " PARTITION

# Check if the selected partition exists
if [[ ! -e $PARTITION ]]; then
    echo "Selected partition $PARTITION does not exist on $DRIVE."
    exit 1
fi

# Get the size of the selected drive
SIZE=$(lsblk -o SIZE -b "$DRIVE" | tail -n 1)

# Get the current partition size
PARTITION_SIZE=$(lsblk -o SIZE -b "$PARTITION" | tail -n 1)

# Calculate the available unallocated space
UNALLOCATED_SPACE=$((SIZE - PARTITION_SIZE))

# Prompt the user to confirm their choice
echo -e "\nSelected drive: $DRIVE"
echo "Drive size: $((SIZE/1024/1024)) MB"
echo "Selected partition: $PARTITION"
echo "Current partition size: $((PARTITION_SIZE/1024/1024)) MB"
echo "Available unallocated space: $((UNALLOCATED_SPACE/1024/1024)) MB"

read -p "Do you want to proceed with expanding the partition to its maximum potential? (y/n): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation canceled."
    exit 0
fi

# Resize the partition to occupy the entire available unallocated space
parted -s "$DRIVE" resizepart "$(lsblk -nlpo NAME,SIZE "$PARTITION" | awk '{print $1}' | cut -d p -f 2)" 100%

# Refresh the partition table
partprobe "$DRIVE"

# Resize the file system to use the entire partition
resize2fs "$PARTITION"

# Display information about the expanded partition
echo "Partition $PARTITION has been expanded to its maximum potential."
