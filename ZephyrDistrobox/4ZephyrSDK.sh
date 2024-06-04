#! /usr/bin/env bash

set -e

echo ""
echo "Setting environment variables"
source ./SetEnvars.sh

echo "Defining LOGFILE"
export LOGFILE=$PWD/Logs/ZephyrSDK.log

# https://docs.zephyrproject.org/latest/develop/getting_started/index.html
echo ""; pushd /tmp
rm -fr zephyr-sdk-* *.sha256sum
echo "Downloading tarball"
wget --quiet \
  "$ZEPHYR_SDK_URL/v$ZEPHYR_SDK_VERSION/$ZEPHYR_SDK_TARBALL"
echo "Checking tarball"
wget --quiet -O - "$ZEPHYR_SDK_URL/v$ZEPHYR_SDK_VERSION/sha256.sum" \
  | shasum --check --ignore-missing
echo "Unpacking tarball"
/usr/bin/time tar xf "$ZEPHYR_SDK_TARBALL" \
  >> $LOGFILE 2>&1
echo "Moving $ZEPHYR_SDK_DIRECTORY to $HOME/$ZEPHYR_SDK_DIRECTORY"
mv $ZEPHYR_SDK_DIRECTORY $HOME/$ZEPHYR_SDK_DIRECTORY
popd; echo ""

echo ""; pushd $HOME/$ZEPHYR_SDK_DIRECTORY
echo "Running SDK setup script"
./setup.sh
popd; echo ""

echo "Finished"
