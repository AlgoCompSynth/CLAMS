#! /bin/bash

set -e

echo "Installing command line utilities"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
  info \
  libusb-dev \
  minicom \
  pkg-config

echo "Setting up Pico SDK"
source set_pico_envars
export SKIP_UART=1
export SKIP_VSCODE=1
pushd $PICO_HOME
rm -fr $PICO_PATH
curl -sOL https://raw.githubusercontent.com/raspberrypi/pico-setup/master/pico_setup.sh
chmod +x pico_setup.sh
/usr/bin/time ./pico_setup.sh 2>&1 | tee pico_setup.log
popd

echo "Copying picoprobe udev rules"
sudo cp 99-pico.rules /etc/udev/rules.d/99-pico.rules

echo "Downloading pinout diagram"
curl -sL \
  "https://cdn.shopify.com/s/files/1/0174/1800/files/picovision_diagram.pdf?v=1696414342" > picovision_diagram.pdf

echo Downloading latest debug probe firmware!
curl -sOL \
  "https://github.com/raspberrypi/picoprobe/releases/download/picoprobe-cmsis-v1.0.3/debugprobe.uf2"

if [ -f $HOME/.zshrc ]
then
  echo "Adding Pico envars to $HOME/.zshrc"
  grep -e 'mkdir' -v set_pico_envars >> $HOME/.zshrc
fi

echo "Finished!"
