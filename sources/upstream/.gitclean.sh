#!/bin/bash

[ -d .garbage ] || mkdir .garbage

find . -maxdepth 1 -type f ! -name ".*" -exec mv {} .garbage \;
