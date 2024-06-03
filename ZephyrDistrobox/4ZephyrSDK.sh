#! /usr/bin/env bash

set -e

echo "Defining environment variables"
export LOGFILE=$PWD/Logs/ZephyrSDK.log
export ZEPHYR_PROJECT=$HOME/zephyrproject
export ZEPHYR_SDK_URL="https://github.com/zephyrproject-rtos/sdk-ng/releases/download"
export ZEPHYR_SDK_VERSION="0.16.5-1"
export ZEPHYR_SDK_TARBALL="zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz"

# https://docs.zephyrproject.org/latest/develop/getting_started/index.html
echo ""
echo "Downloading and checking tarball"
pushd /tmp
rm -fr zephyr-sdk-* *.sha256sum
wget --quiet \
  "$ZEPHYR_SDK_URL/v$ZEPHYR_SDK_VERSION/$ZEPHYR_SDK_TARBALL"
wget --quiet -O - "$ZEPHYR_SDK_URL/v$ZEPHYR_SDK_VERSION/sha256.sum" \
  | shasum --check --ignore-missing
echo "Unpacking tarball"
tar xf "$ZEPHYR_SDK_TARBALL" \
  >> $LOGFILE 2>&1
echo "Moving zephyr-sdk-$ZEPHYR_SDK_VERSION to $ZEPHYR_PROJECT"
mv zephyr-sdk-$ZEPHYR_SDK_VERSION $ZEPHYR_PROJECT/
popd

echo ""
echo "Finished"
