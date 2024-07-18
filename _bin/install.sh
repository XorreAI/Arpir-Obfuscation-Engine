                                                                                                    
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
                                                                                                    


# Define the repository URL and the temporary directory
ARPIR_REPO_URL="https://github.com/XorreAI/Arpir-Obfuscation-Engine"
TMP_DIR="/tmp/Arpir-Obfuscation-Engine"

# Define the destination location for the script
DESTINATION="/home/user/.arpir-bin"
# SCRIPT_LOCATION="$DESTINATION/kill-switch/aprir-killswitch.sh"

# Clone the repository into the temporary directory
echo "Cloning the repository into $TMP_DIR"
git clone $ARPIR_REPO_URL $TMP_DIR

# Copy the Arpir-Obfuscation-Engine folder to /usr/local/bin
echo "Copying the Arpir-Obfuscation-Engine folder to $DESTINATION"
sudo cp -r $TMP_DIR $DESTINATION

# Make the script executable
echo "Making the script executable"
sudo chmod +x $DESTINATION/*.sh
sudo chmod +x $DESTINATION/*/*.sh


sudo bash $DESTINATION/_bin/prereq-install.sh
# sudo cp -r /tmp/Arpir-Obfuscation-Engine/ /usr/local/bin/
# sudo chmod +x /usr/local/bin/Arpir-Obfuscation-Engine/*.sh

