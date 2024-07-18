                                                                                                    
   #                                                       :=+--====                                  
   #                                                               -+::                               
   #                                                  :::-::------:--::::                             
   #                                                ::=@       .....::-::-:                           
   #                                                         -:::::----:::::::                        
   #                                                       ::--:::----:::::::::-                      
   #                                                       -++#-==+-:::::::::::--                     
   #                                                           :+=+=:::::--::.::-::                   
   #                                                        -:-# ==+::::---=-:..==:::                 
   #                                                    :  :-%   +++#:::-----=-:..=-:..               
   #                                                     =#         -=-::----=+%-....-:..             
   #                                                           :::=*====*==+%%#+-::....:...           
   #                                                   -:-+:-=+*#    =+#  =+=-:::::=:.......:         
   #                                                  @@@@@@              ===+=-===*@*:.......        
   #     @++++++%                                     #----*                 -==----+**-:..:....      
   #     *------=@                                    %====#                 --::::-=++++=:.. ...     
   #    %=-------*       %###%@@*#   @%###%@%##%@     %####%    @####%@%*@   :-+++++#@@@@@%-.. ...:   
   #    %----*---+%      *---=+--*@  @=---=------#    *----*    @----=---%   .:::::::-----= -:.: ::.  
   #   @=---*%----%      *-----**%@  @=---=#*----#    *----*    @-----=**@    ++*****@@@@@@   -::     
   #   *----@@=---=@     *----#      @=---+@%----#    *----*    @----+@       -+::::::::::+           
   #  %=---+@@%----#     *----%      @=---+@%----#    *----*    @----+@       :#:=+*##%@@@@           
   #  %------------+@    *----%      @=---+@%----#    *----*    @----+@      .:*  *=----=%            
   # @+----****+----%    *----%      @=----------#    *----*    @----+@       +%   :::::-             
   # #----#@   #----+@   *----%      @=---+=----+@    *----*    @----+@       ===    ::#              
   # @@@@@@     @@@@@@   @@@@@@      @=---+@@@@@       @@@@@     @@@@@          -#                    
   #                                 @=---+@                                                          
   #                                   @@@@                                                           
                                                                                                    


#!/usr/bin/env bash

start_time=$(date +%s)  # Start timing
export LIBGL_ALWAYS_SOFTWARE=1
mkdir -p "/home/user/_Decrypted"
DESTINATION="/home/user/.arpir-bin"

setup_encfs() {
    check_decrypted_files
    local base_dir_name="$1"
    if [[ -z "$base_dir_name" ]]; then
        echo "Usage: setup_encfs [base_dir_name]"
        return 1  # Use return to prevent terminal closure if sourced
    fi

    local encrypted_dir="${HOME}/_Vault/${base_dir_name}/"
    local decrypted_dir="${HOME}/_Decrypted/"
    local password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 180)
    mkdir -p "$encrypted_dir" "$decrypted_dir"
    echo "Generated Password: $password"
    echo $encrypted_dir > /tmp/active_vault.txt
    /usr/bin/expect <<EOF
spawn encfs $encrypted_dir $decrypted_dir
expect "configuration mode"
send "p\r"
expect "New Encfs Password:"
send "$password\r"
expect "Verify Encfs Password:"
send "$password\r"
expect eof
EOF
    echo "EncFS volume mounted at $decrypted_dir"
}


