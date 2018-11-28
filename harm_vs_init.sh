#!/bin/bash

nsteps=$(tac output | grep F= -m1 | awk '{print $1}')
step0=500

diff=0

if [ $1 ] ; then 
 step0=$1
fi

echo "Nsteps: $nsteps, Step0: $step0"


for i in $(seq $step0 1 $nsteps) ; do
	harm=$(grep " $i T=" -B1 output | grep initio | awk '{print $4}')
	init=$(grep " $i T=" -B1 output | grep initio | awk '{print $2}')
	diff=$(echo "$diff+($harm-($init))" | sed s/[eE]+*/*10^/ | sed s/[eE]+*/*10^/ | bc)
	#echo $i $diff $init $harm
done

totaldiff=$(echo $diff/$nsteps/64 | bc -l)

echo "Final average difference is $totaldiff eV"

