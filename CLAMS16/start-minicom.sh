#! /bin/bash

set -e

echo "Starting minicom"
minicom -b 115200 -o -D /dev/ttyACM0
