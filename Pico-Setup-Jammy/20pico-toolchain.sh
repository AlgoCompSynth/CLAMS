#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

echo ""
echo "Creating fresh $PICO_PATH"
pushd $CLAMS_BASE
rm -fr $PICO_PATH

echo ""
echo "Downloading pico_setup.sh script"
curl -sOL https://raw.githubusercontent.com/raspberrypi/pico-setup/master/pico_setup.sh
chmod +x pico_setup.sh

echo ""
echo "Running pico_setup.sh"
export SKIP_UART=1
export SKIP_VSCODE=1
/usr/bin/time ./pico_setup.sh 2>&1 | tee pico_setup.log
popd

echo ""
echo Downloading latest debug probe firmware!
curl -sOL \
  "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0/debugprobe_on_pico.uf2"
curl -sOL \
  "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0/debugprobe.uf2"

echo "Finished!"
