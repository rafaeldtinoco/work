#!/bin/bash -ex

success=0

NUMCPU=`cat /proc/cpuinfo | grep proce | wc -l`
export DEBFULLNAME="Rafael David Tinoco"
export DEBEMAIL="rafaeldtinoco@ubuntu.com"
export MYKEY="F7F10EE108D16BBC92F78212A93E0E0AD83C0D0F"

export MY_DEB_BUILD_OPTIONS="nocheck nostrip noudeb nodebug"
export MY_DEB_BUILD_PROFILES="nocheck nostrip noudeb nodebug"

export DEB_BUILD_OPTIONS="$MY_DEB_BUILD_OPTIONS parallel=$NUMCPU"
export DEB_BUILD_PROFILES="$MY_DEB_BUILD_PROFILES"

origdir=$(pwd)

cleantree() {
    # clean source tree

    quilt pop -af || true

    [ -f debian/patches/debian-changes ] && {
        rm debian/patches/debian-changes
        cat debian/patches/series | grep -v debian-changes > /tmp/$$series
        mv /tmp/$$series debian/patches/series
    } || true

    dh clean
    git clean -fd
    git reset --hard
}

cleanup() {
    # make sure there are not leftovers

    [ $success -eq 0 ] && return;
    [ $package == "" ] && return;

    cd $origdir; cd $package

    [ -d ./debian ] && { rm -rf ./debian; ln -s ../.debian/$package/debian ./debian; }
    [ -f debian/changelog.bkp ] && mv debian/changelog.bkp debian/changelog
    [ -f .mine ] && rm .mine

    cleantree

    cd $origdir
}

checkfirst() {
    # check if this is the first build (to generate orig tar.gz)
    [ ! -f .first ] && { extra=""; first=0; } || { extra="-sa"; first=1; }
    [ -f .first ] && rm .first || true
}

checkbuilt() {
    # check if git HEAD was already built

    cat debian/changelog | grep -q $githash && {
        echo "$package ($githash) already built"
        already=1
    } || already=0;
}

changelog() {
    # change the debian/changelog file based on git HEAD and date

    [ $already -eq 1 ] && return;
    cd $origdir; cd $package
    [ ! -f .mine ] && { echo "something is wrong"; exit 1; }

    cp debian/changelog debian/changelog.bkp
    {
        echo "$package ($newversion) $develsuite; urgency=medium"
        echo ""
        echo "  * $gitdesc"
        echo ""
        echo " -- Rafael David Tinoco <rafaeldtinoco@ubuntu.com>  $(date -Ru)"
        echo ""
    } > debian/changelog

    cat debian/changelog.bkp >> debian/changelog
}

initial() {
    # prepare needed info and env

    cd $origdir; cd $package
    touch .mine

    cleantree

    develsuite=$(ubuntu-distro-info --devel)
    develver=$(rmadison -u ubuntu -a source -s $develsuite -S $package | cut -d'|' -f2 | sed 's: ::g')
    githash=$(git log --format=oneline -1 --abbrev | awk '{print $1}')
    gitdesc=$(git log --format=reference -1)
    newversion=$develver+$(date -u +%y%m%d%H%M%S)

    checkfirst
    checkbuilt

    cd $origdir
}

binarypkgs() {
    # build binary packages

    [ $already -eq 1 ] && return;
    cd $origdir; cd $package
    [ ! -f .mine ] && { echo "something is wrong"; exit 1; }

    cleantree

    dpkg-buildpackage -b -k$MYKEY

    cd $origdir
}

sourcepkg() {
    # build the source package

    [ $already -eq 1 ] && return;
    cd $origdir; cd $package
    [ ! -f .mine ] && { echo "something is wrong"; exit 1; }

    cleantree

    cd $origdir

    if [ $first -eq 1 ]
    then
        tar cfz ${package}_${develver/-*/}.orig.tar.gz \
            --exclude=$package/debian*/* \
            --exclude=$package/.git*/* \
            --exclude=$package/.pc*/* \
            --exclude=$package/.mine \
            ${package}
        sudo chattr +i ${package}_${develver/-*/}.orig.tar.gz
    fi

    cd $package

    [ -e debian ] && rm debian
    [ -d ../.debian/$package/debian ] || { echo "can't find debian"; exit 1; }
    cp -rfp ../.debian/$package/debian .

    dpkg-buildpackage -S $extra -k$MYKEY

    [ ! -d debian ] && { echo "can't find debian"; exit 1; }
    rm -rf ./debian/
    ln -s ../.debian/$package/debian .

    cd $origdir
}

installpkgs() {

    [ $already -eq 1 ] && return;
    cd $origdir; cd $package
    [ ! -f .mine ] && { echo "something is wrong"; exit 1; }

    cd $origdir

    sudo dpkg -i *.deb
}

theend() {

    [ $already -eq 1 ] && return;
    cd $origdir; cd $package
    [ ! -f .mine ] && { echo "something is wrong"; exit 1; }

    [ ! -f debian/changelog.bkp ] && { echo "where is changelog bkp"; exit 1; }

    # this makes changelog to keep history (so no duplicate upload is done)
    rm debian/changelog.bkp

    rm .mine
    cd $origdir
}

uploadsrc() {
    [ $already -eq 1 ] && return;

    dput ppa:ubuntu-ha/staging *_source.changes

    ./.gitclean.sh
}

trap cleanup EXIT

# main loop

pkglist="libqb kronosnet corosync cluster-glue resource-agents"
[ "$1" != "" ] && pkglist=$1 || true

for package in $pkglist
do
    initial
    changelog
    sourcepkg
    binarypkgs
    installpkgs
    theend
    [ $first -ne 1 ] && uploadsrc || true
done

success=1
exit 0

