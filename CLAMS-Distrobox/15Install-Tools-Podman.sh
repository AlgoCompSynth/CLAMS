#! /bin/bash

set -e

echo "Setting CLAMS_BASE to CLAMS-Distrobox home"
export CLAMS_BASE=$HOME/CLAMS-Distrobox

source ./set_pico_envars

pushd $NUTTX_PATH/nuttx/tools/ci/docker/linux
echo ""
echo "Builing tools image"
/usr/bin/time podman build --tag localhost/nuttx-tools-image:latest .
popd

echo ""
echo "Making tools container"
podman rm -f nuttx-tools-container || true
podman create --name nuttx-tools-container localhost/nuttx-tools-image:latest
sleep 10
podman ps -a

echo ""
echo "Copying tools"
rm -fr $NUTTX_TOOLS
podman cp nuttx-tools-container:/tools $NUTTX_PATH/

echo ""
echo "CLAMS Distrobox is ready!"
echo "1. 'cd ../NuttX-Setup-Jammy'"
echo "2. 'distrobox enter CLAMS'"
echo "3. Continue from './20NuttX-Depends.sh'"

echo ""
echo "Finished!"
