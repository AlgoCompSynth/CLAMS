#! /bin/bash

set -e

source set_pico_envars

pushd $NUTTX_PATH/nuttx/tools/ci/docker/linux
echo "Builing tools image"
/usr/bin/time docker build --tag localhost/nuttx-tools-image:latest .
popd

echo "Creating tools container"
docker create --name nuttx-tools-container localhost/nuttx-tools-image:latest
sleep 10
docker ps -a

echo "Copying xtensa-esp32s3-elf-gcc tools"
rm -fr $NUTTX_PATH/tools/xtensa-esp32s3-elf-gcc; mkdir --parents $NUTTX_PATH/tools
docker cp --follow-link nuttx-tools-container:/tools/xtensa-esp32s3-elf-gcc $NUTTX_PATH/tools
sudo chown -R $USER:$USER $NUTTX_PATH/tools

echo "Removing tools container"
docker rm nuttx-tools-container

echo "Finisehd!"
