#! /bin/bash

set -e

echo "Starting minicom"
ls -al /dev/ttyA*
sleep 15
minicom -b 115200 -o -D /dev/ttyACM2
