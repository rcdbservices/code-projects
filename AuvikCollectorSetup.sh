#!/bin/bash

if [[ "$(head -c 1 "$0" | od -An -t uC)" == "13" ]]; then
  echo "Normalizing this script's line endings..."
  sed -i 's/\r$//' "$0"
fi

set -e  # Exit immediately if a command exits with a non-zero status

# Function to display progress
function notify_step() {
  echo -e "\n========================"
  echo "$1"
  echo "========================"
}

notify_step "Checking if dos2unix is installed..."
if ! command -v dos2unix &> /dev/null; then
  notify_step "dos2unix is not installed. Installing dos2unix..."
  sudo apt update -y
  sudo apt install -y dos2unix
else
  notify_step "dos2unix is already installed."
fi

notify_step "Choose what to download:"
echo "1. AuvikExecutable.sh"
echo "2. AuvikExecutableP2.sh"
echo "3. AuvikExecutableP3.sh"
read -p "Enter your choice (1, 2, or 3): " CHOICE

case $CHOICE in
  1)
    FILE_NAME="AuvikExecutable.sh"
    ;;
  2)
    FILE_NAME="AuvikExecutableP2.sh"
    ;;
  3)
    FILE_NAME="AuvikExecutableP3.sh"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

notify_step "Downloading $FILE_NAME..."
wget -O "$FILE_NAME" "https://github.com/rcdbservices/code-projects/blob/main/$FILE_NAME"

dos2unix
notify_step "Converting $FILE_NAME to Unix format using dos2unix..."
dos2unix "$FILE_NAME"

notify_step "Making $FILE_NAME executable..."
chmod +x "$FILE_NAME"

executable
notify_step "Running $FILE_NAME..."
./"$FILE_NAME"
