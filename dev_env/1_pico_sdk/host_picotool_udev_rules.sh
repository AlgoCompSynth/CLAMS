#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Installing picotool udev rules"
sudo cp 99-picotool.rules $SYSTEM_UDEV_PATH/

echo "Reloading"
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Finished"
