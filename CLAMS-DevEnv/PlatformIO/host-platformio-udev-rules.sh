#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Installing udev rules"
sudo cp ../99-pico.rules $SYSTEM_UDEV_PATH/
curl -fsSL $PLATFORMIO_UDEV_RULES_URL | sudo tee $PLATFORMIO_UDEV_RULES_PATH
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Finished"
