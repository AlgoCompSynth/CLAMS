#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Appending test envioronments to $CFORTH_PATH/platformio.ini"
cat testing_platformio.ini >> $CFORTH_PATH/platformio.ini

echo "Finished"
