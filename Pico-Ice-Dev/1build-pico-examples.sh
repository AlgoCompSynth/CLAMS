#! /bin/bash

set -e

pushd pico-ice-sdk/examples

for example in `ls -1 | grep "^pico"`
do
  echo "Building $example"
  pushd $example
    rm -fr build; mkdir build; pushd build

    echo "Running cmake for debug build"
    cmake -DCMAKE_BUILD_TYPE=Debug .. || true

    echo "Building binaries"
    make --jobs=6 || true

    popd

  popd

done

popd

echo "Finished!"
