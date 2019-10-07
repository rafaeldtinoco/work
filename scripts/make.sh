#!/bin/bash

export DEBFULLNAME="Rafael David Tinoco"
export DEBEMAIL="rafaeldtinoco@ubuntu.com"
export DEB_BUILD_OPTIONS="nostrip noopt nocheck debug parallel=6"
export MYKEY="F7F10EE108D16BBC92F78212A93E0E0AD83C0D0F"

# export CPPFLAGS="$(dpkg-buildflags --get CPPFLAGS)"
# export CFLAGS="$(dpkg-buildflags --get CFLAGS) $CPPFLAGS"
# export CXXFLAGS="$(dpkg-buildflags --get CXXFLAGS) $CPPFLAGS"
# export LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"

if [[ "$1" == "all" || "$1" == "build" ]]; then
    fakeroot debian/rules build
fi

if [ "$1" == "clean" ]; then
    fakeroot debian/rules clean
fi

exit $?
