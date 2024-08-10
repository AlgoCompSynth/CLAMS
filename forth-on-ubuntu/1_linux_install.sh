#! /usr/bin/env bash

set -e

export LOGFILE=$PWD/Logs/1_linux_install.log

/usr/bin/time sudo apt-get install \
  gforth \
  pforth \
  texlive-base \
  >> $LOGFILE 2>&1

echo "Finished"
