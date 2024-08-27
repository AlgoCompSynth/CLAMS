#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Activating CLAMS Python virtual environment"
source $ACTIVATE_CLAMS_VENV

echo "Installing with pip"
# https://docs.platformio.org/en/latest/core/installation/methods/pypi.html#installation-pypi
python3 -m pip install --upgrade platformio

echo "Deactivating CLAMS Python virtual environment"
deactivate

echo "Finished"
