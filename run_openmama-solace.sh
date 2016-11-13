#!/bin/bash
VMNAME=openmama-solace
if [ $# -lt 1 ]; then
	echo "Usage: $0 <ip or host of VMR>"
	exit 1
fi
IP=$1
IP=$(perl -MSocket -le 'print inet_ntoa inet_aton shift' $IP)
if [ -z "$IP" ]; then
	echo "cannot resolve '$1' as solace vmr ip"
	exit 1
fi

VMR="solace-vmr:$IP"
shift

INST="${1:+-$1}"
if [ -n "$INST" ]; then 
	shift
fi

if [ -z "$DOCKER_SHARED" ]; then
	DOCKER_SHARED=$(pwd)
fi
SHARED="${DOCKER_SHARED}/$VMNAME-shared"
if [ ! -d "${SHARED}" ]; then
	mkdir -p "${SHARED}/data" "${SHARED}/$VMNAME"
fi

docker run -it --rm \
	-v "${SHARED}/data":/data \
	--hostname ${VMNAME}${INST} \
	--name ${VMNAME}${INST} \
    --add-host $VMR \
	-v "${SHARED}/$VMNAME":/opt/openmama/config \
	 tommi2day/$VMNAME $@
#-p 6666:6666 \
