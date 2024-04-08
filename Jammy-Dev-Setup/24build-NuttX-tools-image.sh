#! /bin/bash

set -e

source set_pico_envars

pushd $NUTTX_PATH/nuttx/tools/ci/docker/linux
echo "Builing tools image"
/usr/bin/time docker build --tag localhost/nuttx-tools-image:latest .
popd

echo "Making tools container"
docker run -d --name nuttx-tools-image-container localhost/nuttx-tools-image:latest
sleep 10
docker ps -a

echo "Copying tools"
rm -fr $NUTTX_PATH/tools
docker cp --follow-link nuttx-tools-image-container:/tools $NUTTX_PATH/
sudo chown -R $USER:$USER $NUTTX_PATH/tools

echo "Finisehd!"
