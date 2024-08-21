#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

pushd $PICO_UTILITIES_PATH
  echo ""
  echo "Downloading Arm cross-compiler tarball"
  rm -f $ARM_COMPILER_TARBALL
  /usr/bin/time curl -sOL $ARM_COMPILER_URL

  echo "Installing"
  mkdir --parents $ARM_COMPILER_PATH
  /usr/bin/time tar --extract \
    --file $ARM_COMPILER_TARBALL \
    --strip-components=1 \
    --directory=$ARM_COMPILER_PATH \
    > arm-extract.log 2>&1
popd
$ARM_COMPILER_PATH/bin/arm-none-eabi-gcc --version

echo "Install complete"
