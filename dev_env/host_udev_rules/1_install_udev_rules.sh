#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Installing Arduino MBED rules"
sudo ./arduino_mbed_rules.sh

echo "Installing PlatformIO rules"
./platformio_udev_rules.sh

echo "Reloading"
./reload_udev_rules.sh

echo "Finished"
