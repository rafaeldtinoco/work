#!/bin/bash

[ ! -f .giturls ] && exit 1

while read name url
do
    [ -d $name ] && continue

    gbp clone $url $name

done < .giturls
