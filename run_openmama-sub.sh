#!/bin/bash
VMNAME=openmama-sub
NET=openmama-net

if [ -z "$DOCKER_SHARED" ]; then
	DOCKER_SHARED=$(pwd)
fi
SHARED="${DOCKER_SHARED}/$VMNAME-shared"
if [ ! -d "${SHARED}" ]; then
	mkdir -p "${SHARED}/data" "${SHARED}/$VMNAME"
fi

docker run -it --rm \
	-v "${SHARED}/data":/data \
	-v "${SHARED}/$VMNAME":/opt/openmama/config \
	--hostname $VMNAME \
	--net $NET \
	--name $VMNAME \
	 tommi2day/$VMNAME $@
#-p 6666:6666 \
