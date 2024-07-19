                                                                                                    
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
ONIONMINING_REPO_URL=$(read_config "$CONFIG_FILE" "ArpirConfig" "ONIONMINING_REPO_URL")
TMP_DIR=$(read_config "$CONFIG_FILE" "ArpirConfig" "TMP_DIR")
DESTINATION=$(read_config "$CONFIG_FILE" "ArpirConfig" "DESTINATION")
MINING_SCRIPTS_DIR=$(read_config "$CONFIG_FILE" "ArpirConfig" "MINING_SCRIPTS_DIR")
ONION_DOMAINS_FILE=$(read_config "$CONFIG_FILE" "ArpirConfig" "ONION_DOMAINS_FILE")
MINING_SCRIPT=$(read_config "$CONFIG_FILE" "ArpirConfig" "MINING_SCRIPT")
MINING_GUI_SCRIPT=$(read_config "$CONFIG_FILE" "ArpirConfig" "MINING_GUI_SCRIPT")
USER_HOME=$(read_config "$CONFIG_FILE" "ArpirConfig" "USER_HOME")

# Clone the repository into the temporary directory
echo "Cloning the repository into $TMP_DIR"
git clone "$ONIONMINING_REPO_URL" "$TMP_DIR"

# Compile the onion address miner
cd "$TMP_DIR"
./autogen.sh
./configure
make

# Copy the Onion-domain-mining folder to the destination
echo "Copying the Onion-domain-mining folder to $DESTINATION"
sudo cp -r "$TMP_DIR" "$DESTINATION"

# Make the script executable
echo "Making the script executable"
sudo chmod +x "$DESTINATION"/*.sh

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
echo "$DESTINATION/mkp224o -f $ONION_DOMAINS_FILE -d $MINING_SCRIPTS_DIR/domain_output/" >> "$MINING_SCRIPT"

# Copy the mining GUI script to the user scripts directory
sudo cp "$DESTINATION/mining_gui.sh" "$MINING_GUI_SCRIPT"

# Make the user scripts executable and change ownership
sudo chmod +x "$MINING_SCRIPTS_DIR"/*.sh
sudo chown $USER:$USER "$MINING_SCRIPTS_DIR"
sudo chown $USER:$USER "$MINING_SCRIPTS_DIR"/*

echo "Onion Mining Installation Complete. Ready to use."

