#!/bin/bash

# Define variables
PARTITION="/dev/nvme0n1p1"
MOUNT_POINT="/mnt/backups"
LABEL="backups"
SOURCE_DIR="/home/user/pictures"

# Unmount the partition if it's currently mounted
if mount | grep "$PARTITION" > /dev/null; then
    echo "Unmounting $PARTITION..."
    sudo umount "$PARTITION"
fi

# Format the partition with ext4 filesystem and label it
echo "Formatting $PARTITION with label $LABEL..."
sudo mkfs.ext4 -L "$LABEL" "$PARTITION"

# Create mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
fi

# Mount the partition
echo "Mounting $PARTITION to $MOUNT_POINT..."
sudo mount "$PARTITION" "$MOUNT_POINT"

# Check if the mount was successful
if mount | grep "$MOUNT_POINT" > /dev/null; then
    echo "Mount successful. Copying files from $SOURCE_DIR to $MOUNT_POINT..."

    # Copy files
    sudo cp -r "$SOURCE_DIR" "$MOUNT_POINT"

    echo "Files copied successfully."
else
    echo "Failed to mount $PARTITION. Exiting."
    exit 1
fi

# Unmount the partition after copying
echo "Unmounting $PARTITION..."
sudo umount "$PARTITION"

echo "Process completed."
