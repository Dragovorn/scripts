#!/bin/bash

print() {
  echo "install: $1"
}

die() {
  print "$1"
  exit
}

INSTALL_PATH="/usr/local/bin"
SCRIPTS_DIR="./cmd-line"

if [ ! -d "$SCRIPTS_DIR" ]; then
  die "could not find installable scripts! is there a $SCRIPTS_DIR directory?"
fi

print "Found scripts directory: $SCRIPTS_DIR"

for f in $SCRIPTS_DIR/*.sh
do
  print "running install script for: $f..."
  $SCRIPTS_DIR/install-script.sh "$f" "$INSTALL_PATH"
done

print "done."
