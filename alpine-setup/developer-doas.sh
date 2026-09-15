#! /bin/sh

set -eu

echo "....Adding packages"
apk add \
    build-base \
    ccache \
    cmake \
    extra-cmake-modules

echo "....Finished"
echo ""
