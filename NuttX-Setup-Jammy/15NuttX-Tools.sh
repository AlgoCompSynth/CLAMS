#! /bin/bash

set -e

echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

source ./set_pico_envars

pushd $NUTTX_PATH/nuttx/tools/ci/docker/linux
echo ""
echo "Builing tools image"
/usr/bin/time docker build --tag localhost/nuttx-tools-image:latest .
popd

echo ""
echo "Making tools container"
docker rm -f nuttx-tools-container || true
docker create --name nuttx-tools-container localhost/nuttx-tools-image:latest
sleep 10
docker ps -a

echo ""
echo "Copying tools"
rm -fr $NUTTX_TOOLS
docker cp nuttx-tools-container:/tools $NUTTX_PATH/

echo "Finished!"
