#!/bin/bash

# HDMI Configuration
HDMI_CONFIG=$(cat <<-END
Section "Device"
    Identifier  "HDMI Video Device"
    Driver      "modesetting"
    Option      "Monitor-HDMI-1" "HDMI Monitor"
EndSection

Section "Monitor"
    Identifier  "HDMI Monitor"
    Option      "PreferredMode" "1920x1080"
    HorizSync    31.5 - 48.5
    VertRefresh  50.0 - 70.0
EndSection

Section "Screen"
    Identifier  "HDMI Screen"
    Monitor     "HDMI Monitor"
    Device      "HDMI Video Device"
    DefaultDepth 24
    SubSection "Display"
        Depth       24
        Modes       "1920x1080"
    EndSubSection
EndSection

Section "ServerLayout"
    Identifier  "Server Layout"
    Screen      "HDMI Screen"
EndSection
END
)

# Dummy Screen Configuration
DUMMY_CONFIG=$(cat <<-END
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
        #Modes       "2560x1080"
        Modes       "1920x1080"
    EndSubSection
EndSection

Section "ServerLayout"
    Identifier  "Server Layout"
    Screen 0    "Dummy Screen"
EndSection
END
)

# Function to notify about steps
notify_step() {
    echo "[NOTIFY] $1"
}

# Function to write configuration to /etc/X11/xorg.conf
write_config() {
    CONFIG_CONTENT=$1
    CONFIG_PATH="/etc/X11/xorg.conf"

    notify_step "Deleting existing $CONFIG_PATH (if it exists)."
    if [ -f "$CONFIG_PATH" ]; then
        sudo rm "$CONFIG_PATH"
    fi

    notify_step "Creating new $CONFIG_PATH with the selected configuration."
    echo "$CONFIG_CONTENT" | sudo tee "$CONFIG_PATH" > /dev/null

    notify_step "Configuration written to $CONFIG_PATH."
}

# Function to restart the necessary process
restart_process() {
    notify_step "Restarting the display manager to apply the new configuration."
    sudo systemctl restart display-manager
    notify_step "Display manager restarted successfully."
}

# Main script starts here
echo "Choose a configuration to deploy:"
echo "1. HDMI"
echo "2. Dummy Screen"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        notify_step "HDMI configuration selected."
        write_config "$HDMI_CONFIG"
        ;;
    2)
        notify_step "Dummy Screen configuration selected."
        write_config "$DUMMY_CONFIG"
        ;;
    *)
        notify_step "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Restart the necessary process
restart_process
