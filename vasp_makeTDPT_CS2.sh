#!/bin/bash

natoms=102

echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep --binary-files=text "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/CS2/POTCAR ~/bin/vasp_tools/CS2/INCAR ~/bin/vasp_tools/CS2/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR600_CONF${i}_SP
	cp INCAR POTCAR KPOINTS SR600_CONF${i}_SP 
	cp conf${i}.POSCAR SR600_CONF${i}_SP/POSCAR 
done

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/SR300/) 
	cp -r $i $j 
	sed -i /ENCUT/s/600/300/ $j/INCAR 
	sed -i /EDIFF/s/06/04/ $j/INCAR
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
        subvMAUI -p80 -m1 -t12 -n1 -q nesi_research
        cd -
done

if [ $4 ] ; then 
	for i in K2SR* ; do
       		cd $i
        	subvMAUI -p160 -m1 -t12 -n2 -q nesi_research
        	cd -
	done
fi


