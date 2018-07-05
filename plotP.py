#!/usr/bin/python
import sys, re
import numpy as np
import matplotlib.pyplot as plt

File  = 'OUTCAR'

steps = 0
psum  = 0
pall  = []

for line in open(File):
	if "total pressure" in line:
		p = float(line.split()[3])
		psum += p
		print steps
		pall.append(p)
		steps += 1

pave = psum/steps

print pave 

plt.plot(pall,lw=2)
plt.xlabel('Step')
plt.ylabel('Pressure [kBar]')
plt.show()
		
