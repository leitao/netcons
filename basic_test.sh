#!/bin/bash

# Simple script to test dynamic targets in netconsole

IFACE=eth0
MAX=${1:-1}
MAC=$(ip link show ${IFACE} | awk '/ether/ {print $2}')
SRC=192.168.1.1
LOCAL=192.168.1.2

set -e

function create_and_test() {
	NAME=$(mktemp -u  tmp.XXXXX)
	FULLPATH=/sys/kernel/config/netconsole/${NAME}

	echo ${FULLPATH}

	mkdir ${FULLPATH}

	echo 0 > ${FULLPATH}/enabled || true
	echo ${REMOTE} > ${FULLPATH}/remote_ip
	echo ${LOCAL} > ${FULLPATH}/local_ip

	echo ${MAC} > ${FULLPATH}/remote_mac
	echo 1 > ${FULLPATH}/enabled

	echo "from ${NAME}" > /dev/kmsg
	ip link set dev ${IFACE} name new${IFACE}

	echo FOOBAR-new${IFACE} > /dev/kmsg
	ip link set dev new${IFACE} name ${IFACE}


	echo 0 > ${FULLPATH}/enabled
	echo ${SRC} > ${FULLPATH}/remote_ip
	echo 1 > ${FULLPATH}/enabled
	# try to disable with it enabled
	echo ${REMOTE} > ${FULLPATH}/remote_ip || true
	echo 0 > ${FULLPATH}/enabled

	rmdir ${FULLPATH}
}

echo ${MAX}
for i in $(seq ${MAX})
do
	create_and_test &
done

echo "Bye"
