#! /bin/bash

set -e

export MAMBAFORGE_HOME="$HOME/mambaforge"

if [ ! -d "$MAMBAFORGE_HOME" ]
then
  echo "$MAMBAFORGE_HOME doesn't exist"
  echo "Installing mambaforge"

  export ARCH=`uname -m`
  echo "ARCH: $ARCH"
  if [ $ARCH == "armv7l" ]
  then
    echo "Sorry - no Mambaforge release exists for $ARCH"
    exit
  fi

  pushd /tmp

    echo "Downloading latest Mambaforge installer"
    rm -fr Mambaforge*
    wget -q \
      https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-$ARCH.sh
    chmod +x Mambaforge-Linux-$ARCH.sh

    echo "Installing Mambaforge to '$MAMBAFORGE_HOME' ..."
    ./Mambaforge-Linux-$ARCH.sh -b -p $MAMBAFORGE_HOME

    popd
fi

echo "Enabling 'conda' and 'mamba'"
source $MAMBAFORGE_HOME/etc/profile.d/conda.sh
source $MAMBAFORGE_HOME/etc/profile.d/mamba.sh

echo "Activating 'base'"
mamba activate base

echo "Disabling auto-activation of 'base' environment"
conda config --set auto_activate_base false

echo "Setting default threads to number of processors"
conda config --set default_threads `nproc`

echo "Updating base packages"
mamba update --name base --all --yes --quiet

echo "Setting up bash command line"
conda init bash
mamba init bash
echo "export MAMBAFORGE_HOME=$MAMBAFORGE_HOME" >> ~/.bash_aliases

if [ -e $HOME/.zshrc ]
then
  echo "Setting up zsh command line"
  conda init zsh
  mamba init zsh
  echo "export MAMBAFORGE_HOME=$MAMBAFORGE_HOME" >> ~/.zshrc
fi

echo "Creating fresh Mamba environment 'PicoVision' with 'mpremote'"
. "$MAMBAFORGE_HOME/etc/profile.d/conda.sh"
. "$MAMBAFORGE_HOME/etc/profile.d/mamba.sh"
mamba create --force --yes --quiet --name PicoVision \
  python \
  pip
mamba activate PicoVision
pip install --quiet --upgrade mpremote

echo "Finished!"
