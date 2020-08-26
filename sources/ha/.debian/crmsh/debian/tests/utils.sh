#!/bin/sh

set -ex

export LC_ALL=C
PKG=vim

dpkg --purge $PKG

# package not installed
/usr/share/crmsh/utils/crm_rpmcheck.py $PKG | grep error

# install
/usr/share/crmsh/utils/crm_pkg.py -n $PKG -s present | grep Unpacking
/usr/share/crmsh/utils/crm_rpmcheck.py $PKG | grep status
dpkg --status $PKG

# upgrade
/usr/share/crmsh/utils/crm_pkg.py -n $PKG -s latest | grep False

# purge
/usr/share/crmsh/utils/crm_pkg.py -n $PKG -s removed | egrep 'Removing|Purging'
/usr/share/crmsh/utils/crm_rpmcheck.py $PKG | grep error

# clean
cd $AUTOPKGTEST_TMP
mkdir dir
touch dir/file
cp /usr/share/crmsh/utils/crm_clean.py .
$PWD/crm_clean.py $PWD/crm_clean.py $PWD/dir
if ls | grep .; then
    exit 1
fi
