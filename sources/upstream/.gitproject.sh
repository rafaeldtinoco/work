#!/bin/bash

[ ! -f .giturls ] && exit 1

while read name url
do
    [ ! -d $name ] && continue

    mydir=$(basename $(pwd))


    if [ "$1" != "force" ]; then

        if [ ! -f $name/.project ] || [ ! -f $name/.cproject ]; then
            echo creating .{c}project files into $name...
            cp .project .cproject $name/
        fi
    else

        echo creating .{c}project files into $name...
        cp .project .cproject $name/

    fi

    sed -i "s:CHANGETHIS:$name-$mydir:g" $name/.project
    sed -i "s:CHANGETHIS:$name-$mydir:g" $name/.cproject

done < .giturls
