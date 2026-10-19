#! /bin/bash

set -eu

source ./set-envars.sh

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/chuck.log
echo "" > $LOGFILE

echo "....Adding packages"
doas apk add -vv \
    bison \
    flex \
    >> $LOGFILE 2>&1

echo "....Cloning ChucK repository"
pushd $HOME/Projects > /dev/null
    rm -fr chuck
    git clone --quiet $CHUCK_URL
    cd chuck/src

    echo "....Compiling ChucK"
    make --jobs=$MAKE_JOBS linux-all \
        >> $LOGFILE 2>&1

    echo "....Installing Chuck"
    doas make install \
        >> $LOGFILE 2>&1
    doas /sbin/ldconfig

    echo "....Probing ChucK"
    for drv in alsa jack pulse
    do
        chuck --driver:${drv} --probe \
            >> $LOGFILE 2>&1

    done

    popd > /dev/null

echo "....Indexing man pages"
doas makewhatis

echo "....Updating plocate database"
doas updatedb

echo "....Finished"
echo ""
