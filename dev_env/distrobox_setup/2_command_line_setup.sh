#! /bin/bash

set -e

echo "Cloning powerlevel10k"
rm -fr $HOME/powerlevel10k*
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k-media.git $HOME/powerlevel10k-media

echo "Downloading patched MesloLG Nerd fonts"
mkdir --parents $HOME/.fonts
pushd $HOME/.fonts
cp $HOME/powerlevel10k-media/*.ttf .
popd

echo "Setting configuration files"
cp bashrc $HOME/.bashrc
cp bash_aliases $HOME/.bash_aliases
cp vimrc $HOME/.vimrc
cp zshrc $HOME/.zshrc
cp p10k.zsh $HOME/.p10k.zsh

echo "Creating $HOME/.local/bin and $HOME/bin"
mkdir --parents $HOME/.local/bin
mkdir --parents $HOME/bin

echo "Copying ../set_pico_envars to $HOME"
cp ../set_pico_envars $HOME/

echo "Finished"
