#!/bin/bash

# Define the directory to scan for files
mkdir -p /home/user/_Vault
SCAN_DIRECTORY="/home/user/_Vault"

# Get a list of all files in the specified directory
ALL_FILES=("$SCAN_DIRECTORY"/*)

# Define the files to monitor with their full paths
FILES=(
    "/home/user/Crypto_passwords.ods"
)

# Add each file from the directory to the FILES array
for file in "${ALL_FILES[@]}"; do
    if [ -f "$file" ]; then
        FILES+=("$file")
    fi
done

# Function to take a photo using the system camera and store it in the /var/log/arpir/photos directory
take_photo() {
    # Create the /var/log/arpir/photos directory if it doesn't exist
    mkdir -p /var/log/arpir/photos
    
    # Define the output file path
    OUTPUT_FILE=/var/log/arpir/photos/photo_$(date +%Y%m%d_%H%M%S).jpg
    
    # Take a photo and save it to the output file
    fswebcam -r 640x480 --jpeg 85 -D 1 $OUTPUT_FILE
    
    # Check if the photo was taken successfully
    if [ -f $OUTPUT_FILE ]; then
        echo "Photo saved to $OUTPUT_FILE" >> /var/log/arpir/access.log
    else
        echo "Failed to take photo" >> /var/log/arpir/access.log
    fi
}

# Function to execute in warn mode
warn_mode() {
    COMMAND_TO_RUN() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Sensitive file accessed" >> /var/log/arpir/access.log
        # Add your additional commands here
        ffplay -nodisp -autoexit /usr/local/bin/Arpir-Obfuscation-Engine/kill-switch/uh-oh-error.mp3 > /dev/null 2>&1
        take_photo
        zenity --text-info --title="Killswitch Trigger Activated" --filename=/usr/local/bin/Arpir-Obfuscation-Engine/kill-switch/tripwire_warning.html --html --width=650 --height=600
        # Add more commands as needed
    }

    # Function to monitor files for access
    monitor_access() {
        # Monitor files for access events
        inotifywait -q -e access "${FILES[@]}" && COMMAND_TO_RUN
    }

    # Function to set a harmless process name
    set_process_name() {
        # Set process name to something innocuous
        echo $$ > /proc/$$/comm
    }

    # Trap exit to reset process name when the script exits
    trap 'echo bash > /proc/$$/comm' EXIT

    # Set the process name
    set_process_name

    # Main loop to ensure the script runs continuously
    while true; do
        # Monitor files for access
        monitor_access
    done
}

# Main script logic to handle command line options
case "$1" in
    --warn-mode)
        warn_mode
        ;;
    --watch-mode)
        watch_mode
        ;;
    --destructive-mode)
        destructive_mode
        ;;
    *)
        echo "Usage: $0 {--warn-mode|--watch-mode|--destructive-mode}"
        exit 1
        ;;
esac
