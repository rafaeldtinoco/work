#!/bin/bash

dir=$1
version=$2

[ "$dir" == "" ] && exit 1
[ "$version" == "" ] && exit 1

[ ! -f .giturls ] && exit 1

while read name url
do
    [ ! -d $name ] && continue

    [ "$name" != "$dir" ] && continue

    mydir=$(pwd)

    echo "getting source package for $name ($version)"

    mkdir /tmp/pulllp$$ ; cd /tmp/pulllp$$
    pull-lp-source $name $version
    find . -mindepth 1 -maxdepth 1 -type f -exec mv {} $mydir \;
    rm -rf /tmp/pulllp$$ ; cd $mydir

done < .giturls
