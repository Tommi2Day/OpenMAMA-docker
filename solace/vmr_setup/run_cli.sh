#!/bin/bash
#debug
if [ -n "$DEBUG" ]; then
	set -x
fi

#arguments
if [ $# -lt 1 ]; then
	echo "Usage: $0 <SCRIPT> [ <VMR-Host>(default solace-vmr)] [<debug>]"
	exit 1
fi
ME=$0
SCRIPT=$1
VMR=${2:-solace-vmr}
KEY=id_rsa_$VMR
KEYFILE=~/.ssh/$KEY
CONFIG=/opt/openmama/config

# set worikng dir
if [ -L $ME ]; then
    ME=$(readlink $ME)
fi

#check tools
for tool in stat scp ssh expect chmod grep; do
	TOOL=$(which $tool)
	if [ -z "$TOOL" ]; then
		echo "cannot find '$tool'"
		exit 1
	fi
done

#check script
if [ ! -r $SCRIPT ]; then
	echo "cannot read $SCRIPT"
	exit 1
fi



#check ssh KEY
if [ ! -r $KEYFILE ]; then
	if [ ! -r $CONFIG/$KEY ]; then
		echo "Cannot read ssh key file $KEYFILE"
		exit 1
	else
		cp $CONFIG/$KEY $KEYFILE
		PERM=$(stat --format '%a' $KEYFILE)
		if [ $PERM -ne 600 ]; then
			chmod 600 $KEYFILE
		fi
	fi
fi

#add vmr host key
HK=$(ssh-keyscan -t ecdsa -p 2222 $VMR 2>/dev/null)
if [ $? -ne 0 ];then
    echo "Cannot access $VMR"
    exit 1
fi
if ! grep "$HK" ~/.ssh/known_hosts ;then
    echo "$HK" >>~/.ssh/known_hosts
fi

#copy and execute remote on VMR with expect
scp -P 2222 -i $KEYFILE $SCRIPT sysadmin@$VMR:.
if [ $? -eq 0 ]; then
	ssh -p 2222 -i $KEYFILE sysadmin@$VMR "docker cp $SCRIPT solace:/usr/solace/jail/cliscripts/"
	expect -f $(dirname $ME)/run_cli.expect $VMR $(basename $SCRIPT) $KEYFILE
	exit $?
else
	echo "cannot transfer $SCRIPT to $VMR"
	exit 1
fi

