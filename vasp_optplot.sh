#!/bin/bash

atstep=$(grep "d E" output | tail -n1 | awk '{print $1}')
if [ $atstep -gt 20 ]
	then nsteps=15
	else nsteps=$((atstep-1))
fi
start=$(echo "$atstep-$nsteps" | bc)
bigstep=100

if [ $atstep -gt 200 ]  
	then bigstep=50
elif [ $atstep -gt 100 ]
	then bigstep=25
elif [ $atstep -gt 50 ] 
	then bigstep=10
elif [ $atstep -gt 20 ]
	then bigstep=5
else bigstep=1
fi

if (( "$atstep" > 20 ))
	then tostep=$(echo $atstep-15 | bc )
	else	tostep=1
fi

echo -e "Step\t Energy [eH] \t dE [eV]"
for i in $(seq 2 $bigstep $tostep) 
	do energy=$(grep " $i F=" output | tail -n1 | cut -c 29-41)
	   energy_eH=$(echo $energy | sed s/[eE]+*/*10^/ | bc | cut -c -9)
	   dE=$(grep " $i F=" output | tail -n1 | cut -c 49-)
	   dE1=$(echo "$dE" | sed 's/[eE]+*/*10^/' | bc -l| cut -c -10)
		echo -e "$i\t $energy_eH\t $dE1"
	done
for i in $(seq $start $atstep) 
	do energy=$(grep " $i F=" output | tail -n1 | cut -c 29-41)
	   energy_eH=$(echo $energy | sed s/[eE]+*/*10^/ | bc | cut -c -9)
	   dE=$(grep " $i F=" output | tail -n1 | cut -c 49-)
	   dE1=$(echo "$dE" | sed 's/[eE]+*/*10^/' | bc -l | cut -c -10)
		echo -e "$i\t $energy_eH\t $dE1"
	done

Econv=$(grep EDIFFG INCAR | awk '{print $3}' | sed 's/[eE]+*/*10^/' | bc -l)
echo -e "      Converged when dE < "$(echo "scale=6; $Econv" | bc | cut -c -9)
	 

		
