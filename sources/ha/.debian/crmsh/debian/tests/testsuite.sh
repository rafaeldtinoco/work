#!/bin/sh

set -e

# prepare test env
export PATH=$PATH:/usr/lib/pacemaker
export PYTHONPATH=/usr/share/crmsh
cd /usr/share/crmsh/tests
mkdir /usr/share/crmsh/doc

# run the tests
printf "Running unittests...\n"
nosetests3 -w ./unittests -v 2>&1

printf "\nRunning cibtests...\n"
./cib-tests.sh

printf "\nRunning regressions...\n"
./regression.sh -m buildbot || true
cat crmtestout/regression.out
