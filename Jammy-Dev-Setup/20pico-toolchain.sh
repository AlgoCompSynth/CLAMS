#! /bin/bash

set -e

echo ""; sleep 2
echo "Setting up Pico SDK"
source set_pico_envars
export SKIP_UART=1
export SKIP_VSCODE=1
pushd $PICO_HOME
rm -fr $PICO_PATH
curl -sOL https://raw.githubusercontent.com/raspberrypi/pico-setup/master/pico_setup.sh
chmod +x pico_setup.sh
/usr/bin/time ./pico_setup.sh 2>&1 | tee pico_setup.log
popd

echo ""; sleep 2
echo Downloading latest debug probe firmware!
curl -sOL \
  "https://github.com/raspberrypi/picoprobe/releases/download/picoprobe-cmsis-v1.0.3/debugprobe.uf2"

echo "Finished!"
