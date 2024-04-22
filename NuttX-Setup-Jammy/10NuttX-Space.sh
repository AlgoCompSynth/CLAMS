#! /bin/bash

set -e

# https://nuttx.apache.org/docs/latest/quickstart/install.html
echo "Setting CLAMS_BASE to $HOME"
export CLAMS_BASE=$HOME

echo ""
echo "Setting environment variables"
source ./set_pico_envars

echo ""
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

echo ""
echo "Listing supported configurations onto $NUTTX_PATH/supported-configurations.txt"
cd nuttx
./tools/configure.sh -L | sort -u > $NUTTX_PATH/supported-configurations.txt
cd ..

popd

echo "Finished!!"
