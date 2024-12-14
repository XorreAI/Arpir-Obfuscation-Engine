# Remove any existing Sublime Text keyring file to avoid conflicts
sudo rm -f /usr/share/keyrings/sublimehq-archive-keyring.gpg

# Install required tools
sudo apt update
sudo apt install -y wget curl gnupg apt-transport-https

# Download and add the correct Sublime Text GPG key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo gpg --dearmor -o /usr/share/keyrings/sublimehq-archive-keyring.gpg

# Verify the key was added successfully
gpg --no-default-keyring --keyring /usr/share/keyrings/sublimehq-archive-keyring.gpg --list-keys

# Add the Sublime Text repository to APT sources
echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Update your package list to include the Sublime Text repository
sudo apt update

# Install Sublime Text
sudo apt install -y sublime-text


# 1. Enable 'contrib' and 'non-free' repositories
sudo sed -i 's/main/main contrib non-free/' /etc/apt/sources.list

# 2. Update package list
sudo apt update

# 3. Install required packages
sudo apt install -y encfs wget expect gcc libc6-dev libsodium-dev make autoconf unrar chromium snapd flatpak

sudo apt-get install -y encfs expect zenity fuse x11-xserver-utils



sudo apt-get update
sudo apt-get install -y gir1.2-ayatanaappindicator3-0.1



# 4. Enable and start the snapd service
sudo systemctl enable --now snapd

# 5. Enable the Flathub repository for Flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 6. Install Opera via Snap
sudo snap install opera

# 7. Install Tor Browser via Flatpak
sudo flatpak install -y flathub com.github.micahflee.torbrowser-launcher

# sudo snap install gitkraken --classic


### VPNs
#NordVPN
sudo snap install nordvpn
# ExpressVPN
# manual download - run expressvpn

#SurfShark
#manual download - run surfshark

#Private Internet Access
# not installed

#Proton VPN
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.6_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.6_all.deb && sudo apt update
sudo apt install -y proton-vpn-gnome-desktop

#MullvadVPN
sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list
sudo apt update
sudo apt install -y mullvad-vpn
sudo apt install -y mullvad-browser




# # Download the Mullvad signing key
# sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc

# # Add the Mullvad repository server to apt
# echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list

# # Install the package
# sudo apt update
# sudo apt install -y mullvad-browser












