#! /bin/sh

set -eu

echo "....Adding packages"
apk add \
    build-base \
    ccache \
    cmake \
    extra-cmake-modules \
    llvm \
    llvm-dev \
    llvm-gtest \
    llvm-libs \
    llvm-libunwind \
    llvm-libunwind-dev \
    llvm-libunwind-static \
    llvm-linker-tools \
    llvm-runtimes \
    llvm-static \
    llvm-test-utils \
    spirv-llvm-translator \
    spirv-llvm-translator-dev \
    spirv-llvm-translator-libs

echo "....Finished"
echo ""
