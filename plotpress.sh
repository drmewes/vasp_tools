#!/bin/bash

echo #Plot pressure vs step in vasp simulation + output average

grep "total pressure" OUTCAR | awk '{print $4}' > Pplot
average=$(grep "total pressure" OUTCAR | awk '{ sum += $4; n++ } END { if (n > 0) print sum / n; }')
#sed -i "s/^/$average /" 4plot

echo "### Average: $average"
module load netcdf/gcc/64/4.3.3.1 
xmgrace -autoscale xy Pplot

 
