#!/bin/bash
#setup a new VMR with cli scripts
#debug
if [ -n "$DEBUG" ]; then
	set -x 
fi

ME=$0
VMR=${1:-solace-vmr}
KEY=id_rsa_$VMR
KEYFILE=~/.ssh/$KEY
CONFIG=/opt/openmama/config

#set working dir
if [ -L $ME ]; then
	ME=$(readlink $ME)
fi
cd $(dirname $ME)

#generate new ssh key if needed
if [ ! -r $KEYFILE ]; then
	if [ -r $CONFIG/$KEY ]; then
		cp $CONFIG/$KEY ~/.ssh/
	else
		ssh-keygen -t rsa -f $KEYFILE -N ''
		if [ $? -ne 0 ]; then 
			echo "failed to create new ssh key as $KEYFILE"
			exit 1
		fi
		#save to local directory
		cp $KEYFILE* $CONFIG/.
	fi
fi

PERM=$(stat --format '%a' $KEYFILE)
if [ $PERM -ne 600 ]; then
    chmod 600 $KEYFILE
fi
#public key
if [ ! -r ${KEYFILE}.pub ]; then
	echo "Cannot read public ssh key ${KEYFILE}.pub"
	exit 1
fi
AK=$(cat ${KEYFILE}.pub)

#add vmr host key
HK=$(ssh-keyscan -t ecdsa -p 2222 $VMR 2>/dev/null)
if [ $? -ne 0 ];then
	echo "Cannot access $VMR"
	exit 1
fi
if ! test -r ~/.ssh/known_hosts || ! grep "$HK" ~/.ssh/known_hosts ;then
	echo "$HK" >>~/.ssh/known_hosts
fi
#add own public key to sysadmin
echo "first time it will ask for the (new) sysadmin password. "
ssh -p 2222 -i ${KEYFILE} sysadmin@$VMR "if [ ! -d ~/.ssh ]; then mkdir ~/.ssh;fi ;if ! grep '$AK' ~/.ssh/autorized_keys ; then echo '$AK' >>~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys; fi"
if [ $? -eq 0 ]; then
	#set admin password and create transfer user via cli
	./run_cli.sh users.cli $VMR 
	#create mama vpn and client
	./run_cli.sh mama.cli $VMR 
	echo ""
	echo "Setup finished, check output"
else
	echo "ssh to sysadmin@VMR Port 2222 failed"
fi
