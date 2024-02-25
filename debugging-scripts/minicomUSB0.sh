#! /bin/bash

set -e

echo "Starting minicom"
ls -al /dev/ttyU*
sleep 5
minicom -b 115200 -o -D /dev/ttyUSB0
