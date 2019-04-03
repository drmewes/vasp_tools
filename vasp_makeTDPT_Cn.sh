#!/bin/bash

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep "Direct configuration=[' ']*$i$" XDATCAR -A100 >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/Cn/POTCAR ~/bin/vasp_tools/Cn/INCAR ~/bin/vasp_tools/Cn/KPOINTS SHIFT/

cd SHIFT

for i in $(seq $1 $2 $3) ; do 
	mkdir SR600_CONF${i}_SP 
	cp INCAR POTCAR KPOINTS SR600_CONF${i}_SP 
	cp conf${i}.POSCAR SR600_CONF${i}_SP/POSCAR 
done

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/SR400/) 
	cp -r $i $j 
	sed -i /ENCUT/s/600/400/ $j/INCAR 
done 

for i in SR*CONF* ; do 
	cd $i 
	subv -p16 -m2 -t72 -n4 
	cd - 
done

for i in SR600_CONF* ; do 
	j=$(echo $i | sed s/SR600/SO600/) 
	cp -r $i $j 
	sed -i /LSORBIT/s/FALSE/TRUE/ $j/INCAR 
done 

for i in SO*CONF* ; do
        cd $i
        subv -p32 -m6 -t72 -n4
        cd -
done




