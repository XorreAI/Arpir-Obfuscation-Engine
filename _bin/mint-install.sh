# Update system
sudo apt update -y && sudo apt upgrade -y

# Add Sublime Text repository and install
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update -y
sudo apt install -y sublime-text

# Install encfs, wget, and expect
sudo apt install -y encfs wget expect

# Install development tools
sudo apt install -y gcc libc6-dev libsodium-dev make autoconf unrar

# Install Plasma Discover, Snapd, and Steghide
sudo apt install -y plasma-discover snapd
sudo ln -s /var/lib/snapd/snap /snap
sudo apt install -y steghide

# Install Tor Browser Launcher
sudo apt install -y torbrowser-launcher

# Install GIMP, VLC, Chromium, LibreOffice, and FileZilla
sudo apt install -y gimp vlc chromium-browser libreoffice filezilla

# Install Opera using Snap
sudo snap install opera

# Optional Snap installs (uncomment as needed)
sudo snap install signal-desktop
sudo snap install telegram-desktop
sudo snap install slack
sudo snap install discord
sudo snap install whatsie
sudo snap install gallery-dl
