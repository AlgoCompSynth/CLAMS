#! /usr/bin/env bash

set -e

export PREFIX=$HOME/.local
export LOGS=$PREFIX/logs
export PDFS=$PREFIX/pdfs

pushd $PREFIX/..
  echo "Creating tarball forth-install.tar.xz"
  tar cJf forth-install.tar.xz $(basename $PREFIX)
popd

echo "Finished"
