#edit by lipai@mail.ustc.edu.cn
#get num of band
num=`grep NBANDS OUTCAR |awk '{print $NF}'`
E_fermi=`grep E-fermi OUTCAR | awk '{print $3}'`
grep "band No." OUTCAR -A $num >temp
echo "" >>temp
split -l 26 -d temp bands
for i in bands*; do sed -i '$d' $i;awk -v num=$i 'BEGIN{printf("%s\t",num)};{if(NR>1) printf("%f\t",$2)};END{printf("\n")}' $i >>band.dat; done
sed -i s/bands// band.dat
rm bands* temp
python < ~/bin/vasp_tools/plot_band.py band.dat $num $E_fermi

