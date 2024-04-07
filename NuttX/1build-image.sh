#! /bin/bash

set -e

# https://nuttx.apache.org/docs/latest/quickstart/install.html
source set_pico_envars

echo ""; sleep 2
echo "Downloading NuttX version $NUTTX_VERSION"
rm -fr $NUTTX_PATH; mkdir $NUTTX_PATH; pushd $NUTTX_PATH

if [ "$NUTTX_VERSION" = "master" ]
then
  git clone --branch master https://github.com/apache/nuttx.git nuttx
  git clone --branch master https://github.com/apache/nuttx-apps.git apps
else
  git clone --branch nuttx-$NUTTX_VERSION https://github.com/apache/nuttx.git nuttx
  git clone --branch nuttx-$NUTTX_VERSION https://github.com/apache/nuttx-apps.git apps
fi

echo ""; sleep 2
echo "Listing supported configurations onto $NUTTX_PATH/supported-configurations.txt"
cd nuttx
./tools/configure.sh -L > $NUTTX_PATH/supported-configurations.txt

echo ""; sleep 2
echo "Building image"
cd tools/ci/docker/linux
/usr/bin/time podman build --tag nuttx-image . > $NUTTX_PATH/image-build.log 2>&1 &

popd

echo ""; sleep 2
echo "Finished!!"
