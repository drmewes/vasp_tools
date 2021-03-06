#!/bin/bash

natoms=32

if [ $4 ] ; then
	natoms=$4
fi 
echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/Og/POTCAR ~/bin/vasp_tools/Og/INCAR_SCAN ~/bin/vasp_tools/Og/KPOINTS SHIFT/
mv SHIFT/INCAR_SCAN SHIFT/INCAR

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
done 

for i in SR*CONF* ; do 
	cd $i 
	subv -p16 -m3 -t24 -n2-4
	cd - 
done

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/SO600/) 
	cp -r $i $j 
	sed -i /LSORBIT/s/FALSE/TRUE/ $j/INCAR 
done 

for i in SO*CONF* ; do
        cd $i
        subvSO -p32 -m4 -t72 -n2-4
        cd -
done



