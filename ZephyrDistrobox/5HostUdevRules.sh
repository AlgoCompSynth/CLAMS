#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ./SetEnvars.sh

echo "Copying 'udev' rules"
echo "ZEPHYR_UDEV_RULES: $ZEPHYR_UDEV_RULES"
sudo cp $ZEPHYR_UDEV_RULES /etc/udev/rules.d/
sudo udevadm control --reload

echo "Finished"
