# Update system
sudo apt update -y && sudo apt upgrade -y

# Add Sublime Text repository and install
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update -y
sudo apt install -y sublime-text

# Install encfs, wget, and expect
sudo apt install -y encfs wget expect git

# Install development tools
sudo apt install -y gcc libc6-dev libsodium-dev make autoconf unrar

# Install Plasma Discover and Steghide
sudo apt install -y plasma-discover steghide

# Install Tor Browser Launcher
sudo apt install -y torbrowser-launcher

# Install GIMP, VLC, Chromium, LibreOffice, and FileZilla
sudo apt install -y gimp vlc chromium-browser libreoffice filezilla

# Install Flatpak support and add Flathub repository
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Opera using Flatpak
flatpak install -y flathub com.opera.Opera

# Install other apps using Flatpak (replacing Snap)
flatpak install -y flathub org.signal.Signal           # Signal Desktop
flatpak install -y flathub org.telegram.desktop        # Telegram Desktop
flatpak install -y flathub com.slack.Slack             # Slack
flatpak install -y flathub com.discordapp.Discord      # Discord
flatpak install -y flathub io.github.mimbrero.Whatsie  # Whatsie
flatpak install -y flathub io.github.gilbertchen.gallery_dl # Gallery-dl
