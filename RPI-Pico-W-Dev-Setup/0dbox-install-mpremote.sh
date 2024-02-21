#! /bin/bash

set -e

echo "Creating fresh mpremote venv"
python3 -m venv --clear dbox-mpremote

echo "Activating mpremote venv"
source dbox-mpremote/bin/activate

echo "Installing mpremote"
pip install --upgrade pip
pip install --upgrade mpremote

echo "Testing mpremote"
mpremote connect list
