#! /bin/bash

set -e

source set_pico_envars
find $PICO_PATH -name '*.uf2'

echo "Finished!"
