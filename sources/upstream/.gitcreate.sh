#!/bin/bash

[ ! -f .giturls ] && exit 1

while read name url
do
    [ -d $name ] && continue

    [ "$name" == "#" ] && continue

    echo $url | grep -q svn

    if [ $? == 0 ]; then
        git svn clone $url $name
    else
        git clone $url $name
    fi
done < .giturls
