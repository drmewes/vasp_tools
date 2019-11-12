#!/bin/bash

natoms=180 

if [ $4 ] ; then
	natoms=$4
fi 
echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep --binary-files=text "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/CCl4/POTCAR ~/bin/vasp_tools/CCl4/INCAR ~/bin/vasp_tools/CCl4/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR600_CONF${i}_SP
	cp INCAR POTCAR KPOINTS SR600_CONF${i}_SP 
	cp conf${i}.POSCAR SR600_CONF${i}_SP/POSCAR 
done

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/SR250/) 
	cp -r $i $j 
	sed -i /ENCUT/s/600/250/ $j/INCAR 
	sed -i /EDIFF/s/06/04/ $j INCAR
	sed -i /PREC/s/accurate/normal/ $j/INCAR
done 

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/K2SR600/)
	cp -r $i $j 
	sed -i "s/1  1  1/2  2  2/" $j/KPOINTS 
        sed -i "/KPAR/s/1/4/" $j/INCAR
done 

for i in SR* ; do
        cd $i
        subvMAUI -p160 -m1 -t24 -n2 -q nesi_research
        cd -
done

#for i in K2SR* ; do
#        cd $i
#        subvMAUI -p160 -m1 -t12 -n2 -q nesi_research
#        cd -
#done


