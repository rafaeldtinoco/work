#!/bin/bash

[ ! -f .giturls ] && exit 1

for dir in $(cat .giturls | grep "^#" | sed 's:.*# \+::g')
do
    ls -d ./$dir 2>/dev/null 1>/dev/null && {
        rm -rf ./$dir
        echo "$dir commented in giturls, deleted"
    }
done

dirs=$(cat .giturls | sed 's:^# \+::g' | xargs)

for dir in *
do
    [ -d $dir ] && {
        echo $dirs | grep -q $dir || {
            [ -d ./$dir ] && rm -rf ./$dir
            echo "$dir missing in giturls, deleted"
        }
    }
done
