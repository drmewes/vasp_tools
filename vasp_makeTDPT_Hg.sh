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

cp ~/bin/vasp_tools/Hg/POTCAR ~/bin/vasp_tools/Hg/INCAR ~/bin/vasp_tools/Hg/KPOINTS SHIFT/

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
	sed -i /EDIFF/s/06/04/ $j/INCAR
	sed -i /PREC/s/accurate/normal/ $j/INCAR
done 

for i in SR500_CONF* ; do 
	j=$(echo $i | sed s/SR500/K3SR500/)
	cp -r $i $j 
	sed -i "s/2  2  2/3  3  3/" $j/KPOINTS 
done 

for i in SR500_CONF* ; do
        j=$(echo $i | sed s/SR500/K4SR500/)
        cp -r $i $j
        sed -i "s/2  2  2/4  4  4/" $j/KPOINTS
done

for i in SR500_CONF* ; do
        j=$(echo $i | sed s/SR500/K5SR500/)
        cp -r $i $j
        sed -i "s/2  2  2/5  5  5/" $j/KPOINTS
done

for i in SR500_CONF* ; do
        j=$(echo $i | sed s/SR500/SO500/)
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

for i in K3SR* ; do
        cd $i
        subvMAUI -p160 -m1 -t12 -n2 -q nesi_research
        cd -
done

