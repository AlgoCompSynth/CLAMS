#! /bin/bash

set -e

echo ""
echo "Setting environment variables"
source ../set_pico_envars

echo "Cloning $AMY_PATH"
pushd $PICO_PYTHON_PATH
  rm -fr $AMY_PATH
  echo $AMY_URL
  git clone $AMY_URL

  pushd $AMY_PATH/src
    python3 -m venv $AMY_VENV_PATH
    source $AMY_VENV_PATH/bin/activate
    pip3 install --upgrade wheel
    pip3 install .
  popd
popd

echo "Install complete"
