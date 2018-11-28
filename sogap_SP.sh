#!/bin/bash

if [ $(grep LSORBIT $1 | awk '{print $3}') == "T" ] ; then
  homo=`awk '/NELECT/ {print $3/1}' $1`
  lumo=`awk '/NELECT/ {print $3/1+1}' $1`
  nkpt=`awk '/NKPTS/ {print $4}' $1`
else
  homo=`awk '/NELECT/ {print $3/2}' $1`
  lumo=`awk '/NELECT/ {print $3/2+1}' $1`
  nkpt=`awk '/NKPTS/ {print $4}' $1`
fi

e1=`grep "average (electrostatic) potential at core" $1 -A10000 | egrep "     $homo     " | grep -v "         " | tail -n $nkpt | sort -n -k 2 -r |head -1 | awk '{print $2}'`
e2=`grep "average (electrostatic) potential at core" $1 -A10000 | egrep "     $lumo     " | grep -v "         " | tail -n $nkpt | sort -g -k 2  | head -1 | awk '{print $2}'`
gap=$(echo "$e2-($e1)" | bc)

echo "HOMO: $e1 eV (band# $homo)"
echo "LUMO: $e2 eV (band# $lumo)"
echo " Gap: $gap eV"

