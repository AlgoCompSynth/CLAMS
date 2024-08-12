#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo ""
echo "Creating fresh $PICO_PATH"
pushd $CLAMS_BASE
sudo rm -fr $PICO_PATH
mkdir --parents $PICO_PATH

echo ""
echo "Cloning repositories"
pushd $PICO_PATH

for repo in $PICO_SDK_URL $PICOTOOL_URL $PICO_EXAMPLES_URL
do
  git clone --recursive $repo
done

echo ""
echo "Installing picotool"

pushd $PICOTOOL_PATH
rm -fr build; mkdir build; cd build
cmake .. 2>&1 | tee cmake.log
sudo make install 2>&1 | tee make.log
picotool version
popd

echo ""
echo Downloading latest debug probe firmware!
curl -sOL \
  "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0/debugprobe_on_pico.uf2"
curl -sOL \
  "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0/debugprobe.uf2"

popd

echo "Finished!"
