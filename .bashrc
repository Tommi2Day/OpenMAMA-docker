# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
sudo chown -R mama:mama /opt/openmama/config
if [ ! -r /opt/openmama/config/mama.properties ]; then 
	cp -r /opt/openmama/config-default/mama.properties /opt/openmama/config/.; 
fi
if [ ! -r /opt/openmama/config/profile.openmama  ]; then 
	cp -r /opt/openmama/config-default/profile.openmama  /opt/openmama/config/.; 
fi
echo $PATH|grep openmama >/dev/null || . /opt/openmama/config/profile.openmama
