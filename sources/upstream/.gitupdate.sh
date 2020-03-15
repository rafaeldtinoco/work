#!/bin/bash

# vi:syntax=sh:expandtab:smarttab:tabstop=4:shiftwidth=4:softtabstop=4

prevdir=$(pwd)
dirname=$(dirname $0)

cd $dirname

dirs=$(find . -mindepth 2 -maxdepth 2 -regex .*\.git -exec dirname {} \;)

for dir in $dirs; do

    dir=${dir/\.\//}

    [ -f $dir/.mine ] && { echo "!! skipping $dir"; continue; }

    now=$(pwd)

    cd $dir

    echo "---- $(basename $(pwd) | tr [:lower:] [:upper:]) ----"

    origin=$(git remote -v | grep fetch | head -1 | awk '{print $1}')

    git fetch $origin -a --tags

    branch=$(git branch --no-color -al | grep HEAD | awk '{print $3}')

    git clean -fd ; git reset --hard ; git checkout $branch -b temporary
    git branch -D $(basename $branch)
    git checkout $branch -b $(basename $branch)
    git branch -D temporary

    cd $now

done

cd $prevdir
