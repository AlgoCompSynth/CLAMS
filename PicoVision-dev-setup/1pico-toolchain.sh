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

echo "Downloading pinout diagram"
curl -sL \
  "https://cdn.shopify.com/s/files/1/0174/1800/files/picovision_diagram.pdf?v=1696414342" > picovision_diagram.pdf

echo "Finished!"
