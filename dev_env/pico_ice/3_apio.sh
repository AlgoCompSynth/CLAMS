#! /bin/bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating fresh virtual environment $APIO_VENV"
rm -fr $APIO_VENV
python3 -m venv $APIO_VENV --upgrade-deps
echo "Activating virtual environment $APIO_VENV"
source $ACTIVATE_APIO_VENV
echo "Installing apio"
pip3 install --upgrade apio
echo "Installing packages"
apio install --all
echo "Deactivating virtual environment $APIO_VENV"
deactivate

echo ""
echo "Finished"
