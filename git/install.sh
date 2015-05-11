#!/bin/bash

set -e errexit
set -x

sudo apt-get install autoconf
sudo apt-get install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
sudo apt-get install asciidoc xmlto docbook2x

version=2.4.0
archivename=v${version}.tar.gz
archivelink=https://github.com/git/git/archive/${archivename}
archivedir=git-${version}
wget -O "${archivename}" "${archivelink}"
tar -zxf "${archivename}"

pushd "${archivedir}"
make configure
./configure --prefix=${HOME}/Apps
make all doc info
make install install-doc install-html install-info
popd

rm "${archivename}"
rm -rf "/${archivedir}"
