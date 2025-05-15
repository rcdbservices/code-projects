#!/bin/bash

set -e

# Function to display progress
function notify_step() {
  echo -e "\n========================"
  echo "$1"
  echo "========================"
}

notify_step "Installing xserver-xorg-video-dummy..."
sudo apt-get update
sudo apt-get install -y xserver-xorg-video-dummy

notify_step "Creating /etc/X11/xorg.conf file..."
sudo bash -c 'cat > /etc/X11/xorg.conf <<EOF
Section "Device"
    Identifier  "Dummy Video Device"
    Driver      "dummy"
EndSection

Section "Monitor"
    Identifier  "Dummy Monitor"
    HorizSync    31.5 - 48.5
    VertRefresh  50.0 - 70.0
EndSection

Section "Screen"
    Identifier  "Dummy Screen"
    Monitor     "Dummy Monitor"
    Device      "Dummy Video Device"
    DefaultDepth 24
    SubSection "Display"
        Depth       24
        Modes       "1920x1080"
    EndSubSection
EndSection

Section "ServerLayout"
    Identifier  "Server Layout"
    Screen 0    "Dummy Screen"
EndSection
EOF'

notify_step "Configuration completed successfully! The xserver-xorg-video-dummy package is installed, and /etc/X11/xorg.conf is configured."

while true; do
  read -p "Do you want to reboot the system now? (Y/N): " REBOOT_CHOICE
  case "$REBOOT_CHOICE" in
    [Yy]* ) notify_step "Rebooting now..."; sudo reboot; break;;
    [Nn]* ) notify_step "Reboot skipped. Please reboot the system manually if required."; break;;
    * ) echo "Please answer Y (yes) or N (no).";;
  esac
done
