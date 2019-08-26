#!/bin/bash

for name in $(find . -maxdepth 1 -type d)
do

    [ "$name" == "." ] || [ "$name" == ".." ] || [ "$name" == "./old" ] || [ "$name" == "./.garbage" ] && continue
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

    oldname=$name
    name=$(echo ${name:2} | cut -d'-' -f1)

    sed -i "s:CHANGETHIS:$name-$mydir:g" $oldname/.project
    sed -i "s:CHANGETHIS:$name-$mydir:g" $oldname/.cproject
done
