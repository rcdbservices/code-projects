#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to display progress
function notify_step() {
  echo -e "\n========================"
  echo "$1"
  echo "========================"
}

# Update and upgrade the package lists
notify_step "Updating package lists..."
sudo apt update -y

# Add AnyDesk GPG key and repository
notify_step "Adding AnyDesk GPG key and repository..."
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list

# Install AnyDesk
notify_step "Installing AnyDesk..."
sudo apt install -y anydesk

# Configure UFW firewall to allow AnyDesk ports
notify_step "Configuring UFW firewall for AnyDesk..."
sudo ufw allow 6568/tcp
sudo ufw allow 7070/tcp
sudo ufw allow 50001/tcp
sudo ufw reload

# Set AnyDesk password
notify_step "Setting AnyDesk password..."
echo "1Wan@2025\$\$" | sudo anydesk --set-password

# Disable Wayland and configure GDM
notify_step "Disabling Wayland and configuring GDM..."
sudo sed -i '/^#WaylandEnable=false/s/^#//' /etc/gdm3/custom.conf
sudo sed -i '/^#AutomaticLoginEnable/s/^#//' /etc/gdm3/custom.conf
sudo sed -i '/^#AutomaticLogin/s/^#//' /etc/gdm3/custom.conf

# Replace $USERNAME with the actual username
USERNAME=$(whoami)
sudo sed -i "s/AutomaticLogin = .*/AutomaticLogin = $USERNAME/" /etc/gdm3/custom.conf

# Ask for reboot
notify_step "Setup and configuration completed successfully!"
read -p "Do you want to reboot the system now? (Y/N): " REBOOT_CHOICE
case "$REBOOT_CHOICE" in
  [Yy]* ) notify_step "Rebooting now..."; sudo reboot;;
  * ) notify_step "Reboot skipped. Please reboot the system manually if required.";;
esac
