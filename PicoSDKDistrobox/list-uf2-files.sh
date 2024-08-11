#! /bin/bash

set -e

echo "Setting CLAMS_BASE to CLAMS-Distrobox home"
export CLAMS_BASE=$HOME/CLAMS-Distrobox

echo ""
echo "Setting environment variables"
source ./set_pico_envars

find $PICO_PATH -name '*.uf2'

echo "Finished!"
