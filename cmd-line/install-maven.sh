#!/bin/bash

WGET=/usr/bin/wget
TAR=/bin/tar

TEMP_DIR="/tmp/mvn/"
INSTALL_DIR="/usr/lib/mvn/"
SCRIPT_PATH="/etc/profile.d/maven.sh"
INSTALL_TARGET="Maven"

if [ -n "$1" ]; then
    LINK="$1"
fi

if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root!"
    exit
fi

if [ ! -x "$WGET" ]; then
    echo "Wget is not installed!" >&2
    exit 1
elif [ ! -x "$TAR" ]; then
    echo "Tar is not installed?" >&2
fi

if [ -z "$LINK" ]; then
    read -p '${INSTALL_TARGET} tzr.gz download link: ' LINK
fi

LINK_NO_PROTOCOL="${LINK#*//}"
LINK_REL="${LINK_NO_PROTOCOL#*/}"
LINK_PATH="${LINK_REL%%\?*}"
FILE="${LINK_PATH##*/}"

echo "Downloading: $LINK"

if [ -d "${TEMP_DIR}" ]; then
    rm -fr "${TEMP_DIR}"
fi

mkdir -p "${TEMP_DIR}"

$WGET -P "${TEMP_DIR}" $LINK

FILE="${TEMP_DIR}${FILE}"

echo "Download complete!"
echo "Unpacking: $FILE"

mkdir -p "${TEMP_DIR}work"

tar xvf "${FILE}" -C "${TEMP_DIR}work/"

echo "Done unpacking!"

for dir in ${TEMP_DIR}work/*/ ; do
    echo "Installing: ${dir}"

    echo "Moving ${INSTALL_TARGET} dir..."

    DIR_FILE=`basename $dir`
    INSTALLED_DIR="${INSTALL_DIR}${DIR_FILE}"

    if [ -d $INSTALLED_DIR ]; then
        read -p "${INSTALLED_DIR} already exists! Overwrite? (Y/N): "  -n 1 -r
        echo

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cannot proceed, aborting..."
            [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
        fi

        echo "Deleting ${INSTALLED_DIR}..."
        rm -fr $INSTALLED_DIR
    fi

    mv $dir $INSTALL_DIR

    if [ -f $SCRIPT_PATH ]; then
        echo "Removing pre-existing ${SCRIPT_PATH}"
        rm $SCRIPT_PATH
    fi

    #OLD_HOME="${JAVA_HOME}"

    echo "Creating: ${SCRIPT_PATH}"
    echo "export MAVEN_HOME=${INSTALLED_DIR}" >> $SCRIPT_PATH
    echo "export PATH=\$PATH:\$MAVEN_HOME/bin" >> $SCRIPT_PATH
    echo "Making executable: ${SCRIPT_PATH}"
    chmod +x $SCRIPT_PATH
done

echo "Finished installing: ${DIR_FILE}"
echo "Restart to fully integrate PATH changes!"
