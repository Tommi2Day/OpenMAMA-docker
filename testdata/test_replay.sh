#!/bin/bash
capturereplayc -S DATA_FEED -m qpid -tport pub -dictionary $HOME/data/dictionary/data.dict  -f $HOME/data/playbacks/openmama_utpcasheuro_capture.5000.10.qpid.mplay
