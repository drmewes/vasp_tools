#!/bin/bash

natoms=64  

#if [ $4 ] ; then
#	natoms=$4
#fi 
echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep --binary-files=text "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/Ba/POTCAR ~/bin/vasp_tools/Ba/INCAR ~/bin/vasp_tools/Ba/KPOINTS SHIFT/

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
done 

for i in SR400_CONF* ; do 
	j=$(echo $i | sed s/SR400/K2SR400/)
	cp -r $i $j 
	sed -i "s/1  1  1/2  2  2/" $j/KPOINTS 
        sed -i "/KPAR/s/1/2/" $j/INCAR
done 

for i in SR400_CONF* ; do
        j=$(echo $i | sed s/SR400/SO400/)
        cp -r $i $j
        sed -i "/LSORBIT/s/FALSE/TRUE/" $j/INCAR
	sed -i "/NBANDS/s/420/900/" $j/INCAR
done


for i in K2SR* SR* ; do
        cd $i
        subvMAUI -p80 -m1 -t24 -n1 -q nesi_research
        cd -
done

if [ $4 ] ; then  
for i in SO* ; do
        cd $i
        subvSOMAUI -p160 -m1 -t24 -n2 -q nesi_research
        cd -
done
fi

