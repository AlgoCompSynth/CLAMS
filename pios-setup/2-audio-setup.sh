#! /bin/sh

set -eu

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/audio-setup.log
echo "" > $LOGFILE

echo "....Adding packages"
sudo apt-get install -qqy \
    alsa-utils \
    faust \
    libfaust-static \
    libspa-0.2-bluetooth \
    pipewire \
    pipewire-alsa \
    pipewire-doc \
    pipewire-jack \
    pipewire-pulse \
    rtkit \
    wireplumber \
    wireplumber-doc \
    >> $LOGFILE 2>&1

echo "....Listing Faust version"
faust --version > faust-version.txt
echo "" >> faust-version.txt
ls -1 /usr/bin/faust2* | sed 's;/usr/bin/;;' >> faust-version.txt

echo "....Indexing man pages"
sudo mandb > /dev/null

echo "....Updating plocate database"
sudo updatedb > /dev/null

echo "....Finished"
echo ""
