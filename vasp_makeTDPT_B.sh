#!/bin/bash

natoms=64  

if [ $4 ] ; then
	natoms=$4
fi

echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep --binary-files=text "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/B/POTCAR ~/bin/vasp_tools/B/INCAR ~/bin/vasp_tools/B/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR600_CONF${i}_SP
	cp INCAR POTCAR KPOINTS SR600_CONF${i}_SP 
	cp conf${i}.POSCAR SR600_CONF${i}_SP/POSCAR 
done

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/SR350/) 
	cp -r $i $j 
	sed -i /ENCUT/s/600/350/ $j/INCAR 
	sed -i /EDIFF/s/06/04/ $j/INCAR
	sed -i /PREC/s/accurate/normal/ $j/INCAR
        sed -i /LASPH/s/TRUE/FALSE/ $j/INCAR
done 

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/K3SR600/)
	cp -r $i $j 
	sed -i "s/2  2  2/3  3  3/" $j/KPOINTS 
        sed -i "/KPAR/s/2/4/" $j/INCAR
done 

for i in K3SR* SR* ; do
        cd $i
        subvMAUI -p160 -m1 -t12 -n2 -q nesi_research
        cd -
done


