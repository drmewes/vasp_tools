#!/bin/bash

echo #Plot temperature vs step in vasp simulation + output average

grep "  FREE ENERGIE" OUTCAR -A3 | grep "free  energy" | awk '{print $5}' > Eplot
average=$(grep "  FREE ENERGIE" OUTCAR -A3 | grep "free  energy" | awk '{ sum += $5; n++ } END { if (n > 0) print sum / n; }')
#sed -i "s/^/$average /" 4plot

if [ $1 ] ; then 
echo "### Average Temp: $average"
echo "Found argument, I'm done here"
else
echo "### Average Temp: $average"
module load netcdf/gcc/64/4.3.3.1 
xmgrace -autoscale xy Eplot

fi 
