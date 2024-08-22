#! /usr/bin/env bash

set -e

export LOGFILE=$PWD/Logs/1LinuxDeps.log
export DEBIAN_FRONTEND=noninteractive

/usr/bin/time sudo apt-get install -qqy --no-install-recommends \
  gforth \
  texlive-base \
  >> $LOGFILE 2>&1

echo "Finished"
