#! /bin/bash

set -e

source set_pico_envars

pushd $NUTTX_PATH/nuttx/tools/ci/docker/linux
echo "Builing tools image"
/usr/bin/time podman build --tag localhost/nuttx-tools-image:latest .
popd

echo "Finisehd!"
