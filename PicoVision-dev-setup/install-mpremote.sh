#! /bin/bash

set -e

echo "Installing mpremote"
pip install --user mpremote
echo "Testing mpremote"
mpremote connect list
