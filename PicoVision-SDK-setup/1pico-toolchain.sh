#! /bin/bash

set -e

echo "Setting up Pico SDK"
source set_pico_envars
pushd $PICO_HOME
curl -sOL https://raw.githubusercontent.com/raspberrypi/pico-setup/master/pico_setup.sh
chmod +x pico_setup.sh
./pico_setup.sh
popd

echo "Copying picoprobe udev rules"
sudo cp 99-pico.rules /etc/udev/rules.d/99-pico.rules

echo "Finished!"
