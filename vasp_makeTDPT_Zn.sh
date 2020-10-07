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

cp ~/bin/vasp_tools/Zn/POTCAR ~/bin/vasp_tools/Zn/INCAR ~/bin/vasp_tools/Zn/KPOINTS SHIFT/

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
	j=$(echo $i | sed s/SR600/K3SR600/)
	cp -r $i $j 
	sed -i "s/2  2  2/3  3  3/" $j/KPOINTS 
done 

for i in SR600_CONF* ; do
        j=$(echo $i | sed s/SR600/SO600/)
        cp -r $i $j
        sed -i "/LSORBIT/s/FALSE/TRUE/" $j/INCAR
done

for i in SR* ; do
        cd $i
        subvMAUI -p80 -m1 -t24 -n1 -q nesi_research
        cd -
done

for i in SO* ; do
        cd $i
        subvMAUISO -p80 -m2 -t24 -n1 -q nesi_research
        cd -
done

if [ $4 ] ; then  
for i in K3SR* ; do
        cd $i
        subvMAUI -p160 -m1 -t12 -n2 -q nesi_research
        cd -
done
fi