create_vault() {
    check_decrypted_files

    # Function to suggest a vault name
    suggest_vault_name() {
        local names_file="$DESTINATION/_bin/random.txt"
        if [ ! -f "$names_file" ]; then
            zenity --error --text="The file $names_file does not exist." --width=300 --height=100
            return 1
        fi

        local random_name=$(shuf -n 1 "$names_file")
        local num_suffix=$(shuf -i 1-4 -n 1)  # Choose a random count of numbers to append
        local random_numbers=$(tr -dc '0-9' </dev/urandom | head -c $num_suffix)
        random_name+="$random_numbers"

        if (( $RANDOM % 2 == 0 )); then
            random_name="${random_name,,}"  # Convert to lowercase with a 50% chance
        fi

        echo "$random_name"
    }

    # Loop until the user accepts a vault name or cancels the operation
    local user_input=""
    while true; do
        local vault_name=$(suggest_vault_name)
        echo "Suggested vault name: $vault_name"

        user_input=$(zenity --entry --title="Vault Name Suggestion" \
            --text="Suggested Vault Name:\n$vault_name\n\nYou can accept this name or enter a new one. To cancel, accept the name suggestion and move to the next screen. \n\nClick 'Suggest New Name' to get another suggestion:" \
            --ok-label="Accept" \
            --extra-button="Suggest New Name" \
            --cancel-label="Cancel" \
            --entry-text="$vault_name" \
            --width=400 --height=200)

        response=$?
        echo "Zenity response code: $response"
        echo "User input: $user_input"

        if [[ $response -eq 0 ]]; then
            vault_name="$user_input"  # Update vault_name to user's input
            echo "User accepted/entered vault name: $vault_name"

            # Check if the directory with the vault name already exists
            if [ -d "/home/user/_Vault/$vault_name" ]; then
                zenity --error --text="A vault with the name '$vault_name' already exists. Please choose a different name." --width=300 --height=100
                continue  # Re-prompt for vault name if it already exists
            else
                break  # Exit loop if user accepts a name and it does not exist
            fi
        elif [[ $response -eq 1 ]]; then
            echo "User requested a new name suggestion."
            continue  # Continue looping to suggest a new name
        elif [[ $response -eq 5 ]]; then
            zenity --info --text="Vault creation cancelled." --width=300 --height=100
            echo "Vault creation cancelled by user."
            return 1
        fi
    done

    # Check if there is at least 4GB of free space available
    local available_space=$(df --output=avail /home | tail -1)
    available_space=$((available_space / 1024))  # Convert to MB
    if [[ $available_space -lt 4096 ]]; then
        zenity --error --text="Not enough free space to create a new vault. Please ensure at least 4GB of free space is available." --width=300 --height=100
        echo "Not enough free space. Operation cancelled."
        return 1
    fi

    # Password input stage with retry on mismatch
    while true; do
        local passwords
        passwords=$(zenity --forms --title="Enter Vault Password" \
            --text="Enter a password for the new vault named '$vault_name' and confirm it:" \
            --add-password="Password" \
            --add-password="Confirm Password" \
            --width=400 --height=200)

        # Check if the user pressed the cancel button
        if [[ $? -ne 0 ]]; then
            zenity --info --text="Vault creation cancelled." --width=300 --height=100
            echo "Vault creation cancelled by user."
            return 1
        fi

        # Split the passwords input
        local password=$(echo "$passwords" | cut -d'|' -f1)
        local confirm_password=$(echo "$passwords" | cut -d'|' -f2)

        # Check if the passwords are empty or do not match
        if [[ -z "$password" || "$password" != "$confirm_password" ]]; then
            zenity --error --text="Passwords cannot be empty and must match. Please try again." --width=300 --height=100
            continue  # Re-prompt if passwords do not match
        else
            echo "Passwords matched and accepted."
            break  # Exit loop if passwords match
        fi
    done

    local encrypted_dir="${HOME}/_Vault/$vault_name/"
    local decrypted_dir="${HOME}/_Decrypted/"
    mkdir -p "$encrypted_dir" "$decrypted_dir"
    echo $encrypted_dir > /tmp/active_vault.txt

    # Automate EncFS setup using expect
    /usr/bin/expect <<EOF
spawn encfs $encrypted_dir $decrypted_dir
expect "configuration mode"
send "p\r"
expect "New Encfs Password:"
send "$password\r"
expect "Verify Encfs Password:"
send "$password\r"
expect eof
EOF

    if [[ $? -eq 0 ]]; then
        zenity --info --text="Vault '$vault_name' created and now generating random files..." --width=300 --height=100
        echo "Vault '$vault_name' created successfully."

        # Generate a random file size target between 300M and 500M
        local target_size=$((300 + RANDOM % 201))M
        echo "Target size for random file generation: $target_size"

        # Function to calculate the current size of the directory
        calculate_dir_size() {
            du -sm "$decrypted_dir" | cut -f1
        }

        # Loop to run execute_random_commands until directory size exceeds target size
        echo "Starting random file generation..."
        while [[ $(calculate_dir_size) -lt ${target_size%M} ]]; do
            execute_random_commands
            local current_size=$(calculate_dir_size)
            echo "Current directory size: ${current_size}M / Target size: ${target_size}"
        done

        # Create directory _Files in decrypted directory
        mkdir -p "${decrypted_dir}_Files"

        # Success dialog with additional instructions or confirmation
        zenity --info --title="Vault Ready" --text="Your new vault '$vault_name' is ready to use with additional random files generated in _Decrypted." --width=300 --height=200
    else
        zenity --error --title="Vault Creation Failed" --text="Failed to create the vault. Please check the inputs and try again." --width=300 --height=200
    fi
}








