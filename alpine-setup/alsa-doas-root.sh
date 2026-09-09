#! /bin/sh

set -eu

echo "....Adding packages"
apk add \
    alsa-plugins \
    alsa-plugins-doc \
    alsa-utils \
    alsa-utils-doc \
    tinyalsa \
    tinyalsa-doc

echo "....Updating plocate database"
updatedb

echo "....Finished"
echo ""
