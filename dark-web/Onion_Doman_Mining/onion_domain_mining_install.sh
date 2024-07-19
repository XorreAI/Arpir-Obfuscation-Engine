#!/bin/bash

# Function to read configuration values
read_config() {
    local config_file=$1
    local section=$2
    local key=$3
    awk -F= -v section="$section" -v key="$key" '
    $0 ~ "\\[" section "\\]" { in_section=1 }
    in_section && $1 == key { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit }
    ' "$config_file"
}

CONFIG_FILE="/home/user/.arpir-bin/_bin/config.cfg"

# Read values from the configuration file
ONIONMINING_REPO_URL=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "ONIONMINING_REPO_URL")
ONION_TMP_DIR=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "ONION_TMP_DIR")
ONION_DESTINATION=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "ONION_DESTINATION")
MINING_SCRIPTS_DIR=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "MINING_SCRIPTS_DIR")
ONION_DOMAINS_FILE=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "ONION_DOMAINS_FILE")
MINING_SCRIPT=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "MINING_SCRIPT")
MINING_GUI_SCRIPT=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "MINING_GUI_SCRIPT")
USER_HOME=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "USER_HOME")

# Ensure the temporary directory is empty
if [ -d "$ONION_TMP_DIR" ]; then
    rm -rf "$ONION_TMP_DIR"
fi

# Clone the repository into the temporary directory
echo "Cloning the repository into $ONION_TMP_DIR"
git clone "$ONIONMINING_REPO_URL" "$ONION_TMP_DIR"

# Compile the onion address miner
cd "$ONION_TMP_DIR"
./autogen.sh
./configure
make

# Copy the Onion-domain-mining folder to the destination
echo "Copying the Onion-domain-mining folder to $ONION_DESTINATION"
sudo cp -r "$ONION_TMP_DIR" "$ONION_DESTINATION"

# Ensure the mining_gui.sh file exists in the source directory
if [ ! -f "/home/user/.arpir-bin/dark-web/Onion_Doman_Mining/mining_gui.sh" ]; then
    echo "Error: mining_gui.sh not found in /home/user/.arpir-bin/dark-web/Onion_Doman_Mining"
    exit 1
fi

# Copy the mining_gui.sh script to the destination
sudo cp "/home/user/.arpir-bin/dark-web/Onion_Doman_Mining/mining_gui.sh" "$MINING_GUI_SCRIPT"

# Make the script executable
echo "Making the script executable"
sudo chmod +x "$ONION_DESTINATION"/*.sh

# Creating the user scripts directory
echo "Creating the user scripts directory"
mkdir -p "$MINING_SCRIPTS_DIR"
mkdir -p "$MINING_SCRIPTS_DIR/domain_output"

# Create and make the onion_domains_to_mine.txt writable by the current user
touch "$ONION_DOMAINS_FILE"
sudo chown $USER:$USER "$ONION_DOMAINS_FILE"
chmod +w "$ONION_DOMAINS_FILE"

# Write to the start mining script
echo "mkdir -p $MINING_SCRIPTS_DIR/domain_output" > "$MINING_SCRIPT"
echo "$ONION_DESTINATION/mkp224o -f $ONION_DOMAINS_FILE -d $MINING_SCRIPTS_DIR/domain_output/" >> "$MINING_SCRIPT"

# Make the user scripts executable and change ownership
sudo chmod +x "$MINING_SCRIPTS_DIR"/*.sh
sudo chown $USER:$USER "$MINING_SCRIPTS_DIR"
sudo chown $USER:$USER "$MINING_SCRIPTS_DIR"/*

echo "Onion Mining Installation Complete. Ready to use."
