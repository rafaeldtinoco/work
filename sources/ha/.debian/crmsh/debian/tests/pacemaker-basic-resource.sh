#!/bin/sh

set -ex

DAEMON_TIMEOUT=60
CRM_TIMEOUT=5
RSC_NAME="test"
rsc_check()
{
	if crm status | grep "$RSC_NAME[[:space:]][(]ocf::heartbeat:IPv6addr[)]:[[:space:]].*$1" >/dev/null; then
		return 0
	else
		return 1
	fi
}

# https://bugs.launchpad.net/bugs/1828228
ulimit -H -l unlimited 2>/dev/null || {
	echo "test disabled for unprivileged namespaces"
	exit 77
}

#
# daemons start
#

service corosync start
service pacemaker start
sleep $DAEMON_TIMEOUT

#
# disable stonith and quorum
#

crm configure property stonith-enabled="false"
crm configure property no-quorum-policy="ignore"
sleep $CRM_TIMEOUT

#
# creation & start
#

crm configure primitive $RSC_NAME \
	ocf:heartbeat:IPv6addr \
		params ipv6addr="fe00::200" \
		cidr_netmask="64" \
		nic="lo"
sleep $CRM_TIMEOUT
crm resource start $RSC_NAME
sleep $CRM_TIMEOUT
if rsc_check "Started" ; then
	: INFO resource creation and start OK
else
	: ERROR failed to start resource
	exit 1
fi

#
# stop
#

crm resource stop $RSC_NAME
sleep $CRM_TIMEOUT
if rsc_check "Stopped" ; then
	: INFO resource stop OK
else
	: ERROR failed to stop resource
	exit 1
fi

#
# delete
#

crm configure delete $RSC_NAME
sleep $CRM_TIMEOUT
if ! rsc_check "Stopped" ; then
	: INFO resource delete OK
else
	: ERROR failed to delete resource
	exit 1
fi

: INFO all tests OK
exit 0