generate_random_name_from_file() {
    local names_file="$DESTINATION/_bin/random.txt"

    # Check if the file exists
    if [ ! -f "$names_file" ]; then
        echo "The file $names_file does not exist."
        return 1
    fi

    local random_name
    local vault_dir

    # Loop until a unique directory name is found
    while true; do
        # Read a random line from the file
        random_name=$(shuf -n 1 "$names_file")
        vault_dir="/home/user/_Vault/$random_name"

        # Check if the directory already exists
        if [ ! -d "$vault_dir" ]; then
            echo "$random_name"
            return 0  # Exit with success as a unique name is found
        fi
        # If the directory exists, loop will continue to find a new name
    done
}





generate_random_files() {
    local base_num_chars="$1"
    local base_num_files="$2"
    local root_dir="/home/user/_Decrypted/"

    if [[ -z "$base_num_chars" || -z "$base_num_files" ]]; then
        echo "Usage: generate_random_files [number_of_characters] [base_number_of_files]"
        return 1
    fi

    # Array to store all directories including subdirectories
    local directories=("$root_dir")

    # Generate a random number of top-level directories
    local num_dirs=$(shuf -i 0-6 -n 1)

    for ((j=0; j<num_dirs; j++)); do
        local subdir_suffix=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 2)
        local new_dir="${root_dir}/Decoy${subdir_suffix}"
        mkdir -p "$new_dir"
        directories+=("$new_dir")
        create_file_in_directory "$new_dir" "$base_num_chars"

        # Recursively create subdirectories with a 25% chance and ensure each has at least one file
        local current_dir="$new_dir"
        while (( RANDOM % 4 == 0 )); do
            subdir_suffix=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 2)
            current_dir="${current_dir}/Decoy${subdir_suffix}"
            mkdir -p "$current_dir"
            directories+=("$current_dir")
            create_file_in_directory "$current_dir" "$base_num_chars"
        done
    done

    # Distribute additional files among all directories
    distribute_files_among_directories "${directories[@]}" "$base_num_chars" "$base_num_files"
}

# Helper function to create a file in a specified directory
create_file_in_directory() {
    local dir=$1
    local num_chars=$(shuf -i 110000-310000 -n 1)  # Random character count
    local filename_suffix=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 4)
    local full_filename="${dir}/decoy${filename_suffix}.txt"
    < /dev/urandom tr -dc 'A-Za-z0-9' | head -c "$num_chars" > "$full_filename"
}

