#!/bin/bash

natoms=96 

if [ $4 ] ; then
	natoms=$4
fi 
echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep --binary-files=text "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/Br/POTCAR ~/bin/vasp_tools/Br/INCAR ~/bin/vasp_tools/Br/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR500_CONF${i}_SP
	cp INCAR POTCAR KPOINTS SR500_CONF${i}_SP 
	cp conf${i}.POSCAR SR500_CONF${i}_SP/POSCAR 
done

for i in SR500_CONF* ; do 
	j=$(echo $i | sed s/SR500/SR250/) 
	cp -r $i $j 
	sed -i /ENCUT/s/500/250/ $j/INCAR 
done 

for i in SR500_CONF* ; do 
	j=$(echo $i | sed s/SR500/K2SR500/)
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


