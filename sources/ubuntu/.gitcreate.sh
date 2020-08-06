#!/bin/bash

[ ! -f .giturls ] && exit 1

while read name
do
    [[ "$name" == \#* ]] && continue
    [[ -d $name ]] && continue
    [[ "$1" != "" && "$name" != "$1" ]] && continue

    git ubuntu clone $name

done < .giturls
