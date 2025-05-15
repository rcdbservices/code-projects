#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to display progress
function notify_step() {
  echo -e "\n========================"
  echo "$1"
  echo "========================"
}

# Prompt for user inputs
read -p "Enter your email address (e.g., kb@1wan.ph): " USER_EMAIL
read -p "Enter your Auvik subdomain (e.g., 1wanlab): " AUVIK_SUBDOMAIN

# Validate input
if [[ -z "$USER_EMAIL" ]] || [[ -z "$AUVIK_SUBDOMAIN" ]]; then
  echo "Error: Both email and subdomain are required. Exiting."
  exit 1
fi

# Configure power and screen settings
notify_step "Configuring power and screen settings..."
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0

# Disable sleep, suspend, hibernate, and hybrid-sleep targets
notify_step "Disabling sleep, suspend, hibernate, and hybrid-sleep targets..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Install Auvik agent
notify_step "Downloading and installing Auvik agent..."
sudo bash -c "rm -rf ./auvik_installer install.sh && \
  umask 0022 && \
  curl --verbose --location-trusted --header \"Accept: text/plain\" --user $USER_EMAIL https://$AUVIK_SUBDOMAIN.au1.my.auvik.com/agents/installer > install.sh && \
  grep -wq __ARCHIVE_BELOW__ install.sh && \
  chmod 0755 install.sh && \
  bash -x ./install.sh 2>&1 | tee /tmp/install.log"

notify_step "Auvik agent installation completed!"
