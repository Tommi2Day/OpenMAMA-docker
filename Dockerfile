FROM centos:centos7
MAINTAINER Tommi2Day

ENV HOSTNAME openmama

RUN yum update -y && yum install -y epel-release vim wget tar mc sudo git-core java-1.8.0-openjdk-devel libevent libuuid && yum clean all

ENV MAMA_VERSION 6.1.0
ENV RPM_BUILD 2
ENV JAVA_HOME /etc/alternatives/java_jdk

# Disables the firewall
RUN systemctl disable firewalld

#disable selinux
RUN if [ -w /etc/sysconfig/selinux ]; then perl -pi -e "s/^SELINUX=.*/SELINUX=disabled/g" /etc/sysconfig/selinux; fi

#create user
ENV HOME /opt/openmama
RUN useradd -d $HOME -m -s /bin/bash mama
RUN echo "mama:mama"|chpasswd
RUN echo 'mama ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#install qpid from EPEL
RUN yum install -y qpid-proton-c  --enablerepo=epel

#install openmama from local rpm
ADD openmama*.rpm /root/
RUN yum localinstall -y --nogpgcheck /root/openmama-${MAMA_VERSION}-${RPM_BUILD}*.rpm /root/openmama-devel-${MAMA_VERSION}-${RPM_BUILD}*.rpm && \
	rm /root/openmama-${MAMA_VERSION}-${RPM_BUILD}*.rpm /root/openmama-devel-${MAMA_VERSION}-${RPM_BUILD}*.rpm && yum clean all

#make default config copy to be restore if mounted config dir is empty and source profile
RUN mkdir /opt/openmama/config-default && cp -r /opt/openmama/config/* /opt/openmama/config-default/ && \
	mkdir -p $HOME/.ssh && ln -s /data $HOME/extdata
	
	
#copy testdata run scripts
COPY ["testdata/*.sh", "/opt/openmama/bin/"]

#add data mount point
RUN mkdir /data  

#set rights
RUN chown -R mama:mama $HOME /data

#enhance environment
USER mama
WORKDIR $HOME

ADD [ ".vimrc",".bashrc","$HOME/"]
ENV TERM xterm
ENV EDITOR vim

#volumes
VOLUME [ "/data", "/opt/openmama/config" ]

#entry point
CMD ["bash"]
