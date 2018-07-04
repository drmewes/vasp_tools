#!/bin/bash

echo #Plot looptime vs step in vasp simulation + output average

grep LOOP+ OUTCAR | awk '{print $7}' > Lplot
average=$(grep LOOP+ OUTCAR| awk '{ sum += $7; n++ } END { if (n > 0) print sum / n; }')
#sed -i "s/^/$average /" 4plot

if [ $1 ] ; then 
echo "### Average SCF time: $average s"
echo "Found argument, I'm done here"
else
echo "### Average SCF time: $average s"
module load netcdf/gcc/64/4.3.3.1 
xmgrace -autoscale xy Lplot

fi 
