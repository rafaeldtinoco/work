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

    # clean and fetch origin

    git clean -fd ; git reset --hard
    origin=$(git remote -v | grep fetch | head -1 | awk '{print $1}')
    git fetch $origin -a --tags

    # create a temporary branch with remote head

    headptr=$(git branch --no-color -al | sed 's:\*::g' | grep HEAD | awk '{print $3}')
    git checkout temporary 2>&1 > /dev/null 2>&1 || git checkout $headptr -b temporary

    # delete all branches

    branches=$(git branch --no-color -l | sed 's:\*::g' | \
        grep -v "temporary" | awk '{print $1}' | xargs)

    for branch in $branches; do
        git branch -D $branch
    done

    # delete all remotes but origin

    remotes=$(git remote -v | grep fetch | grep -v origin | awk '{print $1}' | xargs)

    for remote in $remotes; do
        git remote remove $remote
    done

    # checkout remote head as default

    git checkout $headptr -b $(basename $headptr)
    git branch -D temporary

    cd $now

done

cd $prevdir
