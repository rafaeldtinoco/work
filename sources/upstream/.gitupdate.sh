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

    remotehead=$(git branch -r | grep HEAD | awk '{print $1}')
    remotebranch=$(git branch -r | grep HEAD | awk '{print $3}')
    localbranch=$(basename $(git branch -r | grep HEAD | awk '{print $3}'))

    log git reset --hard
    log git clean -fd

    log git fetch -a --tags

    log git checkout $localbranch && {

        log git reset --hard $remotebranch

    } || {

        log git checkout $remotebranch -b $localbranch
    }


    cd $now

done

cd $prevdir
