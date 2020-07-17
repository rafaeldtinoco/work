#!/bin/bash

[ ! -f .giturls ] && exit 1

while read name url
do
    [[ "$name" == "#" ]] && continue
    [[ -d $name ]] && continue
    [[ "$1" != "" && "$name" != "$1" ]] && continue

    gbp clone $url $name

done < .giturls
