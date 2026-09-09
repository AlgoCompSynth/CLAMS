#! /bin/sh

set -eu

echo "....Adding packages"
apk add \
    faust \
    faust-dev \
    faust-doc \
    faust-static \
    faust-tools \
    faust-vim

echo "....Listing Faust version"
faust --version > faust-version.txt
echo "" >> faust-version.txt
ls -1 /usr/bin/faust2* | sed 's;/usr/bin/;;' >> faust-version.txt

echo "....Finished"
echo ""
