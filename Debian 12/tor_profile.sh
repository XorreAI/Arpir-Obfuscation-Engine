#!/bin/bash

# Get the current username
USER=$(whoami)

# Define the path to the AppArmor directory and the file to be created
APPARMOR_DIR="/etc/apparmor.d"
FIREFOX_FILE="${APPARMOR_DIR}/firefox-local"

# Create the firefox-local profile file
echo "# This profile allows everything and only exists to give the
# application a name instead of having the label 'unconfined'
abi <abi/4.0>,
include <tunables/global>
profile firefox-local
/home/${USER}/bin/firefox/{firefox,firefox-bin,updater}
flags=(unconfined) {
    userns,
    # Site-specific additions and overrides. See local/README for details.
    include if exists <local/firefox>
}" | sudo tee $FIREFOX_FILE > /dev/null

# Restart the apparmor service to apply changes
sudo systemctl restart apparmor.service

echo "AppArmor profile for firefox-local has been created and the service has been restarted."
