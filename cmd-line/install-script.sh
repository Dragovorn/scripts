#!/usr/bin/bash

print() {
  echo "install-script: $1"
}

die() {
  print "$1"
  exit
}

DEFAULT_INSTALL_DIR="/usr/local/bin"

if [ -z "$1" ]; then
  die "script path required!"
fi

INSTALL_DIR="$DEFAULT_INSTALL_DIR"

if [ ! -z "$2" ]; then
  INSTALL_DIR="$2"
  INSTALL_DIR="${INSTALL_DIR/#~/$HOME}"
fi

SCRIPT="$1"
SCIPRT="${SCRIPT/#~/$HOME}"
SCRIPT_PATH=`readlink -f $SCIPRT`
INSTALL_PATH=`readlink -f $INSTALL_DIR`
SCRIPT_NAME=`basename -- "$SCRIPT_PATH"`
LINK_PATH="$INSTALL_PATH/${SCRIPT_NAME%.*}"

if [ -L "$LINK_PATH" ]; then
  die "link $LINK_PATH already exists, aborting!"
fi

print "installing script: $SCRIPT_NAME to $INSTALL_PATH..."

sudo ln -s "$SCRIPT_PATH" "$LINK_PATH"

print "created symlink: $SCRIPT_PATH -> $LINK_PATH"
