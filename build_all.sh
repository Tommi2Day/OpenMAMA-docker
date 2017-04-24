#!/bin/bash

docker build -t tommi2day/openmama .
docker build -t tommi2day/openmama-pub -f Dockerfile.openmama-pub .
docker build -t tommi2day/openmama-sub -f Dockerfile.openmama-sub .
docker build -t tommi2day/openmama-zmq -f Dockerfile.openmama-zmq .
docker build -t tommi2day/openmama-solace -f Dockerfile.openmama-solace .

if ! docker network inspect openmama-net >/dev/null 2>&1; then
 docker network create openmama-net
fi

#clean
rm -Rf $DOCKER_SHARED/openmama-*shared/*
