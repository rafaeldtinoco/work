#!/bin/bash

rm -f *.asc
sudo chattr +i *orig* 2>/dev/null

[ -d .garbage ] || mkdir .garbage

find . -maxdepth 1 -type f ! -name ".*" -exec mv {} .garbage \; 2>/dev/null
find . -maxdepth 1 -type l ! -name ".*" -exec mv {} .garbage \; 2>/dev/null
