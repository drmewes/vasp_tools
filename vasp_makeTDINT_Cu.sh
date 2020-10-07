#!/bin/bash

natoms=64  

echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep --binary-files=text "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/Cu/POTCAR ~/bin/vasp_tools/Cu/INCAR ~/bin/vasp_tools/Cu/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR350_CONF${i}_SP
	cp INCAR POTCAR KPOINTS SR350_CONF${i}_SP 
	cp conf${i}.POSCAR SR350_CONF${i}_SP/POSCAR 
	sed -i /ENCUT/s/600/350/ SR350_CONF${i}_SP/INCAR 
	sed -i /EDIFF/s/06/04/ SR350_CONF${i}_SP/INCAR
	sed -i /PREC/s/accurate/normal/ SR350_CONF${i}_SP/INCAR
done 

for i in SR350_CONF* ; do 
	j=$(echo $i | sed s/SR350/K2SR350/)
	cp -r $i $j 
	sed -i "s/1  1  1/2  2  2/" $j/KPOINTS 
        sed -i "/KPAR/s/1/2/" $j/INCAR
done 

for i in SR* ; do
        cd $i
        subvMAUI -p80 -m1 -t1 -n1 -q nesi_research
        cd -
done

for i in K2SR* ; do
        cd $i
        subvMAUI -p80 -m1 -t1 -n1 -q nesi_research
        cd -
done

