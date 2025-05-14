#!/bin/bash

# Update and upgrade the package lists
sudo apt update -y

# Add AnyDesk GPG key and repository
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list

# Install AnyDesk
sudo apt install -y anydesk

# Configure UFW firewall to allow AnyDesk ports
sudo ufw allow 6568/tcp
sudo ufw allow 7070/tcp
sudo ufw allow 50001/tcp
sudo ufw reload

# Open and modify GDM3 configuration
sudo sed -i '/^#WaylandEnable=false/s/^#//' /etc/gdm3/custom.conf
sudo sed -i '/^#AutomaticLoginEnable/s/^#//' /etc/gdm3/custom.conf
sudo sed -i '/^#AutomaticLogin/s/^#//' /etc/gdm3/custom.conf

# Replace $USERNAME with the actual username
USERNAME=$(whoami)
sudo sed -i "s/AutomaticLogin = .*/AutomaticLogin = $USERNAME/" /etc/gdm3/custom.conf

# Power and screen settings
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0

# Disable sleep, suspend, hibernate, and hybrid-sleep targets
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "Setup and configuration completed successfully!"