#! /usr/bin/env bash

set -e

echo "Installing PlatformIO rules"
curl -fsSL $PLATFORMIO_UDEV_RULES_URL | sudo tee $PLATFORMIO_UDEV_RULES_PATH
