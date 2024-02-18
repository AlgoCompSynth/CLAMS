#! /bin/bash

set -e

source set_pico_envars

echo "Downloading MicroPython release $PICOVISION_VERSION"
curl -sOL $PICOVISION_PYTHON_DOWNLOAD
curl -sOL $PICOVISION_PYTHON_WIDESCREEN_DOWNLOAD

echo "Downloading flash_nuke.uf2"
# https://www.raspberrypi.com/documentation/microcontrollers/raspberry-pi-pico.html#resetting-flash-memory
curl -sOL https://datasheets.raspberrypi.com/soft/flash_nuke.uf2

if [ `which apt-get | wc -l ` -le "0" ]
then
  echo "No apt-get - exiting"
  exit
fi
echo "Installing 'python3-venv' if needed"
sudo apt-get install -qqy --no-install-recommends python3-venv

# run separate script for mpremote virtual environment
./install-mpremote.sh

echo "Finished!"
