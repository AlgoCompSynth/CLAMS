#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating virtual environment $PLATFORMIO_VENV"
python3 -m venv $PLATFORMIO_VENV
echo "Activating virtual environment $PLATFORMIO_VENV"
source $ACTIVATE_PLATFORMIO_VENV

echo "Installing with pip"
# https://docs.platformio.org/en/latest/core/installation/methods/pypi.html#installation-pypi
python3 -m pip install --upgrade platformio

echo "Deactivating virtual environment $PLATFORMIO_VENV"
deactivate

echo "Finished"
