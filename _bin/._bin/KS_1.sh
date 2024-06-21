#!/bin/bash

# Define the directory to scan for files
SCAN_DIRECTORY="/home/arpir/_Vault"

# Get a list of all files in the specified directory
ALL_FILES=("$SCAN_DIRECTORY"/*)

# Define the files to monitor with their full paths
FILES=(
    # "/home/user/Arpir/test/passwords.txt"
    # "/home/user/Arpir/test/sensitive_info.txt"
    # "/home/user/Arpir/test/confidential_data.txt"
    "/home/arpir/Crypto_passwords.ods"
)

# Add each file from the directory to the FILES array
for file in "${ALL_FILES[@]}"; do
    if [ -f "$file" ]; then
        FILES+=("$file")
    fi
done


# Function to take a photo using the system camera and store it in the .bin directory
take_photo() {
    # Create the .bin/photos directory if it doesn't exist
    mkdir -p /home/arpir/._bin/photos
    
    # Define the output file path
    OUTPUT_FILE=/home/arpir/._bin/photos/photo_$(date +%Y%m%d_%H%M%S).jpg
    
    # Take a photo and save it to the output file
    fswebcam -r 640x480 --jpeg 85 -D 1 $OUTPUT_FILE
    
    # Check if the photo was taken successfully
    if [ -f $OUTPUT_FILE ]; then
        echo "Photo saved to $OUTPUT_FILE"
    else
        echo "Failed to take photo"
    fi
}




# Define the commands to run when any of the files are accessed
COMMAND_TO_RUN() {
    echo 'Sensitive file accessed'
    # Add your additional commands here
    ffplay -nodisp -autoexit /home/arpir/._bin/uh-oh-error.mp3 > /dev/null 2>&1
    take_photo
    zenity --text-info --title="Killswitch Trigger Activated" --filename=/home/arpir/._bin/tripwire_warning.html --html --width=650 --height=600
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
