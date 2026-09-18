#! /bin/sh

set -eu

echo "....Setting up home directories"
# https://wiki.alpinelinux.org/wiki/OpenRC_User_Services#User_runlevels
mkdir --parents $HOME/.local/bin $HOME/Logfiles $HOME/Projects $HOME/.config/rc/runlevels/console

echo "....Creating logfile"
export LOGFILE=$HOME/Logfiles/command-line-base.log
echo "" > $LOGFILE

echo "....Switching to edge release with tagged @testing!"
diff repositories /etc/apk/repositories || true
doas cp repositories /etc/apk/repositories

echo "....Upgrading if needed"
doas apk upgrade

echo "....Adding packages"
doas apk add -vv \
    bash \
    bash-doc \
    bash-completion \
    bash-completion-doc \
    checkbashisms \
    curl \
    curl-doc \
    dbus \
    dbus-doc \
    doas-doc \
    doas-sudo-shim \
    doas-sudo-shim-doc \
    file \
    git \
    git-doc \
    fenneljit \
    fennel-doc \
    htop \
    htop-doc \
    lua5.1 \
    lua5.1-doc \
    luajit \
    luajit-doc \
    lynx \
    lynx-doc \
    man-pages \
    mandoc \
    mandoc-doc \
    mandoc-apropos \
    mkrundir \
    neovim \
    neovim-doc \
    nerd-fonts-all \
    openssh-doc \
    openssl-doc \
    plocate \
    plocate-doc \
    raspberrypi-bootloader-doc \
    ripgrep \
    ripgrep-doc \
    shadow \
    shadow-doc \
    starship \
    time \
    time-doc \
    tree \
    tree-doc \
    wget \
    wget-doc \
    xdg-utils \
    xdg-utils-doc \
    >> $LOGFILE 2>&1

# https://wiki.alpinelinux.org/wiki/Eudev
echo "....Setting up udev"
doas setup-devd udev

echo ""
echo "....Enabling/starting services"
doas rc-update add dbus
doas rc-service dbus start

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

echo "....Updating plocate database"
doas updatedb

echo "....Changing $USER shell to /bin/bash"
doas chsh --shell "/bin/bash" $USER

echo "....Log out and back in again to activate 'bash' shell"

echo "....Finished"
echo ""
