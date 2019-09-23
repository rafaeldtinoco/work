#!/bin/bash

[ ! -f .giturls ] && exit 1

while read name url
do
    [ "$name" == "#" ] && continue

    [ -d $name ] && continue

    git ubuntu clone $name

done < .giturls
