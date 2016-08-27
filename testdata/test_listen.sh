#!/bin/sh
. /opt/openmama/config/profile.openmama
mamalistenc -m qpid -tport sub -S DATA_FEED -s DE000CM95AU4.EUR.XPAR  -dictionary $HOME/data/dictionaries/data.dict
