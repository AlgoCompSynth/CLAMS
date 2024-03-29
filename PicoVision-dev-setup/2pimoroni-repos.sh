#! /bin/bash

set -e

source set_pico_envars
pushd $PICO_PATH

echo "Downloading Pimoroni examples"
git clone -b main https://github.com/pimoroni/pimoroni-pico.git --recurse-submodules

echo "Downloading Pimoroni picovision"
git clone -b main https://github.com/pimoroni/picovision.git --recurse-submodules

echo "Downloading Pimoroni picovision-boilerplate"
git clone -b main https://github.com/pimoroni/picovision-boilerplate.git --recurse-submodules

echo "Downloading Pimoroni picovision-projects"
git clone -b main https://github.com/MichaelBell/picovision-projects.git --recurse-submodules

popd

echo "Finished!"
