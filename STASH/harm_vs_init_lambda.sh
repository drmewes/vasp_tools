#!/bin/bash

nsteps=$(tac output | grep F= -m1 | awk '{print $1}')
step0=500
natoms=64

diff=0

if [ $1 ] ; then 
 step0=$1
fi

if [ $2 ] ; then
 natoms=$2
fi


echo "Nsteps: $nsteps, Step0: $step0"


for i in $(seq $step0 1 $nsteps) ; do
	harm=$(grep " $i T=" -B1 output | grep initio | awk '{print $4}')
	init=$(grep " $i T=" -B1 output | grep initio | awk '{print $2}')
	diff=$(echo "$diff+(1.07*$init-($harm))" | sed s/[eE]+*/*10^/ | sed s/[eE]+*/*10^/ | bc)
	#echo $i $diff $init $harm
done

totaldiff=$(echo "$diff/($nsteps-$step0)/$natoms" | bc -l)

echo "Final average difference is $totaldiff eV"

