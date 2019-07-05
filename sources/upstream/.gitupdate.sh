#!/bin/bash

prevdir=$(pwd)
dirname=$(dirname $0)

cd $dirname

echo -n > .gitupdate.log

log() { $@ 2>&1 >> ../.gitupdate.log 2>&1; }

dirs=$(find . -maxdepth 2 -regex .*\.git -exec dirname {} \;)

for dir in $dirs; do

    dir=${dir/\.\//}

    [ -f $dir/.mine ] && { echo "!! skipping $dir"; break; }

    echo "-- updating $dir"

    now=$(pwd)

    cd $dir

    log echo "---- $(basename $(pwd) | tr [:lower:] [:upper:]) ----"

    log git reset --hard
    log git clean -fd
    log git fetch -a --tags

    branch=$(git branch --no-color | grep ^* | sed 's:^* ::g')

    log git reset --hard origin/$branch

    cd $now

done

cd $prevdir
