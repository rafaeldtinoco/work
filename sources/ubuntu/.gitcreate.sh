#!/bin/bash

[ ! -f .giturls ] && exit 1

while read name url
do
    [ -d $name ] && continue

    git ubuntu clone $url $name

done < .giturls
