#!/bin/bash

natoms=64

if [ $4 ] ; then
	natoms=$4
fi 
echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/K/POTCAR ~/bin/vasp_tools/K/INCAR ~/bin/vasp_tools/K/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR300_CONF${i}_SP 
	cp INCAR POTCAR KPOINTS SR300_CONF${i}_SP 
	cp conf${i}.POSCAR SR300_CONF${i}_SP/POSCAR 
done

for i in SR300_CONF* ; do 
	j=$(echo $i | sed s/SR300/SR150/) 
	cp -r $i $j 
	sed -i /ENCUT/s/300/150/ $j/INCAR 
done 

for i in SR300_CONF* ; do 
	j=$(echo $i | sed s/SR300/K2SR300/)
	cp -r $i $j 
	sed -i "s/1  1  1/2  2  2/" $j/KPOINTS 
        sed -i "/KPAR/s/1/4/" $j/INCAR
done 

for i in SR* ; do
        cd $i
        subvMAUI -p80 -m1 -t12 -n1 -q nesi_research
        cd -
done

for i in K2SR* ; do
        cd $i
        subvMAUI -p160 -m1 -t12 -n2 -q nesi_research
        cd -
done


