#!/bin/bash

if [ $1 ] && [ $2 ] && [ $3 ] && [ $4 ] && [ $5 ] && [ $6 ] ; then
	for lev in $1 $2 $3 ; do 
		echo "### LEVEL $lev:" 
		for i in $(seq $4 $5 $6) ; do 
			echo -n "$i " 
			grep "FREE ENERGIE" ${lev}_CONF${i}_SP/OUTCAR -A3 | grep TOTEN | awk '{print $5}' 
		done 
	done
elif [ $1 ] && [ $2 ] && [ $3 ] && [ $4 ] && [ $5 ] ; then
        for lev in $1 $2 ; do 
                echo "### LEVEL $lev:" 
                for i in $(seq $3 $4 $5) ; do 
                        echo -n "$i "
			grep "FREE ENERGIE" ${lev}_CONF${i}_SP/OUTCAR -A3 | grep TOTEN | awk '{print $5}' 
                done 
        done
else
	echo "Need at least 5 arguments (level1 level2 [level3] frame0 stepsize endframe)"
fi

