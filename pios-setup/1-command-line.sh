#! /bin/sh

set -eu

echo "....Setting up home directories"
mkdir --parents $HOME/.local/bin $HOME/Logfiles $HOME/Projects

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/command-line.log
echo "" > $LOGFILE

echo "....Upgrading if needed"
sudo apt-get update \
    && sudo apt-get dist-upgrade

echo "....Adding packages"
sudo apt-get install -qqy \
    curl \
    file \
    fennel \
    git \
    htop \
    lua5.1 \
    luajit \
    lynx \
    neovim \
    plocate \
    ripgrep \
    starship \
    time \
    tmux \
    tree \
    wget \
    >> $LOGFILE 2>&1

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

echo "....Setting tmux configuration file"
cp tmux.conf $HOME/.tmux.conf

echo "....Setting starship configuration file"
cp starship.toml $HOME/.config/

if [ "$(grep starship $HOME/.bashrc | wc -l)" = "0" ]
then
  echo "....Appending starship init to $HOME/.bashrc"
  echo "" >> $HOME/.bashrc
  echo 'eval "$(starship init bash)"' >> $HOME/.bashrc

fi

echo "....Indexing man pages"
sudo mandb

echo "....Updating plocate database"
sudo updatedb

echo ""
echo ""
echo "....Command line setup complete - log out and back in again"

echo "....Finished"
echo ""
