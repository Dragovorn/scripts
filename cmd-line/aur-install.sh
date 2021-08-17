#!/bin/bash

print() {
  echo "aur-install: $1"
}

if [ -z "$1" ]; then
  print "needs 1 parameter!"
  exit
fi

if [ -z "$AUR_INSTALL_DIR" ]; then
  AUR_INSTALL_DIR="$HOME/.aur/"
  READ_STR=$(print "install directory ($AUR_INSTALL_DIR): ")

  read -p "$READ_STR" AUR_INSTALL_DIR_SET

  if [ ! -z "$AUR_INSTALL_DIR_SET" ]; then
    AUR_INSTALL_DIR="$AUR_INSTALL_DIR_SET"
  fi

  AUR_INSTALL_DIR="${AUR_INSTALL_DIR/#~/$HOME}"

  EXPORT="export AUR_INSTALL_DIR=\"$AUR_INSTALL_DIR\"  # Added by aur-install"
  RC_FILE="$HOME"

# If this ever needs to support more shells just add their respective detectors & rc file to this ladder.
# (if this doesnt go python once i stop larping and writing this shit in shell and using nano as my editor)
  if [ -z "$BASH_VERSION" ]; then
    RC_FILE="$RC_FILE/.bashrc"
    print "detected bash, appending to $RC_FILE"
  elif [ -z "$ZSH_VERSION" ]; then
    RC_FILE="$RC_FILE/.zshrc"
    print "detected zsh, appending to $RC_FILE"
  fi

  print "echo $EXPORT >> \"$RC_FILE\""
  echo "$EXPORT" >> "$RC_FILE"

# oh-my-zsh seems to have a weird bug that only presents itself if you source the .zshrc from a script
# can't export from this script so ill just beg the user.
  NEW_AUR_INSTALL=TRUE
fi

if [ ! -d "$AUR_INSTALL_DIR" ]; then
  mkdir -p "$AUR_INSTALL_DIR"
fi

PACKAGE="$1"
PACKAGE_DIR="$AUR_INSTALL_DIR/$PACKAGE"
AUR_URL="https://aur.archlinux.org/$PACKAGE.git"

if [ -d "$PACKAGE_DIR" ]; then
  print "$PACKAGE_DIR already exists! executing git pull..."
  cd "$PACKAGE_DIR"
  git pull
else
  git clone $AUR_URL "$PACKAGE_DIR"
  cd "$PACKAGE_DIR"
fi

makepkg -sri

print "done."

if [ ! -z "$NEW_AUR_INSTALL" ]; then
  print "because your installation is new please execute: source $RC_FILE"
fi
