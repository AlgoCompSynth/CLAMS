#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

export HERE=$PWD
pushd $PICO_PATH

echo "Downloading Pimoroni examples"
git clone -b $PIMORONI_PICO_VERSION https://github.com/pimoroni/pimoroni-pico.git --recurse-submodules

echo "Downloading Pimoroni picovision"
git clone -b $PICOVISION_VERSION https://github.com/pimoroni/picovision.git --recurse-submodules

echo "Downloading Pimoroni picovision-boilerplate"
git clone -b $PICOVISION_BOILERPLATE_VERSION https://github.com/pimoroni/picovision-boilerplate.git --recurse-submodules

echo "Downloading Pimoroni picovision-projects"
git clone -b $PICOVISION_PROJECTS_VERSION https://github.com/MichaelBell/picovision-projects.git --recurse-submodules
cp $HERE/CMakeLists.txt.fixed $PICO_PICOVISION_PROJECTS_PATH/CMakeLists.txt

popd

echo "Finished!"
