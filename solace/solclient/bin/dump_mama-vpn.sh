#!/bin/bash
VMR=${1:-solace-vmr}
WORK=$(dirname $0)
PATH=$PATH:$WORK
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORK/../lib
sdkperf_c -cip=$VMR -cu=mama@mama-vpn -cp=mama -stl=">" -md
