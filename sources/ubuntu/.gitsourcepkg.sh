#!/bin/bash

pkgname=$1
ubuntuver=$2

if [[ $pkgname == "" ]]
then
    echo missing pkgname
    exit 1
fi

if [[ $ubuntuver == "" ]]
then
    echo missing ubuntu version
    exit 1
fi

mydir=$(pwd)

echo "getting source package for $pkgname ($ubuntuver)"

mkdir /tmp/pulllp$$ ; cd /tmp/pulllp$$
pull-lp-source $pkgname $ubuntuver
find . -mindepth 1 -maxdepth 1 -type f -exec mv {} $mydir \;
rm -rf /tmp/pulllp$$ ; cd $mydir

