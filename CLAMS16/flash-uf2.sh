#! /bin/bash

set -e

if [ `df | grep -e '/media/znmeb/RPI-RP2' | wc -l` -gt "0" ]
then
  cp build/CLAMS16.uf2 /media/znmeb/RPI-RP2/
  exit 0
else
  echo "No RPI-RP2 USB Drive!!"
fi
exit -255
