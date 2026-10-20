#! /bin/sh

set -eu

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/faust.log
echo "" > $LOGFILE

echo "....Adding packages"
doas apk add -vv \
    arduino-cli@testing \
    binutils-doc \
    build-base \
    ccache \
    ccache-doc \
    clang20 \
    clang20-ccache \
    clang20-dev \
    clang20-extra-tools \
    clang20-headers \
    clang20-libclang \
    clang20-libs \
    clang20-rtlib \
    clang20-static \
    faust@testing \
    faust-dev@testing \
    faust-doc@testing \
    faust-static@testing \
    faust-tools@testing \
    faust-vim@testing \
    gcc-doc \
    gmp-doc \
    llvm20 \
    llvm20-dev \
    llvm20-gtest \
    llvm20-libs \
    llvm20-linker-tools \
    llvm20-static \
    llvm20-test-utils \
    llvm20-test-utils-pyc \
    make-doc \
    mpc1-doc \
    mpfr4-doc \
    patch-doc \
    platformio-core@testing \
    >> $LOGFILE 2>&1

echo "....Listing Faust version"
faust --version > faust-version.txt
echo "" >> faust-version.txt
ls -1 /usr/bin/faust2* | sed 's;/usr/bin/;;' >> faust-version.txt

echo "....Indexing man pages"
doas makewhatis

echo "....Updating plocate database"
doas updatedb

echo "....Finished"
echo ""
