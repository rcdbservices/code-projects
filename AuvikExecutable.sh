#!/bin/bash
set -e 
function notify_step() {
  echo -e "\n========================"
  echo "$1"
  echo "========================"
}
notify_step "Updating package lists..."
sudo apt update -y
notify_step "Installing packages..."
sudo apt install bash curl openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh

notify_step "Adding AnyDesk GPG key and repository..."
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list

notify_step "Installing AnyDesk..."
sudo apt install -y anydesk

notify_step "Configuring UFW firewall for AnyDesk..."
sudo ufw allow 6568/tcp
sudo ufw allow 7070/tcp
sudo ufw allow 50001/tcp
sudo ufw reload

notify_step "Setting AnyDesk password..."
echo "1Wan@2025\$\$" | sudo anydesk --set-password

notify_step "Disabling Wayland and configuring GDM..."
sudo sed -i '/^#WaylandEnable=false/s/^#//' /etc/gdm3/custom.conf
sudo sed -i '/^#AutomaticLoginEnable/s/^#//' /etc/gdm3/custom.conf
sudo sed -i '/^#AutomaticLogin/s/^#//' /etc/gdm3/custom.conf

USERNAME=$(whoami)
sudo sed -i "s/AutomaticLogin = .*/AutomaticLogin = $USERNAME/" /etc/gdm3/custom.conf

notify_step "Setup and configuration completed successfully!"
while true; do
  read -p "Do you want to reboot the system now? (Y/N): " REBOOT_CHOICE
  case "$REBOOT_CHOICE" in
    [Yy]* ) notify_step "Rebooting now..."; sudo reboot; break;;
    [Nn]* ) notify_step "Reboot skipped. Please reboot the system manually if required."; break;;
    * ) echo "Please answer Y (yes) or N (no).";;
  esac
done
