#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo ""
echo "Downloading RISC-V cross-compiler tarball"
mkdir --parents $PICO_UTILITIES
pushd $PICO_UTILITIES
rm -f $RISC_V_COMPILER_TARBALL
/usr/bin/time wget --quiet $RISC_V_COMPILER_URL

echo "Installing to /usr/local/bin"
/usr/bin/time sudo tar --extract \
  --file $RISC_V_COMPILER_TARBALL \
  --directory /usr/local \
  --strip-components=1 \
  > extract.log 2>&1
popd
echo "Install complete"
