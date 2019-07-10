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
    log git fetch pkg -a --tags

    log git checkout ubuntu/devel && {

        git reset --hard pkg/ubuntu/devel

    } || {

        git checkout pkg/ubuntu/devel -b ubuntu/devel

    }

    cd $now

done

cd $prevdir
