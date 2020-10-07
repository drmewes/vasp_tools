#!/bin/bash

natoms=61

if [ $4 ] ; then
	natoms=$4
fi 
echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/Xe/POTCAR ~/bin/vasp_tools/Xe/INCAR ~/bin/vasp_tools/Xe/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR400_CONF${i}_SP 
	cp INCAR POTCAR KPOINTS SR400_CONF${i}_SP 
	cp conf${i}.POSCAR SR400_CONF${i}_SP/POSCAR 
done

for i in SR400_CONF* ; do 
	j=$(echo $i | sed s/SR400/SR200/) 
	cp -r $i $j 
	sed -i /ENCUT/s/400/200/ $j/INCAR 
	sed -i /EDIFF/s/06/04/ $j/INCAR
	sed -i /PREC/s/accurate/normal/ $j/INCAR
#	sed -i /LASPH/s/TRUE/FALSE/ $j/INCAR
done 

for i in SR400_CONF* ; do 
	j=$(echo $i | sed s/SR400/K2SR400/)
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


