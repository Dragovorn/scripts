#!/bin/bash

echo "Installing all files in cmd-line to /usr/lib/jvm..."
cp -v -a cmd-line/. /usr/local/bin
echo "Done! Scripts should be usable!"
