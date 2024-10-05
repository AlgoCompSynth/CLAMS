#! /usr/bin/env bash

set -e

if [ ! "${#1}" -gt "0" ]
then
  echo "Mandatory first parameter is test directory"
  echo "Mandatory second parameter is fully-qualified board name"
  echo "Optional third parameter is port - default '/dev/ttyACM0'"
  echo "Optional fourth parameter is baudrate - default 115200"
  echo "First parameter is empty - bailing out!!"
  exit -1024
fi

if [ ! -d $1 ]
then
  echo "Mandatory first parameter is test directory"
  echo "Mandatory second parameter is fully-qualified board name"
  echo "Optional third parameter is port - default '/dev/ttyACM0'"
  echo "Optional fourth parameter is baudrate - default 115200"
  echo "$1 is not a directory - bailing out!!"
  exit -1024
fi

export TEST_DIR=$1
echo "TEST_DIR: $TEST_DIR"

if [ ! "${#2}" -gt "0" ]
then
  echo "Second parameter is empty - bailing out!!"
  exit -1024
fi

export FQBN=$2
echo "FQBN: $FQBN"

export PORT=${3-/dev/ttyACM0}
echo "PORT: $PORT"

export BAUDRATE=${3-115200}
echo "BAUDRATE: $BAUDRATE"

echo ""
echo ""
echo "Entering $TEST_DIR"
pushd $TEST_DIR
  echo ""
  echo ""
  echo "Compiling"
  arduino-cli compile \
  --fqbn $FQBN \
  --port $PORT \
  --export-binaries \
  --upload \
  --verify \
  --verbose \
  2>&1 | tee compile.log

  echo ""
  echo ""
  echo "Monitoring"
  arduino-cli monitor --port $PORT --config baudrate=$BAUDRATE

popd
