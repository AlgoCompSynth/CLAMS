#! /bin/sh

set -eu

echo "....Setting up home directories"
# https://wiki.alpinelinux.org/wiki/OpenRC_User_Services#User_runlevels
mkdir --parents $HOME/.local/bin $HOME/Logfiles $HOME/Projects $HOME/.config/rc/runlevels/console

echo "....Setting startup dotfiles"
if [ "$(grep 'end startup code' $HOME/.profile 2> /dev/null | wc -l)" = "0" ]
then
    echo "....Appending startup code to $HOME/.profile"
    cat startup-code.sh >> $HOME/.profile

fi

if [ "$(grep 'end bash aliases' $HOME/.bashrc 2> /dev/null | wc -l)" = "0" ]
then
    echo "....Appending bash aliases to $HOME/.bashrc"
    cat bash-aliases.sh >> $HOME/.bashrc

fi

echo "....Setting neovim configuration files"
mkdir --parents $HOME/.config
cp -rp nvim $HOME/.config

echo "....Setting starship configuration file"
cp starship.toml $HOME/.config/

if [ "$(grep starship $HOME/.bashrc | wc -l)" = "0" ]
then
  echo "....Appending starship init to $HOME/.bashrc"
  echo "" >> $HOME/.bashrc
  echo 'eval "$(starship init bash)"' >> $HOME/.bashrc

fi

echo "....Changing $USER shell to /bin/bash"
doas chsh --shell "/bin/bash" $USER

echo "....Finished"
echo ""
