FROM centos:centos7

MAINTAINER Tommi2Day

RUN yum update -y && yum install -y epel-release vim wget tar mc sudo git-core java-1.8.0-openjdk-devel libevent libuuid

ENV MAMA_VERSION 2.4.1
ENV JAVA_HOME /etc/alternatives/java_jdk


# Disables the firewall
RUN systemctl disable firewalld

#disable selinux
RUN if [ -w /etc/sysconfig/selinux ]; then perl -pi -e "s/^SELINUX=.*/SELINUX=disabled/g" /etc/sysconfig/selinux; fi

ENV HOME /opt/openmama
RUN useradd -d $HOME -m -s /bin/bash mama
RUN echo "mama:mama"|chpasswd
RUN echo 'mama ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#add proton from EPEL
RUN yum install -y qpid-proton-c  --enablerepo=epel

#add local stored openmama rpm
ADD openmama*.rpm /root/
RUN yum localinstall -y --nogpgcheck /root/openmama-${MAMA_VERSION}*.rpm && rm /root/openmama-${MAMA_VERSION}*.rpm

#test scripts
COPY ["testdata/*.sh", "/opt/openmama/bin/"]

#Volume
RUN mkdir /data  
RUN chown -R mama:mama $HOME /data

#non root user
USER mama
WORKDIR $HOME


ADD [ ".vimrc","$HOME/"]
RUN ln -s /data $HOME/extdata
ENV TERM linux

#interface
VOLUME [ "/data"]

CMD ["bash"]
