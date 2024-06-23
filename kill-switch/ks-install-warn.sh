#!/bin/bash

sudo apt-get install inotify-tools
sudo apt-get install fswebcam

# Define the repository URL and the temporary directory
REPO_URL="https://github.com/XorreAI/Arpir-Obfuscation-Engine"
TMP_DIR="/tmp/Arpir-Obfuscation-Engine"

# Define the destination location for the script
DESTINATION="/usr/local/bin/Arpir-Obfuscation-Engine"
SCRIPT_LOCATION="$DESTINATION/kill-switch/aprir-killswitch.sh"

# Clone the repository into the temporary directory
echo "Cloning the repository into $TMP_DIR"
git clone $REPO_URL $TMP_DIR

# Copy the Arpir-Obfuscation-Engine folder to /usr/local/bin
echo "Copying the Arpir-Obfuscation-Engine folder to $DESTINATION"
sudo cp -r $TMP_DIR $DESTINATION

# Make the script executable
echo "Making the script executable"
sudo chmod +x $SCRIPT_LOCATION

# Define the service file location
SERVICE_FILE="/etc/systemd/system/aprir-killswitch.service"

# Create the systemd service file
echo "Creating systemd service file at $SERVICE_FILE"
sudo bash -c "cat <<EOF > $SERVICE_FILE
[Unit]
Description=Aprir Killswitch Service
After=network.target

[Service]
ExecStart=$SCRIPT_LOCATION --warn-mode
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF"

# Enable the service to run on boot
echo "Enabling the service to run on boot"
sudo systemctl enable aprir-killswitch.service

# Start the service immediately
echo "Starting the service"
sudo systemctl start aprir-killswitch.service

# Check the status of the service
echo "Checking the status of the service"
sudo systemctl status aprir-killswitch.service
