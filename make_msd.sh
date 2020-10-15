#!/bin/bash

python2.7 < ~/bin/vasp_tools/xdatcar2xyz.py
python2.7 < ~/bin/vasp_tools/msd.py

tail -n 8000 msd.out | grep ^[0-9]*00" " | awk '{printf("%5.0f %2.2f\n",$1,$2)}'

