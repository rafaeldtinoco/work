#!/bin/bash

[ ! -f .giturls ] && exit 1

while read name url branch
do
    [ -d $name ] && continue

    now=$(pwd)

    if [ "$branch" != "master" ]; then

        mkdir $name ; cd $name

        git init
        git remote add -t $branch -f origin $url
        git checkout $branch

        cd $now

    else
        git clone $url $name
    fi

done < .giturls
