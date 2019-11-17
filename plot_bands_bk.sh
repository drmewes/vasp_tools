#!/bin/bash

nbands=24
nkpt=40

tmp1=$1
tmp2=$2

if [ $1 ] ; then 
	nbands=$tmp1
fi

if [ $2 ] ; then
	nkpt=$2
fi 

for band in $(seq $nbands) ; do 
	echo -en "Band$band: " 
	for i in $(seq $nkpt) ; do 
		ener=$(grep "k-point  *  $i :" -A $((band+1)) OUTCAR | tail -n1 | awk '{print $2}') 
		echo -en "$ener " 
	done 
	echo "" 
done
