#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Installing PlatformIO rules"
curl -fsSL $PLATFORMIO_UDEV_RULES_URL | sudo tee $PLATFORMIO_UDEV_RULES_PATH

echo "Installing Raspberry Pi Pico rules"
sudo cp 99-pico.rules $SYSTEM_UDEV_PATH/

echo "Installing SparkFun rules"
sudo cp 99-sparkfun.rules $SYSTEM_UDEV_PATH/

echo "Installing Arduino MBED rules"
sudo ./arduino_mbed_rules.sh

echo "Reloading"
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Finished"
