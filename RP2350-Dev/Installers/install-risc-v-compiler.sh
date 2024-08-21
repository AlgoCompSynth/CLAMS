#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Creating fresh $PICO_UTILITIES_PATH"
mkdir --parents $PICO_UTILITIES_PATH
pushd $PICO_UTILITIES_PATH
  echo ""
  echo "Downloading RISC-V cross-compiler tarball"
  rm -f $RISCV_COMPILER_TARBALL
  /usr/bin/time curl -sOL $RISCV_COMPILER_URL

  echo "Installing"
  rm -fr $RISCV_COMPILER_PATH
  /usr/bin/time tar --extract \
    --file $RISCV_COMPILER_TARBALL \
    > extract.log 2>&1
popd
$RISCV_COMPILER_PATH/bin/riscv32-corev-elf-gcc --version

echo "Install complete"