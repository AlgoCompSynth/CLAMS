#! /bin/bash

set -e

source set_pico_envars

echo "Downloading MicroPython release $PICOVISION_VERSION"
curl -sOL \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-v$PICOVISION_VERSION-micropython.uf2"
curl -sOL \
  "https://github.com/pimoroni/picovision/releases/download/v$PICOVISION_VERSION/pimoroni-picovision-widescreen-v$PICOVISION_VERSION-micropython.uf2"

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

echo "Creating fresh 'mpremote' virtual environment"
python3 -m venv mpremote --clear
source ./mpremote/bin/activate
pip install --upgrade mpremote
echo "Testing mpremote"
mpremote connect list

echo "To use 'mpremote', type 'source ./mpremote/bin/activate'"
sleep 5

echo "Finished!"
