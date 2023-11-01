#! /bin/bash

set -e

rm -fr build; mkdir build; pushd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make --jobs=`nproc`
ls -Altr
popd
