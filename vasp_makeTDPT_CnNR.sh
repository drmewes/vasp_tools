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

cp ~/bin/vasp_tools/CnNR/POTCAR ~/bin/vasp_tools/CnNR/INCAR ~/bin/vasp_tools/CnNR/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR600_CONF${i}_SP 
	cp INCAR POTCAR KPOINTS SR600_CONF${i}_SP 
	cp conf${i}.POSCAR SR600_CONF${i}_SP/POSCAR 
done

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/SR400/) 
	cp -r $i $j 
	sed -i /ENCUT/s/600/400/ $j/INCAR 
done 

for i in SR*CONF* ; do 
	cd $i 
	subv -p16 -m4 -t12 -n2 
	cd - 
done

for i in SR600_CONF* ; do
        j=$(echo K3$i)
        cp -r $i $j
        sed -i "s/2  2  2/3  3  3/" $j/KPOINTS
done

for i in K3*CONF* ; do
        cd $i
        subv -p16 -m4 -t36 -n2
        cd -
done

