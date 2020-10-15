#!/bin/bash

echo "Usage: harm_vs_init.sh startstep endstep natoms"

nsteps=$(tac output | grep F= -m1 | awk '{print $1}')
echo "Found $nsteps usable steps."
step0=500
natoms=64

thisdiff=0
diff=0

if [ $1 ] ; then 
 step0=$1
fi

if [ $3 ] ; then
 natoms=$3
fi

if [ $2 ] ; then
 if [ $2 -lt $nsteps ] ; then
  nsteps=$2
 else
  echo "Simulation too short for given endstep. Using maximum value of $nsteps."
 fi
fi

echo "Endstep: $nsteps, Step0: $step0, nAtoms: $natoms"

grep -e initio -e F= output > tmpout
cat tmpout | head -n $((2*nsteps+2)) > tmpout2 
cat tmpout2| tail -n $((2*(nsteps-step0)+10)) > tmpout 

for i in $(seq -f '%5.f' $step0 1 $nsteps) ; do
	line=$(grep " $i T=" -B1 tmpout | head -n1 )
	harm=$(echo $line | awk '{print $4}')
	init=$(echo $line | awk '{print $2}')
	thisdiff=$(echo "(($init)-($harm))" | sed s/[eE]+*/*10^/ | sed s/[eE]+*/*10^/ | bc)
        #echo "(($init)-($harm))" | sed s/[eE]+*/*10^/ | sed s/[eE]+*/*10^/ 
	diff=$(echo $diff+$thisdiff | bc)
	echo "$thisdiff $harm $init" >> ener_diff_harm_init.txt
	#echo $i $diff $init $harm
done

totaldiff=$(echo "$diff/($nsteps-$step0)/$natoms" | bc -l)

echo "Final average difference is $totaldiff eV"

rm tmpout tmpout2

