#!/bin/bash

echo #Plot Ekin + output average

grep "EK=" OSZICAR | awk '{print $11}' > ekin.txt
average=$(grep "EK=" OSZICAR | awk '{ sum += $11; n++ } END { if (n > 0) print sum / n; }')
#sed -i "s/^/$average /" 4plot

echo "### Average Ekin: $average"

