#! /bin/bash

set -e

source set_pico_envars

pushd $NUTTX_PATH/nuttx/tools/ci/docker/linux
echo "Builing tools image"
/usr/bin/time podman build --tag localhost/nuttx-tools-image:latest .
popd

echo "Making tools container"
podman rm -f nuttx-tools-container || true
podman create --name nuttx-tools-container localhost/nuttx-tools-image:latest
sleep 10
podman ps -a

echo "Copying tools"
rm -fr $NUTTX_TOOLS
podman cp nuttx-tools-container:/tools $NUTTX_PATH/

echo "Finished!"
