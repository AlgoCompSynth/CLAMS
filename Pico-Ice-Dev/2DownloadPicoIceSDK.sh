#! /bin/bash

set -e

source set_pico_ice_envars

echo "Downloading pico-ice SDK"
rm -fr pico-ice-sdk*
curl -sL $PICO_ICE_SDK | tar xzvf -

echo "Finished!"
