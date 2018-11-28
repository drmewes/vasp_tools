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

e1=`grep "QP_SHIFT:  cpu time  " $1 -A100000 | egrep "     $homo     " | grep -v "         " | tail -n $nkpt | sort -n -k 3 -r |head -n 1 | awk '{print $3}'`
e2=`grep "QP_SHIFT:  cpu time  " $1 -A100000 | egrep "     $lumo     " | grep -v "         " | tail -n $nkpt | sort -g -k 3  | head -n 1 | awk '{print $3}'`
gap=$(echo "$e2-($e1)" | bc)

echo "HOMO: $e1 eV (band# $homo)"
echo "LUMO: $e2 eV (band# $lumo)"
echo " Gap: $gap eV"

