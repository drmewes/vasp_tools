#!/usr/bin/env python3

import numpy as np
import os, sys
import argparse

desc=""
count = 0
diff = []
eabini = []
eharm = []
meandiff = 0
thisdiff = 0
diffh = 0

parser = argparse.ArgumentParser(description=desc,formatter_class=argparse.RawDescriptionHelpFormatter)


parser.add_argument("-s", "--startstep",
                        dest="startstep",
                        type=int,
                        action="store",
                        required=False) 

parser.add_argument("-e", "--endstep",
                        dest="esteps",
                        type=int,
                        action="store",
                        required=False) 

parser.add_argument("-a", "--atomnumber",
                        dest="atoms",
                        type=int,
                        action="store",
                        required=False) 

args=parser.parse_args()

if args.startstep is None:
    step0 = 500
else:
    step0 = args.startstep
 
if args.esteps is None:
    estep = 10000
else:
    estep = args.esteps
    
if args.atoms is None:
    natoms = 64
else:
    natoms = args.atoms
    
print("Startstep:", step0, " endstep:", estep, " Number of atoms:", natoms)

with open("OSZICAR", "r") as inp:
    for line in inp:
        if line.startswith(" E(ab-initio)"):
            count += 1
            if count >= step0 and count <= estep:
                eabini.append(float(line.split()[1]))
                eharm.append(float(line.split()[3]))

diff = [i/natoms-j/natoms for i,j in zip(eabini, eharm)]

meandiff = np.mean(diff)
print("Final average difference is", meandiff, "eV.")

with open("ener_diff_harm_init.txt", "w") as out:
    out.write("{}       {}        {}\n".format("E(abini)", "E(harm)", "E(diff)"))
    for i,j,k in zip(eabini, eharm, diff):
        out.write("{}   {}   {} \n".format(i, j, k))
