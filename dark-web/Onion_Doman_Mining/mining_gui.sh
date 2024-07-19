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
MINING_SCRIPTS_DIR=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "MINING_SCRIPTS_DIR")
ONION_DOMAINS_FILE=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "ONION_DOMAINS_FILE")
MINING_SCRIPT=$(read_config "$CONFIG_FILE" "OnionMiningConfig" "MINING_SCRIPT")

# Function to start mining and display output in a Zenity window
start_mining() {
    local script_path="$MINING_SCRIPT"

    if [[ ! -x "$script_path" ]]; then
        zenity --error --text="The script $script_path is not executable or not found." --width=300 --height=100
        exit 1
    fi

    # Create a temporary file for the script output
    local output_file=$(mktemp)

    # Run the script in the background and redirect output to the temporary file
    $script_path > "$output_file" 2>&1 &
    
    # Store the PID of the script
    local script_pid=$!

    # Function to handle the cancel action
    cancel_script() {
        pkill -f "/usr/local/bin/Onion-domain-mining/mkp224o"
        zenity --info --text="Mining script cancelled." --width=300 --height=100
        rm "$output_file"
        exit 0
    }

    # Trap the SIGINT and SIGTERM signals to cancel the script
    trap cancel_script SIGINT SIGTERM

    # Display the instructions in a Zenity window
    zenity --info --title="Onion Domain Mining in Progress" --text="Instructions:\n1. Set the domains to mine in the file 'onion_domains_to_mine.txt'.\n2. Completed domains will be in the 'domain_output' directory when finished.\n3. Remember to move the domains to a secure vault when complete." --width=400 --height=200

    # Display the output in a Zenity progress window with a cancel button
    (
        tail -f "$output_file" &
        tail_pid=$!

        while kill -0 $script_pid 2>/dev/null; do
            sleep 1
            echo "# Mining in progress..."
        done

        kill $tail_pid
    ) | zenity --progress \
        --title="Onion Domain Mining in Progress" \
        --text="Mining in progress..." \
        --pulsate \
        --auto-close \
        --width=500 \
        --height=100

    # Check the exit status of the Zenity progress window
    if [ $? -ne 0 ]; then
        cancel_script
    fi

    # Clean up the temporary file
    rm "$output_file"
}

# Run the function
start_mining
