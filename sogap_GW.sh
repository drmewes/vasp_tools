#!/bin/bash

homo=`awk '/NELECT/ {print $3/1}' $1`
lumo=`awk '/NELECT/ {print $3/1+1}' $1`
nkpt=`awk '/NKPTS/ {print $4}' $1`

e1=`grep "     $homo     " $1 | tail -$nkpt | sort -n -k 3 | tail -1 | awk '{print $3}'`
e2=`grep "     $lumo     " $1 | tail -$nkpt | sort -n -k 3 | head -1 | awk '{print $3}'`
gap=$(echo "$e2-($e1)" | bc)

echo "HOMO: $e1 eV (band# $homo)"
echo "LUMO: $e2 eV (band# $lumo)"
echo " Gap: $gap eV"

