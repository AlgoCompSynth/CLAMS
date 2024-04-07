#! /bin/bash

set -e

source set_pico_envars
export NUTTXTOOLS=$NUTTX_PATH/tools

echo "Removing existing $NUTTXTOOLS if any"
rm -fr $NUTTXTOOLS

echo "Patch install script for local Rust install"
diff patched-ubuntu.sh $NUTTX_PATH/nuttx/tools/ci/platforms/ubuntu.sh || true
cp patched-ubuntu.sh $NUTTX_PATH/nuttx/tools/ci/platforms/ubuntu.sh
pushd $NUTTX_PATH/nuttx/tools/ci/platforms
echo "Compiling cross-build tools"
/usr/bin/time ./ubuntu.sh > $NUTTX_PATH/build-tools.log 2>&1 &
popd

echo "Tool build background job started!"
