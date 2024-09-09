#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE=$PWD/host_arduino_mbed_rules.log
rm -f $LOGFILE

echo "Installing Arduino MBED RP2040 'udev' rules as 'root'!!"
sudo "$ARDUINO_INSTALL_PATH/packages/arduino/hardware/mbed_rp2040/4.1.5/post_install.sh" \
  >> $LOGFILE 2>&1
sudo chown $USER:$USER $LOGFILE
ls -l $SYSTEM_UDEV_PATH \
  >> $LOGFILE 2>&1

echo "Finished"
