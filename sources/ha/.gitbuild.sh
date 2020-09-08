#!/bin/bash -ex

#PPA="ppa:ubuntu-ha/staging *_source.changes"
PPA="ppa:ubuntu-ha/200831-staging *_source.changes"

success=0

NUMCPU=`cat /proc/cpuinfo | grep proce | wc -l`
export DEBFULLNAME="Rafael David Tinoco"
export DEBEMAIL="rafaeldtinoco@ubuntu.com"
export MYKEY="F7F10EE108D16BBC92F78212A93E0E0AD83C0D0F"

export MY_DEB_BUILD_OPTIONS="check nostrip noudeb nodebug"
export MY_DEB_BUILD_PROFILES="check nostrip noudeb nodebug"

export DEB_BUILD_OPTIONS="$MY_DEB_BUILD_OPTIONS parallel=$NUMCPU"
export DEB_BUILD_PROFILES="$MY_DEB_BUILD_PROFILES"

origdir=$(pwd)

cleantree() {

    [ -f debian/patches/debian-changes ] && {
        rm debian/patches/debian-changes
        cat debian/patches/series | grep -v debian-changes > /tmp/$$series
        mv /tmp/$$series debian/patches/series
    } || true

    [ -f debian/changelog ] && {
        dh_autoreconf_clean || true
        dh_autoreconf || true
        dh clean
    } || true

    git clean -fd
    git reset --hard
}

cleanup() {

    [ $package == "" ] && return;
    cd $origdir; cd $package

    [ -d ./debian ] && {
        rm -rf ./debian;
        ln -s ../.debian/$package/debian ./debian;
    }

    [ -f debian/changelog.bkp ] && {
        mv debian/changelog.bkp debian/changelog.$mysuite
    } || true

    [ -f debian/changelog ] && rm debian/changelog
    [ -f .mine ] && rm .mine

    [ $already -eq 1 ] && return;

    cleantree

    cd $origdir
}

checkbuilt() {
    cat debian/changelog.$mysuite | grep -q $githash && {
        echo "$package ($githash) already built"
        already=1
    } || already=0;
}

changelog() {

    [ $already -eq 1 ] && return;
    cd $origdir; cd $package
    [ ! -f .mine ] && { echo "something is wrong"; exit 1; }

    cp debian/changelog.$mysuite debian/changelog
    cp debian/changelog debian/changelog.bkp
    {
        echo "$package ($newversion) $mysuite; urgency=medium"
        echo ""
        echo "  * $gitdesc"
        echo ""
        echo " -- Rafael David Tinoco <rafaeldtinoco@ubuntu.com>  $(date -Ru)"
        echo ""
    } > debian/changelog

    cat debian/changelog.bkp >> debian/changelog
    cp debian/changelog debian/changelog.$mysuite
}

initial() {

    cd $origdir; cd $package

    mysuite=$(lsb_release -c -s)
    myver=$(rmadison -u ubuntu -a source -s $mysuite,$mysuite-updates,$mysuite-proposed -S $package | tail -1 | cut -d'|' -f2 | sed 's: ::g')
    githash=$(git log --format=oneline -1 --abbrev | awk '{print $1}')
    gitdesc=$(git log --pretty='format:%C(auto)%h (%s, %ad)' -1)
    newversion=$myver+$(date -u +%y%m%d%H%M%S)

    checkbuilt

    [ $already -eq 1 ] && { cd $origdir; return; }

    cleantree
    touch .mine
    cd $origdir
}

binarypkgs() {

    [ $already -eq 1 ] && return;
    cd $origdir; cd $package
    [ ! -f .mine ] && { echo "something is wrong"; exit 1; }

    cleantree

    dpkg-buildpackage -b -k$MYKEY

    cd $origdir
}

sourcepkg() {

    [ $already -eq 1 ] && return;
    cd $origdir; cd $package
    [ ! -f .mine ] && { echo "something is wrong"; exit 1; }

    cleantree

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

    # dependencies for corosync & kronosnet
    sudo dpkg -i *libqb*.deb || true
    # dependencies for corosync
    sudo dpkg -i *libnozzle*.deb || true
    sudo dpkg -i *libknet*.deb || true
    # dependencies for cluster-glue
    sudo dpkg -i \
        *libcfg*deb \
        *libcmap*.deb \
        *libcorosync*.deb \
        *libcpg*deb \
        *libquorum*deb || true
    # dependencies for pacemaker
    sudo dpkg -i cluster-glue*.deb \
        *liblrm2*.deb \
        *libpils2*.deb \
        *libplumb2*.deb \
        *libplumbgpl2*.deb \
        *libstonith1*.deb || true
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

    dput $PPA *_source.changes
}

cleanall() {
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
    uploadsrc
    cleanall
done

success=1
exit 0


