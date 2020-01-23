#!/bin/bash

natoms=61

if [ $4 ] ; then
	natoms=$4
fi 
echo "Using $natoms atoms..."

mkdir SHIFT

for i in $(seq $1 $2 $3) ; do 
	head -n7 XDATCAR > SHIFT/conf$i.POSCAR 
	grep "Direct configuration=[' ']*$i$" XDATCAR -A $natoms >> SHIFT/conf$i.POSCAR
done

cp ~/bin/vasp_tools/Og/POTCAR ~/bin/vasp_tools/Og/INCAR ~/bin/vasp_tools/Og/KPOINTS SHIFT/

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
        sed -i /Precision/s/Accurate/Normal/ $j/INCAR 
        sed -i /EDIFF/s/6/4/ $j/INCAR 
done 

for i in SR600_CONF* ; do
        j=$(echo $i | sed s/SR600/K2SR600/)
        cp -r $i $j
        sed -i "s/1  1  1/2  2  2/" $j/KPOINTS
        sed -i /KPAR/s/1/2/ $j/INCAR       
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
        subvSO -p32 -m3 -t72 -n2-4 -q short,long
        cd -
done

for i in K2SR600*CONF* ; do
        cd $i
        subv -p32 -m3 -t72 -n2-4 -q short,long,bigmem
        cd -
done


