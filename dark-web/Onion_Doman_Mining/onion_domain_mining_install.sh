                                                                                                    
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

# Define the repository URL and the temporary directory
ONIONMINING_REPO_URL="https://github.com/cathugger/mkp224o"
TMP_DIR="/tmp/Onion-domain-mining"

# Define the destination location for the script
DESTINATION="/usr/local/bin/Onion-domain-mining"

# Clone the repository into the temporary directory
echo "Cloning the repository into $TMP_DIR"
git clone $ONIONMINING_REPO_URL $TMP_DIR

# Compile the onion address miner
cd $TMP_DIR
./autogen.sh
./configure
make

# Copy the Onion-domain-mining folder to /usr/local/bin
echo "Copying the Onion-domain-mining folder to $DESTINATION"
sudo cp -r $TMP_DIR $DESTINATION

# Make the script executable
echo "Making the script executable"
sudo chmod +x /usr/local/bin/Onion-domain-mining/*.sh

# Creating the /home/user/ scripts
echo "Creating the /home/user/ scripts"
mkdir -p /home/user/Onion_Keys
mkdir -p /home/user/Onion_Keys/domain_output

# Create and make the onion_domains_to_mine.txt writable by the current user
touch /home/user/Onion_Keys/onion_domains_to_mine.txt
sudo chown $USER:$USER /home/user/Onion_Keys/onion_domains_to_mine.txt
chmod +w /home/user/Onion_Keys/onion_domains_to_mine.txt

echo "mkdir -p /home/user/Onion_Keys/domain_output" >> /home/user/Onion_Keys/start_mining.sh
echo "/usr/local/bin/Onion-domain-mining/mkp224o -f /home/user/Onion_Keys/onion_domains_to_mine.txt -d /home/user/Onion_Keys/domain_output/" >> /home/user/Onion_Keys/start_mining.sh
sudo cp /usr/local/bin/Arpir-Obfuscation-Engine/dark-web/Onion_Doman_Mining/mining_gui.sh /home/user/Onion_Keys
sudo chmod +x /home/user/Onion_Keys/*.sh
sudo chown $USER:$USER /home/user/Onion_Keys/
sudo chown $USER:$USER /home/user/Onion_Keys/*

echo "Onion Mining Installation Complete. Ready to use."
