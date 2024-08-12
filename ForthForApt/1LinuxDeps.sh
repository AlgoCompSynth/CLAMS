#! /usr/bin/env bash

set -e

export LOGFILE=$PWD/Logs/1LinuxDeps.log

/usr/bin/time sudo apt-get install \
  gforth \
  pforth \
  texlive-base \
  >> $LOGFILE 2>&1

echo "Finished"
