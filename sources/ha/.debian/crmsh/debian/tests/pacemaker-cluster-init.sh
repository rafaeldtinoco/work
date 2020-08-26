#!/bin/sh

set -ex

# https://bugs.launchpad.net/bugs/1828228
ulimit -H -l unlimited 2>/dev/null || {
	echo "test disabled for unprivileged namespaces"
	exit 77
}

# ufw currently broken without /sbin/iptables
if ! ufw status; then
	test -e /sbin/iptables  || ln -s /usr/sbin/iptables /sbin/iptables
	test -e /sbin/ip6tables || ln -s /usr/sbin/ip6tables /sbin/ip6tables
fi

service corosync stop

crm cluster init --yes --name=autopkgtest --unicast

crm cluster geo-init --yes --clusters=autopkgtest=127.2.2.2 --tickets=ticket1
crm resource start g-booth
sleep 5

crm status

crm status | grep -q booth-ip.*Started
crm status | grep -q booth-site.*Started

: INFO all tests OK
exit 0
