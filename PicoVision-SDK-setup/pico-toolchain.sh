#! /bin/bash

set -e

echo "Copying picoprobe udev rules"
sudo cp 99-pico.rules /etc/udev/rules.d/99-pico.rules

echo "Setting up Pico SDK"
pushd $HOME/Projects
curl -sOL https://raw.githubusercontent.com/raspberrypi/pico-setup/master/pico_setup.sh
chmod +x pico_setup.sh
./pico_setup.sh

echo "Finished!"
