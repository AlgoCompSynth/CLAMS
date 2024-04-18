#! /bin/bash

set -e

source set_pico_ice_envars

echo "Downloading pico-ice SDK"
rm -fr pico-ice-sdk*
git clone --branch $PICO_ICE_SDK_VERSION $PICO_ICE_SDK_REPO --recursive

echo "Finished!"
