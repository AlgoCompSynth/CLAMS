#! /bin/bash

set -e

echo "Copying $PICO_SDK_PATH/external/pico_sdk_import.cmake"
cp $PICO_SDK_PATH/external/pico_sdk_import.cmake .

echo "Creating fresh build directory"
rm -fr build; mkdir --parents build; cd build

echo "Running cmake for debug build"
cmake -DCMAKE_BUILD_TYPE=Debug ..

echo "Building binaries"
make --jobs=`nproc`

ls -Altr
