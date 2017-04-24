# OpenMAMA



## An OpenMAMA installation running on Docker

Description: http://www.openmama.org/what-is-openmama/introduction-to-openmama

Upstream Source: https://github.com/OpenMAMA/OpenMAMA

Docker Sources: https://github.com/Tommi2Day/OpenMAMA-docker

Versions: OpenMAMA 6.2.0, Qpid-Proton 0.17, ZeroMQ 4.1.4

There are 5 different flavors of OpenMAMA images available:
- OpenMAMA base image (https://hub.docker.com/r/tommi2day/openmama/)    [![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama.svg)](https://hub.docker.com/r/tommi2day/openmama/)
- OpenMAMA publisher image (https://hub.docker.com/r/tommi2day/openmama-pub/) [![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama-pub.svg)](https://hub.docker.com/r/tommi2day/openmama-pub/)
- OpenMAMA subscriber image (https://hub.docker.com/r/tommi2day/openmama-sub/)  [![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama-sub.svg)](https://hub.docker.com/r/tommi2day/openmama-sub/)
- OpenMAMA ZeroMQ enabled image (https://hub.docker.com/r/tommi2day/openmama-zmq/)  [![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/openmama-zmq.svg)](https://hub.docker.com/r/tommi2day/openmama-zmq/)
- OpenMAMA Solace enabled image (Dockerfile and scripts only, for legal reasons you need to build it for yourself)

The sub/pub OpenMAMA images differs only on the openmama configuration and the usage of the seperate docker network

The zmq OpenMAMA image contains additional to the base image  Frank Quinner's [OpenMama ZeroMQ Middleware Bridge](https://github.com/fquinner/OpenMAMA-zmq)

The solace enabled OpenMAMA container utilizes the free "Community Edition" of the Solace [Virtual Message Router](http://dev.solace.com/tech/virtual-message-router/) as 
[OpenMAMA bridge](http://docs.solace.com/Solace-OpenMama/Solace-OpenMAMA-Componen.htm) (without SolCache). 
There are also scripts for basic configuring of the VMR provided.

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

to build the solace enabled container you have to download 
the propretary software from 
[Solace Developer Portal](http://dev.solace.com/downloads/)

- C API Linux 2.6 x64
- API-> Openmama (Bridge) for Linux 2.6 x64
- SDKperf C Linux 2.6 x64

copy the tarballs into solace/downloads/. afterwards you should see there files similar
```
ls -1 solace/downloads
pubSubTools_CCSMP_Linux26-x86_64_opt_7.2.5.6.tar.gz
solclient_Linux26-x86_64_opt_7.2.5.7.tar.gz
solopenmama_bridge_Linux26-x86_64_opt_7.2.2.32.tar.gz
```

    
- optionally (not needed for the build) you may consider to download 
the SolAdmin Gui from the same page.

Then build the OpenMAMA base container first.
Afterwards you may build the new container using
```
docker build -t tommi2day/openmama-solace -f Dockerfile.openmama-solace .
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
 
If you will not use a private configuration you dont need to mount /opt/openmama/config. 
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
#### Solace
Solace provides an enterprise ready high speed low latency messaging platform as hardware solution 
and with the same API as virtual appliance. See details [online](http://dev.solace.com/tech/).
 Solace provides an OpenMAMA bridge which replaces the standard Qpid message bridge.

The virtual appliance "Solace Virtual Message Router"(VMR) is available [here](http://dev.solace.com/downloads/).
Its a VM which runs the VMR as Docker container inside. Make sure the VM can be reached per hostname
and does not change the IP (usually via DHCP reservation). 

For the VMR Appliance Installation follow the provided quickstart guide 
for your Hypervisor (VMWare vSphere,ESXi or Workstation, Oracle VirtualBox, KVM) 

After PowerOn of the new VM you can reach both, the VM via ssh on port 2222 as user "sysadmin" 
and the docker container on port 22 as user "support" on the VMR IP 

Solace provides a lot of samples to there technology on 
[Github](https://github.com/solacesamples). 
There is also an OpenMAMA related
[Tutorial](https://github.com/SolaceSamples/solace-samples-openmama). 

start solace enabled OpenMAMA container with providing the VMR hostname 
and an optional suffix (e.g. sub or pub)
```sh
./run_openmama-solace.sh solace pub
```
the given hostname will be resolved and added to the container /etc/hosts as 
solace-vmr. All other solace scripts rely on that name.

mama.properties is preconfigured for publisher and subscriber

for your convience I am providing some scripts for initial setup for using with OpenMAMA.
You may configure a VMR with these supplied cli scripts from within the running container. 
```
/opt/solclient/vmr_setup/vmr_mama_conf.sh
```

 - vmr_mama_conf.sh 
 
    all at one setup script. It creates a SSH key for accessing VMR, 
    ask for password for sysadmin at first access and configure pubkey ssh login. 
    Then it executes the CLI scripts users.cli and mama.cli remotely on the VMR 
    to create a VPN and users for configuration used in this Image
    
 - run_cli.sh
 
    copy a CLI script to VMR and execute it via run_cli.expect
 - run_cli.expect
 
    used by run_cli.sh, executes a CLI script on VMR
 - users.cli
 
    set admin password to "admin"
 - mama.cli
 
    create message vpn "mama-vpn" with service SMF, basic auth and user "mama" with password "mama"
 - dump_mama-vpn.sh
    
    uses sdkperf_c to dump all traffic an message vpn mama-vpn

Alternativ you may copy the related scripts to another unix box. Pls review and adopt the scripts regarding hostnames, IPs passwords etc.
ssh keys and passwords or use SolAdmin.

**Remember:** Solace software is subject to there propretary license

#### Notes: 
- you can only run one publisher and one subscriber at a given time with the provided starter scripts. 
If you need more you have to adopt the container name and mama.properties 

- All OpenMAMA images are based on RPM build using slightly extended upstream openmama.spec, which is also provided here.
If prefere to build your own RPMs, you need online access to Github and the following packages from CentOS7 and EPEL repositories
 ```
 yum install -y git-core gcc gcc-c++ make binutils \
    rpmlint rpm-build redhat-rpm-config rpmdevtools \
    flex scons doxygen java-devel libtool autoconf automake ant \
    libuuid-devel qpid-proton-c-devel libevent-devel ncurses-devel \
    libxml2-devel zeromq-devel
 ```

- As of writing VMR 7.2.010 startup hangs shortly after loading image. You may wait 
for completion(about 20min). In this time the VM tries to write to a serial console device 
which may not be provided by the Hypervisor as seen at ProfitBricks Cloud. 
  After you reached the login prompt login as sysadmin, give  do "sudo -i" for root access 
  and change /etc/default/grub 
  
    from
    ```
    GRUB_CMDLINE_LINUX="crashkernel=7G-:128M biosdevname=0 net.ifnames=0 disable_cpuid_reorder=1 libata.fua=1 console=tty0 console=ttyS0,115200n8 no_timer_check"
    ```
    to
    ```
    GRUB_CMDLINE_LINUX="crashkernel=7G-:128M biosdevname=0 net.ifnames=0 disable_cpuid_reorder=1 libata.fua=1 console=tty0 no_timer_check"
    ```
    then rewrite grub.cfg
    ```
    grub2-mkconfig -o /boot/grub2/grub.cfg
    ```
    I dont know why a "virtual" router should require serial console output.
 
