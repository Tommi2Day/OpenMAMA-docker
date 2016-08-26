# OpenMAMA

[![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama.svg)](https://hub.docker.com/r/tommi2day/openmama/)

## An OpenMAMA installation running on Docker

Description: [http://www.openmama.org/what-is-openmama/introduction-to-openmama]

Upstream Source: [https://github.com/OpenMAMA/OpenMAMA]

OpenMama Version: 2.4.1

Qpid-Proton Version: 0.13


### build
```sh
docker build -t tommi2day/openmama .
```
### exposed Ports
none

### Volumes
```sh
VOLUME /data # external data dir
```

### Run
start shell
```sh
docker run -it --rm \
--name openmama \
-v /c/Users/openmama/data:/data \ 
tommi2day/openmama
```

### Usage
OpenMAMA has been installed to /opt/openmama and is owned by user mama, which has /opt/openmama as HOME.

OpenMAMA sample data is in $HOME/data. There are additional scripts (test_*.sh) in $HOME/bin, which are the commands you found in the documentation 
to utilize the sample data.
Your external data volume is mounted to /data and linked to $HOME/extdata. 