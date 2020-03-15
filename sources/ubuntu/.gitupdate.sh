#!/bin/bash

# vi:syntax=sh:expandtab:smarttab:tabstop=4:shiftwidth=4:softtabstop=4

prevdir=$(pwd)
dirname=$(dirname $0)

cd $dirname

dirs=$(find . -maxdepth 2 -regex .*\.git -exec dirname {} \;)

for dir in $dirs; do

    dir=${dir/\.\//}

    [ -f $dir/.mine ] && { echo "!! skipping $dir"; continue; }

    now=$(pwd)

    cd $dir

    echo "---- $(basename $(pwd) | tr [:lower:] [:upper:]) ----"

    # clean and fetch remote "pkg"

    git clean -fd ; git reset --hard
    git fetch pkg -a --tags

    # create a temp branch with with remote head

    git checkout temporary 2>&1 > /dev/null 2>&1 || git checkout pkg/ubuntu/devel -b temporary

    # delete all branches

    branches=$(git branch --no-color -l | sed 's:\*::g' | \
        grep -v "ubuntu/devel$" | grep -v "temporary" | \
        awk '{print $1}' | xargs)

    for branch in $branches; do
        git branch -D $branch
    done

    # delete all remotes but pkg

    remotes=$(git remote -v | grep fetch | grep -v "^pkg" | awk '{print $1}' | xargs)

    for remote in $remotes; do
        git remote remove $remote
    done

    # checkout pkg/ubuntu/devel by default

    git branch -D ubuntu/devel
    git checkout pkg/ubuntu/devel -b ubuntu/devel
    git branch -D temporary

    cd $now

done

cd $prevdir