# Helper function to distribute files evenly across directories
distribute_files_among_directories() {
    local directories=("$@")
    local num_chars_base=${directories[-2]}
    local num_files_base=${directories[-1]}
    unset directories[-1]  # Remove last element which is num_files_base
    unset directories[-1]  # Remove second last element which is num_chars_base

    local total_files=$(shuf -i "$((num_files_base / 2))-$num_files_base" -n 1)  # Ensure each directory gets at least one file

    for ((i=0; i<total_files; i++)); do
        local num_chars=$(shuf -i "$((num_chars_base / 2))-$num_chars_base" -n 1)
        local selected_dir=${directories[$(( RANDOM % ${#directories[@]} ))]}
        create_file_in_directory "$selected_dir" "$num_chars"
    done

    echo "Files have been generated and distributed among directories, including nested subdirectories."
}




check_decrypted_files() {
    local decrypted_dir="$HOME/_Decrypted"

    # Check if the directory exists and is not empty
    if [ -d "$decrypted_dir" ] && [ "$(ls -A "$decrypted_dir")" ]; then
        # There are files in the directory, show Zenity dialog
        zenity --warning \
               --title="Directory Not Empty" \
               --text="The directory $decrypted_dir is not empty.\nPlease exit the vault or remove the files before trying again." \
               --width=300 --height=200
        exit 1  # Exit the script entirely to prevent further execution
    fi

    # No files in the directory, script continues
}

create_active_decoys() {
    local target_dir="/home/user/_Decrypted/Decoy_Active"
    mkdir -p "$target_dir"  # Ensure the directory exists

    # Generate between 1 and 4 files
    local num_files=$(shuf -i 1-4 -n 1)

    for ((i=0; i<num_files; i++)); do
        local file_name="decoy$(tr -dc 'A-Za-z' </dev/urandom | head -c 4).txt"
        local num_chars=$(shuf -i 110000-910000 -n 1)  # Random character count between 110000 and 310000
        < /dev/urandom tr -dc 'A-Za-z0-9' | head -c "$num_chars" > "$target_dir/$file_name"
    done

    # Echo 10 random characters into all files in the directory
    local random_chars=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 10)
    for file in "$target_dir"/*; do
        echo "$random_chars" >> "$file"
    done

    echo "Decoy files created and updated in $target_dir"
}



mount_vault() {
    check_decrypted_files
    local VAULT_DIR="$HOME/_Vault"

    # Get screen dimensions for Zenity
    local screen_dimensions=$(xrandr | grep -w connected | grep -oP '\d+x\d+\+\d+\+\d+' | head -1)
    local screen_width=$(echo $screen_dimensions | cut -d 'x' -f1)
    local screen_height=$(echo $screen_dimensions | cut -d 'x' -f2 | cut -d '+' -f1)

    # Calculate window dimensions (80% of screen dimensions)
    local width=$((screen_width * 80 / 100))
    local height=$((screen_height * 80 / 100))

    if [ ! -d "$VAULT_DIR" ]; then
        zenity --error --text="Directory does not exist: $VAULT_DIR" --width=$width --height=$height
        return 1
    fi

    local dirs=$(find "$VAULT_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | tr '\n' ' ')
    if [ -z "$dirs" ]; then
        zenity --info --text="No directories found in $VAULT_DIR." --width=$width --height=$height
        return 0
    fi

    local selected_dir=$(zenity --list --title="Select your hidden files" \
                          --text="Welcome to the Directory Selector!\nPlease select a directory from the list below." \
                          --column="Directories" $dirs --width=$width --height=$height)

    if [ -z "$selected_dir" ]; then
        zenity --info --text="No directory was selected. Operation canceled." --width=$width --height=$height
        return 1
    fi

    local password=$(zenity --password --title="Password Entry" \
                      --text="Please enter your password to mount the directory:" --width=$width --height=$height)
    if [ -z "$password" ]; then
        zenity --info --text="No password was entered. Operation canceled." --width=$width --height=$height
        return 1
    fi

    # Save the active vault path to a file
    local active_vault="$VAULT_DIR/$selected_dir"
    echo $active_vault > /tmp/active_vault.txt

    # Progress bar and mounting operation
    (
    echo "10" # Start the progress
    echo "# Mounting $selected_dir..." 
    mkdir -p "$HOME/_Decrypted/"
    local ENCFS6_CONFIG="$active_vault/.encfs6.xml"
    if echo $password | encfs -v "$active_vault" "$HOME/_Decrypted/" --stdinpass; then
        echo "100" # Complete the progress bar
        zenity --info --title="Successfully Mounted files" --text="Hidden files mounted successfully in the folder _Decrypted." --width=$width --height=$height
    else
        echo "Failed"
        zenity --error --text="Failed to mount the directory. Check terminal for details." --width=$width --height=$height
    fi
    ) | zenity --progress \
               --title="Mounting Vault" \
               --text="Initializing..." \
               --percentage=0 \
               --auto-close \
               --width=$width \
               --height=$height \
               --no-cancel

    return 0
}



change_password() {
    local VAULT_DIR="$HOME/_Vault"

    # Get screen dimensions for Zenity
    local screen_dimensions=$(xrandr | grep -w connected | grep -oP '\d+x\d+\+\d+\+\d+' | head -1)
    local screen_width=$(echo $screen_dimensions | cut -d 'x' -f1)
    local screen_height=$(echo $screen_dimensions | cut -d 'x' -f2 | cut -d '+' -f1)

    # Calculate window dimensions (80% of screen dimensions) for the main dialogs
    local width=$((screen_width * 80 / 100))
    local height=$((screen_height * 80 / 100))

    if [ ! -d "$VAULT_DIR" ]; then
        zenity --error --text="Directory does not exist: $VAULT_DIR" --width=$width --height=$height
        return 1
    fi

    local dirs=$(find "$VAULT_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | tr '\n' ' ')
    if [ -z "$dirs" ]; then
        zenity --info --text="No directories found in $VAULT_DIR." --width=$width --height=$height
        return 0
    fi

    local selected_dir=$(zenity --list --title="Select your vault" \
                          --text="Please select a vault from the list below." \
                          --column="Vaults" $dirs --width=$width --height=$height)

    if [ -z "$selected_dir" ]; then
        zenity --info --text="No vault was selected. Operation canceled." --width=$width --height=$height
        return 1
    fi

    local active_vault="$VAULT_DIR/$selected_dir"
    echo $active_vault > /tmp/active_vault.txt

    # Get the current password
    local current_password=$(zenity --password --title="Current Password Entry" \
                             --text="Please enter the current password for the vault '$selected_dir':" --width=$width --height=$height)
    if [ -z "$current_password" ]; then
        zenity --info --text="No password was entered. Operation canceled." --width=$width --height=$height
        return 1
    fi

    # Password input stage with retry on mismatch
    while true; do
        local passwords=$(zenity --forms --title="Enter New Vault Password" \
            --text="Enter a new password for the vault '$selected_dir' and confirm it:" \
            --add-password="New Password" \
            --add-password="Confirm New Password" \
            --width=400 --height=200)

        # Check if the user pressed the cancel button
        if [[ $? -ne 0 ]]; then
            zenity --info --text="Password change canceled." --width=300 --height=100
            echo "Password change canceled by user."
            return 1
        fi

        local new_password=$(echo "$passwords" | cut -d'|' -f1)
        local confirm_new_password=$(echo "$passwords" | cut -d'|' -f2)

        # Check if the passwords are empty or do not match
        if [[ -z "$new_password" || "$new_password" != "$confirm_new_password" ]]; then
            zenity --error --text="Passwords cannot be empty and must match. Please try again." --width=300 --height=100
            continue  # Re-prompt if passwords do not match
        else
            echo "Passwords matched and accepted."
            break  # Exit loop if passwords match
        fi
    done

    # Change the EncFS password using encfsctl
    /usr/bin/expect <<EOF
spawn encfsctl passwd "$active_vault"
expect "EncFS Password:"
send "$current_password\r"
expect "New Encfs Password:"
send "$new_password\r"
expect "Verify Encfs Password:"
send "$new_password\r"
expect eof
EOF

    if [[ $? -eq 0 ]]; then
        zenity --info --title="Password Changed" --text="Password for the vault '$selected_dir' has been successfully changed." --width=300 --height=100
        echo "Password for the vault '$selected_dir' has been successfully changed."
    else
        zenity --error --title="Password Change Failed" --text="Failed to change the password for the vault. Please check the current password and try again." --width=300 --height=100
        echo "Failed to change the password for the vault. Please check the current password and try again."
    fi
}






randomize_timestamps() {
    echo "timestamp randomization begins"
    local directory="$1"

    if [[ -z "$directory" ]]; then
        echo "Usage: randomize_timestamps [directory]"
        return 1
    fi

    if [[ ! -d "$directory" ]]; then
        echo "Directory does not exist: $directory"
        return 1
    fi

    # Count total files and directories
    local total_items=$(find "$directory" \( -type f -o -type d \) | wc -l)
    local progress=0

    # Start Zenity progress bar
    (
    find "$directory" \( -type f -o -type d \) -print0 | while IFS= read -r -d $'\0' item; do
        # Randomization code
        while true; do
            year=$(shuf -i 1990-2037 -n 1)
            month=$(shuf -i 1-12 -n 1)
            case $month in
                4|6|9|11) day=$(shuf -i 1-30 -n 1);;
                2) if ((year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))); then
                        day=$(shuf -i 1-29 -n 1)
                   else
                        day=$(shuf -i 1-28 -n 1)
                   fi;;
                *) day=$(shuf -i 1-31 -n 1);;
            esac
            hour=$(shuf -i 0-23 -n 1)
            minute=$(shuf -i 0-59 -n 1)
            second=$(shuf -i 0-59 -n 1)

            if [[ $(date -d "$year-$month-$day $hour:$minute:$second" "+%Y-%m-%d %H:%M:%S" 2>/dev/null) ]]; then
                new_timestamp="${year}$(printf "%02d" $month)$(printf "%02d" $day)$(printf "%02d" $hour)$(printf "%02d" $minute)"
                touch -d "$year-$month-$day $hour:$minute:$second" "$item" && break
            fi
        done

        # Update progress
        progress=$((progress + 1))
        echo $((progress * 100 / total_items))
    done
    ) | zenity --progress --title="Randomizing Timestamps" --text="Updating timestamps..." --percentage=0 --auto-close

    echo "timestamp finished"
}



execute_random_commands() {
    local commands=(
        "generate_random_files 210000 300"
        "generate_random_files 2100000 30"
        "generate_random_files 2100000 100"
        "generate_random_files 21000000 40"
        "generate_random_files 210000000 10"
        "generate_random_files 21000 1000"
        "generate_random_files 2100 2000"
        "generate_random_files 210 10000"
        "generate_random_files 21 10000"
        "generate_random_files 2100000 40"
        "generate_random_files 2100000 10"
        "generate_random_files 110000 600"
        "generate_random_files 1100000 200"
        "generate_random_files 11000000 80"
        "generate_random_files 110000000 20"
        "generate_random_files 11000 2000"
        "generate_random_files 1100 4000"
        "generate_random_files 110 20000"
        "generate_random_files 11 40000"
        "generate_random_files 1100000 80"
        "generate_random_files 1100000 20"    
        "generate_random_files 410000 300"
        "generate_random_files 4100000 100"
        "generate_random_files 41000000 40"
        "generate_random_files 41000000 10"
        "generate_random_files 41000 1000"
        "generate_random_files 4100 2000"
        "generate_random_files 410 10000"
        "generate_random_files 41 20000"
        "generate_random_files 4100000 40"
        "generate_random_files 4100000 10"
        "generate_random_files 410000 1"
        "generate_random_files 4100000 1"
        "generate_random_files 41000000 1"
        "generate_random_files 41000000 15"
        "generate_random_files 41000 1"
        "generate_random_files 4100 2"
        "generate_random_files 410 1"
        "generate_random_files 41 1"
        "generate_random_files 4100000 1"
        "generate_random_files 4100000 1"
        "generate_random_files 810000 100"
        "generate_random_files 8100000 10"
        "generate_random_files 8100000 5"
        "generate_random_files 81000 200"
        "generate_random_files 8100 800"
        "generate_random_files 810 1000"
        "generate_random_files 81 10000"
        "generate_random_files 8100000 40"
        "generate_random_files 8100000 20"
        "generate_random_files 81000000 2"
        "generate_random_files 810000000 1"
        "generate_random_files 1810000000 1"
        "generate_random_files 4810000000 1"
    )

    local total_commands=${#commands[@]}
    local command_index=$(shuf -i 0-$(($total_commands - 1)) -n 1)
    local command_to_run="${commands[$command_index]}"

    # Setup Zenity progress bar
    (
    echo "0"  # Initial progress
    echo "# Generating decoy files and encrypting them to establish obfuscation and plausible deniability..." 
    for ((i=0; i < total_commands; i++)); do
        if [[ $i -eq $command_index ]]; then
            eval "${commands[$i]}"
            echo "100"  # End progress
            echo "# Running command: ${commands[$i]}"
        fi
    done
    echo "100"  # End progress
    echo "# Command execution complete."
    ) | zenity --progress \
               --title="Generating Random Files" \
               --text="Generating..." \
               --pulsate \
               --auto-close

    echo "Running command: $command_to_run"
}



generate_obfuscation() {
    # Generate a random number between 2 and 21
    local num_commands=$(shuf -i 2-21 -n 1)
    echo "Randomly chosen to execute the 'execute_random_commands' function $num_commands times:"

    # Execute the function the randomly determined number of times
    for ((i=1; i<=num_commands; i++)); do
        execute_random_commands
    done

    echo "File Generation Finished"
}





dismount_vault() {
    local decrypted_dir="/home/user/_Decrypted"

    if mount | grep -q "$decrypted_dir"; then
        # Unmount the directory
        create_active_decoys
        fusermount -u "$decrypted_dir"
        
        # Check if unmounting was successful
        if mount | grep -q "$decrypted_dir"; then
            zenity --error \
                   --title="Unmounting Failed" \
                   --text="Failed to unmount the vault at $decrypted_dir.\nPlease try again or check for active file usage." \
                   --width=300 --height=200
        else
            # Read active vault information
            local active_vault=$(cat /tmp/active_vault.txt)
            echo "Active vault was: $active_vault"
            randomize_timestamps "$active_vault"
            rm /tmp/active_vault.txt
            
            zenity --info \
                   --title="Vault Dismounted" \
                   --text="The vault has been successfully dismounted." \
                   --width=300 --height=200
        fi
    else
        # Display a Zenity dialog box saying nothing is mounted
        zenity --info \
               --title="No Vault Mounted" \
               --text="No vault is currently mounted at $decrypted_dir." \
               --width=300 --height=200
    fi
}



generate_decoy_vault() {
    # Check if there is at least 4GB of free space available
    local available_space=$(df --output=avail /home | tail -1)
    available_space=$((available_space / 1024))  # Convert to MB
    if [[ $available_space -lt 4096 ]]; then
        zenity --error --text="Not enough free space to generate a new decoy vault. Please ensure at least 4GB of free space is available." --width=300 --height=100
        echo "Not enough free space. Operation cancelled."
        return 1
    fi

    # Generate a random variable from the specified file
    local random_variable=$(generate_random_name_from_file)

    # Check if random variable generation was successful
    if [[ -z "$random_variable" ]]; then
        echo "Failed to generate a random variable."
        return 1
    fi

    # Append 1 to 4 random numbers to the random_variable
    local num_suffix=$(shuf -i 0-4 -n 1)  # Choose a random count of numbers to append
    local random_numbers=$(tr -dc '0-9' </dev/urandom | head -c $num_suffix)  # Generate the random numbers
    random_variable+="${random_numbers}"  # Append numbers to the variable

    # Convert random_variable to lowercase with a 50% chance
    if (( $RANDOM % 2 == 0 )); then
        random_variable="${random_variable,,}"  # Convert to lowercase
    fi

    # Execute the setup_encfs with the modified random_variable
    setup_encfs "$random_variable"

    # Execute the generate_obfuscation function
    generate_obfuscation
    sleep 3

    # Unmount the decrypted directory
    fusermount -u ~/_Decrypted

    # Record and announce the active vault
    active_vault=$(cat /tmp/active_vault.txt)
    echo "Active vault is: $active_vault"
    randomize_timestamps "$active_vault"

    echo "Operations completed with random variable $random_variable"
}






generate_mass_decoy_vaults() {
    # Generate a random number between 1 and 10
    local num_commands=$(shuf -i 1-10 -n 1)
    echo "----------------------------------"
    echo "Randomly chosen to execute the 'generate_decoy_vault' function $num_commands time(s):"
    echo "----------------------------------"

    case $num_commands in
        1)
            generate_decoy_vault
            ;;
        2)
            generate_decoy_vault
            generate_decoy_vault
            ;;
        3)
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            ;;
        4)
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            ;;
        5)
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            ;;
        6)
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            ;;
        7)
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            ;;
        8)
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            ;;
        9)
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            ;;
        10)
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            generate_decoy_vault
            ;;
    esac
    echo "Decoy vault generation completed."
}




new_container_setup() {
    # Check if there is at least 30GB of free space available
    local available_space=$(df --output=avail /home | tail -1)
    available_space=$((available_space / 1024 / 1024))  # Convert to GB
    if [[ $available_space -lt 30 ]]; then
        zenity --error --text="Not enough free space to set up a new container. Please ensure at least 30GB of free space is available." --width=300 --height=100
        echo "Not enough free space. Operation cancelled."
        return 1
    fi

    # Run create_vault function
    # create_vault
    # dismount_vault

    # Run generate_mass_decoy_vaults function
    generate_mass_decoy_vaults

    # Generate a random size between 20G and 40G
    local min_size=20  # 20 GB
    local max_size=40  # 40 GB
    local target_size_gb=$((RANDOM % (max_size - min_size + 1) + min_size))

    # Check if the target size is more than 60% of the available space
    local sixty_percent_of_available_space=$((available_space * 60 / 100))
    if [[ $target_size_gb -gt $sixty_percent_of_available_space ]]; then
        target_size_gb=20  # Use 20GB as the target size if the random size is too large
    fi

    local target_size=$((target_size_gb * 1024 * 1024 * 1024))  # Convert GB to bytes for comparison

    echo "Target size for /home/user/_Vault is $target_size_gb GB"

    # Check the actual size
    local actual_size=$(du -sb /home/user/_Vault | cut -f1)

    # Continue to add decoy vaults until the size requirement is met
    while [ "$actual_size" -lt "$target_size" ]; do
        generate_decoy_vault
        actual_size=$(du -sb /home/user/_Vault | cut -f1)
    done

    echo "The size of /home/user/_Vault now exceeds $target_size_gb GB."
}




#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  --new-container-setup      Run first: Initial setup for a new container"
    echo "  --create-vault             Create a new vault"
    echo "  --setup-decoy-container    Setup a decoy container"
    echo "  --setup-mass-obfuscation   Setup mass obfuscation"
    echo "  --exit-vault               Exit the vault"
    echo "  --change-password          Change the password"
    echo "  --mount-vault              Mount the vault"
    echo "  --randomize-access-data    Randomize access data"
    echo "  --help                     Display this help message"
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No options provided."
    show_help
    exit 1  # Use exit only when not sourcing the script
fi

case "$1" in
    --new-container-setup)
        new_container_setup
        ;;
    --create-vault)
        create_vault
        ;;
    --setup-decoy-container)
        echo "Setting up a decoy container..."
        generate_decoy_vault
        ;;
    --setup-mass-obfuscation)
        echo "Setting up mass obfuscation..."
        generate_mass_decoy_vaults
        ;;
    --exit-vault)
        dismount_vault
        ;;
    --change-password)
        echo "Changing password..."
        change_password
        ;;
    --mount-vault)
        mount_vault
        ;;
    --randomize-access-data)
        randomize_timestamps /home/user/_Vault
        ;;
    --help)
        show_help
        ;;
    *)
        echo "Error: Invalid option '$1'"
        show_help
        exit 1  # Use exit here as this is for direct script execution
        ;;
esac


end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
hours=$((elapsed_time / 3600))
minutes=$(((elapsed_time % 3600) / 60))
seconds=$((elapsed_time % 60))
echo "Total execution time: $hours hours, $minutes minutes, $seconds seconds"
