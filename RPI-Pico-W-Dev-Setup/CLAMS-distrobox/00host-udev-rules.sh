#! /bin/bash

set -e

echo "This script must be run in host!!!"
echo "Copying picoprobe udev rules"
sudo cp 99-pico.rules /etc/udev/rules.d/99-pico.rules
echo "Finished!"
