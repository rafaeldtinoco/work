#!/bin/bash

MAINDIR="$HOME/work"
SOURCES="$MAINDIR/sources"
TREES="$SOURCES/trees"

gitclean() {
    git reset --hard ; git clean -fd
    git checkout master ; git reset --hard origin/master ;
    git reset --hard ; git clean -fd
}

#versions=$(git tag | grep ^glibc-2 | grep -v ports | xargs)
versions=$(git log --tags --simplify-by-decoration --pretty="format:%ai %d" | grep "(tag: glibc-" | grep -v ports | egrep -E "^20(12|13|14|15|16|17)" | awk '{print $5}' | sed 's:)$::g')

for version in $versions; do

cd $TREES/glibc

gitclean
git checkout $version

../8_builddeb.sh glibc

gitclean

done
