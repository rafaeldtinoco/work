#!/bin/bash

pkgname=$1
debianver=$2

if [[ $pkgname == "" ]]
then
    echo missing pkgname
    exit 1
fi

if [[ $debianver == "" ]]
then
    echo missing debian version
    exit 1
fi

mydir=$(pwd)

echo "getting source package for $pkgname ($debianver)"

mkdir /tmp/pulllp$$ ; cd /tmp/pulllp$$
pull-debian-source $pkgname $debianver
find . -mindepth 1 -maxdepth 1 -type f -exec mv {} $mydir \;
rm -rf /tmp/pulllp$$ ; cd $mydir
