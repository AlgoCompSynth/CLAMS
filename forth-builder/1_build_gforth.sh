#! /usr/bin/env bash

set -e

echo "Creating Projects directory"
mkdir --parents $HOME/Projects

echo "Creating output destination"
export PREFIX=$HOME/.local
export LOGS=$PREFIX/logs
export PDFS=$PREFIX/pdfs
mkdir --parents $LOGS
mkdir --parents $PDFS

pushd $HOME/Projects
  echo "Getting source tarball"
  rm -fr gforth*
  curl -sOL https://www.complang.tuwien.ac.at/forth/gforth/Snapshots/current/gforth.tar.xz
  tar xJf gforth.tar.xz

  echo "Installing dependencies"
  cd gforth-*
  export BUILD_FROM="tarball"
  source ./install-deps.sh > $LOGS/install-deps.log 2>&1

  echo "Configuring"
  ./configure --prefix=$PREFIX > $LOGS/configure.log 2>&1

  echo "Building gforth"
  make > $LOGS/make.log 2>&1

  echo "Making PDF documents"
  cd doc
  make pdf > $LOGS/pdf.log 2>&1
  cp *.pdf $PDFS/
  cd ..

  echo "Installing gforth"
  sudo make install > $LOGS/install.log 2>&1
  sudo chown -R $USER:$USER $PREFIX
popd

echo "Finished"
