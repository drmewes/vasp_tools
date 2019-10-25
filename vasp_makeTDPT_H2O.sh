#!/bin/bash

natoms=$((96+192)) 

if [ $4 ] ; then
	natoms=$4
fi 
echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep --binary-files=text "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/H2O/POTCAR ~/bin/vasp_tools/H2O/INCAR ~/bin/vasp_tools/H2O/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR700_CONF${i}_SP
	cp INCAR POTCAR KPOINTS SR700_CONF${i}_SP 
	cp conf${i}.POSCAR SR700_CONF${i}_SP/POSCAR 
done

for i in SR700_CONF* ; do 
	j=$(echo $i | sed s/SR700/SR400/) 
	cp -r $i $j 
	sed -i /ENCUT/s/700/400/ $j/INCAR 
done 

for i in SR700_CONF* ; do 
	j=$(echo $i | sed s/SR700/K2SR700/)
	cp -r $i $j 
	sed -i "s/1  1  1/2  2  2/" $j/KPOINTS 
        sed -i "/KPAR/s/1/4/" $j/INCAR
done 

for i in SR* ; do
        cd $i
        subvMAUI -p80 -m1 -t12 -n1 -q nesi_research
        cd -
done

#for i in K2SR* ; do
#        cd $i
#        subvMAUI -p160 -m1 -t12 -n2 -q nesi_research
#        cd -
#done


