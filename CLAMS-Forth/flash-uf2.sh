#! /bin/bash

set -e

if [ `df | grep -e '/media/znmeb/RPI-RP2' | wc -l` -gt "0" ]
then
  cp build/CLAMS-Forth.uf2 /media/znmeb/RPI-RP2/
  exit 0
else
  echo "No RPI-RP2 USB Drive!!"
fi
exit -255
