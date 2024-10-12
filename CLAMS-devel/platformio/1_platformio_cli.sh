#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars
export LOGFILE="$PWD/1_platformio_cli.log"
rm --force $LOGFILE

echo "Creating fresh virtual environment $PLATFORMIO_VENV"
rm -fr $PLATFORMIO_VENV
python3 -m venv $PLATFORMIO_VENV --upgrade-deps
echo "Activating virtual environment $PLATFORMIO_VENV"
source $ACTIVATE_PLATFORMIO_VENV

echo "Installing with pip"
# https://docs.platformio.org/en/latest/core/installation/methods/pypi.html#installation-pypi
/usr/bin/time python3 -m pip install --upgrade platformio \
  >> $LOGFILE 2>&1
pio --version

echo "Deactivating virtual environment $PLATFORMIO_VENV"
deactivate

echo "Finished"
