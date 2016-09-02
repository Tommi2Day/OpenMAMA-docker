# OpenMAMA



## An OpenMAMA installation running on Docker

Description: http://www.openmama.org/what-is-openmama/introduction-to-openmama

Upstream Source: https://github.com/OpenMAMA/OpenMAMA

Docker Sources: https://github.com/Tommi2Day/OpenMAMA-docker

Versions: OpenMAMA 2.4.1, Qpid-Proton 0.13, (ZeroMQ 4.1)

There are 4 images provided:
- OpenMAMA base image (https://hub.docker.com/r/tommi2day/openmama/)    [![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama.svg)](https://hub.docker.com/r/tommi2day/openmama/)
- OpenMAMA publisher image (https://hub.docker.com/r/tommi2day/openmama-pub/) [![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama-pub.svg)](https://hub.docker.com/r/tommi2day/openmama-pub/)
- OpenMAMA subscriber image (https://hub.docker.com/r/tommi2day/openmama-sub/)  [![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama-sub.svg)](https://hub.docker.com/r/tommi2day/openmama-sub/)
- OpenMAMA ZeroMQ enabled image (https://hub.docker.com/r/tommi2day/openmama-zmq/)  [![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama-zmq.svg)](https://hub.docker.com/r/tommi2day/openmama-zmq/)

The sub/pub images differs only on the openmama configuration and the usage of the seperate docker network

The zmq image contains additional to the base image the OpenMama ZeroMQ Middleware Bridge from Frank Quinner (https://github.com/fquinner/OpenMAMA-zmq)

all OpenMAMA are based of private build RPM using slightly extended upstream openmama.spec 

### build
```sh
#!/bin/bash
git clone https://github.com/Tommi2Day/OpenMAMA-docker openmama
cd openmama
docker build -t tommi2day/openmama .
docker build -t tommi2day/openmama-pub -f Dockerfile.openmama-pub .
docker build -t tommi2day/openmama-sub -f Dockerfile.openmama-sub .
docker build -t tommi2day/openmama-zmq -f Dockerfile.openmama-zmq .
docker network create openmama-net
```
### exposed Ports
```sh
EXPOSE 7777 #publisher port on openmama-pub 
EXPOSE 6666 #subscriber port on openmama-sub
```

### Volumes
```sh
/data                   # external data dir
/opt/openmama/config    # OpenMAMA configuration directory 
```

### Usage
OpenMAMA has been installed to /opt/openmama and is owned by user mama, which has /opt/openmama as HOME.

There are additional scripts (test_*.sh) in $HOME/bin, which are including the same commands you found in the documentation 
to utilize the sample data.

Volume mount points must exist before starting a container and accessible by docker.
Your external data volume is mounted to /data and linked to $HOME/extdata. 
 
If you dont need use a private configuration you dont need to mount /opt/openmama/config. 
A mounted configuration directory may be empty but then should be writable. 
If bash cannot find a mama.properties in /opt/openmama/properties a default mama.properties along profile.openmama will be copied there. 

To run the publisher and subscriber image from the provided starter scripts make sure you have already created 
the private openmama docker network
```sh
docker network create openmama-net
```
### Run
start basic image shell with default localhost config. 

```sh
docker run -it --rm \
--name openmama \
-v ./openmama/data:/data \  
tommi2day/openmama
```

start publisher to replay test data using on Github provided publisher docker starter script
```sh
./run_openmama-pub.sh /opt/openmama/bin/test_replay.sh
```
start subscriber to listen test data using on Github provided subscriber docker starter script
```sh
 ./run_openmama-sub.sh /opt/openmama/bin/test_listen.sh
```

start bookticker to subscribe test data using on Github provided subscriber docker starter script
```sh
 ./run_openmama-sub.sh /opt/openmama/bin/test_ticker.sh
```

start basic image shell with ZeroMQ enabled localhost config. 
```sh
docker run -it --rm \
--name openmama-zmq \
-v ./openmama/data:/data \  
tommi2day/openmama-zmq
```
#####Note: 
you can only run one publisher and one subscriber at a given time with the provided starter scripts. 
If you need more you have to adopt the container name and mama.properties 