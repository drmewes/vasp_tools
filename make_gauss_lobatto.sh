#!/bin/bash

echo "###########################################"
echo "### Gauss-Lobatto Free-Energie Machine  ###"
if [ "$1" = "-h" ]; then
echo "### Prepare sample input in folder GLIN ###"
echo "### with _SCALEE_ for coupling strength ###"
echo "### Arg1: number of nodes (default 8)   ###"
echo "### Arg2: kappa (0<=k<1, default 0.60)  ###"
echo "###########################################"
exit
fi 
echo "###########################################"
echo

n=8
k=0.60

SCALEE=1.0
declare -a x

if [ $1 ] ; then 
	n=$1
	if [ $2 ] ; then
		k=$2
	fi
fi

if [ -d GLIN ] && [ -e GLIN/INCAR ] && [ $(grep _SCALEE_ GLIN/INCAR) ] ; then 

echo "Creating input for integration with n = $n, k = $k:"

if (( "$n" == "7" )) ; then
	x=("0.830223896278567" "0.468848793470714" "0.0" "-0.468848793470714" "-0.830223896278567")
	cp -rf GLIN L1
	sed -i s/_SCALEE_/1.0/ L1/INCAR
        echo "L1 1.000000 (full interaction - normal MD)"
	for i in $(seq 2 $((n-1))) ; do
		SCALEE=$(awk "BEGIN { print ((${x[$((i-2))]}+1)/2)**(1/(1-$k))}")
		echo "L$i $SCALEE"
		cp -rf L1 L$i
		sed -i s/_SCALEE_/$SCALEE/ L$i/INCAR
	done
        echo "L$n 0.000000 (non-interacting limit - skipped)"
elif (( "$n" == "8" )) ; then
        x=("0.8717401485" "0.5917001814" "0.2092992179" "-0.2092992179" "-0.5917001814" "-0.8717401485")
        cp -rf GLIN L1
        sed -i s/_SCALEE_/1.0/ L1/INCAR
        echo "L1 1.000000 (full interaction - normal MD)"
	for i in $(seq 2 $((n-1))) ; do
                cp GLIN L${i} -r
                SCALEE=$(awk "BEGIN { print ((${x[$((i-2))]}+1)/2)**(1/(1-$k))}")
                echo "L$i $SCALEE"
                cp -rf GLIN L$i
                sed -i s/_SCALEE_/$SCALEE/ L$i/INCAR
	done
        echo "L$n 0.000000 (non-interacting limit - skipped)"
elif (( "$n" == "9" )) ; then
        x=("0.8997579954" "0.6771862795" "0.3631174638" "0" "-0.363117464" "-0.6771862795" "-0.8997579954")
        cp -rf GLIN L1
        sed -i s/_SCALEE_/1.0/ L1/INCAR
        echo "L1 1.000000 (full interaction - normal MD)"
        for i in $(seq 2 $((n-1))) ; do
                cp GLIN L${i} -r
                SCALEE=$(awk "BEGIN { print ((${x[$((i-2))]}+1)/2)**(1/(1-$k))}")
                echo "L$i $SCALEE"
                cp -rf GLIN L$i
                sed -i s/_SCALEE_/$SCALEE/ L$i/INCAR
	done
        echo "L$n 0.000000 (non-interacting limit - skipped)"
elif (( "$n" == "10" )) ; then
        x=("0.9195339082" "0.7387738651" "0.4779249498" "0.1652789577" "-0.1652789577" "-0.4779249498" "-0.7387738651" "-0.9195339082")
        cp -rf GLIN L1
        sed -i s/_SCALEE_/1.0/ L1/INCAR
	echo "L1 1.000000 (full interaction - normal MD)"
        for i in $(seq 2 $((n-1))) ; do
                cp GLIN L${i} -r
                SCALEE=$(awk "BEGIN { print ((${x[$((i-2))]}+1)/2)**(1/(1-$k))}")
                echo "L$i $SCALEE"
                cp -rf GLIN L$i
                sed -i s/_SCALEE_/$SCALEE/ L$i/INCAR
        done
        echo "L$n 0.000000 (non-interacting limit - skipped)"
else echo "This value number of nodes is not (yet) supported."
fi

echo ALLDONE

else 	echo "Template for input not found or does not contain _SCALEE_ ."
	echo "--> please create GLIN/INCAR file and indicate where to put coupling strength." && exit 
fi
