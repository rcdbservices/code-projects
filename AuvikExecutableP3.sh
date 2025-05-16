#!/bin/bash

set -e

# Function to display progress
function notify_step() {
  echo -e "\n========================"
  echo "$1"
  echo "========================"
}

notify_step "Installing dbus-x11..."
sudo apt install dbus-x11 -y

notify_step "Fix Screen Timeout and Idle Activity"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

notify_step "Installing xserver-xorg-video-dummy..."
sudo apt-get update
sudo apt-get install -y xserver-xorg-video-dummy

sudo rm -f /etc/X11/xorg.conf

echo -e "\n========================"
sudo anydesk --get-id
echo "========================\n"

notify_step "Restarting the display manager to apply the new configuration."
sudo systemctl restart display-manager

notify_step "Configuration completed successfully! The xserver-xorg-video-dummy package is installed, and /etc/X11/xorg.conf is configured."

while true; do
  read -p "Do you want to reboot the system now? (Y/N): " REBOOT_CHOICE
  case "$REBOOT_CHOICE" in
    [Yy]* ) notify_step "Rebooting now..."; sudo reboot; break;;
    [Nn]* ) notify_step "Reboot skipped. Please reboot the system manually if required."; break;;
    * ) echo "Please answer Y (yes) or N (no).";;
  esac
done
