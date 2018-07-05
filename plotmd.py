#!/usr/bin/python
import sys, re
import numpy as np
import matplotlib.pyplot as plt

File  = 'OUTCAR'

steps = 0
psum  = 0
tsum  = 0
esum  = 0
lsum  = 0
p5sum  = 0
t5sum  = 0
e5sum  = 0
pall  = []
tall  = []
eall  = []
isfree = 0

for line in open(File):
	if "total pressure" in line:
		p = float(line.split()[3])
		psum += p
		if steps > 500:
			p5sum += p
		#print steps
		pall.append(p)
	if "(temperature  " in line:
		t = float(line.split()[5])
		tsum += t
		if steps > 500:
			t5sum += t
		tall.append(t)
	if "LOOP+" in line:
		l = float(line.split()[6])
		lsum += l
	if "  FREE ENERGIE" in line:
		isfree=3
	if "free  energy   TOTEN  =" in line:
		if isfree > 0:
			e = float(line.split()[4])
			esum += e
			if steps > 500:
				e5sum += e
			eall.append(e)
			steps += 1
	isfree -= 1

tave = tsum/steps		
pave = psum/steps
eave = esum/steps
lave = lsum/steps

tvar = 0.0
pvar = 0.0
evar = 0.0

for t in tall:
#	print t, tave
	tvar += np.square(t - tave)

for p in pall:
	pvar += np.square(p - pave)

for e in eall:
	evar += np.square(e - eave)

tvar = np.sqrt(tvar/steps)	
pvar = np.sqrt(pvar/steps)	
evar = np.sqrt(evar/steps)	
	
if steps > 600:
	t5ave = t5sum/(steps-500)		
	p5ave = p5sum/(steps-500)
	e5ave = e5sum/(steps-500)

print ""
print "MD has done", steps, "steps."
print("Average time per SCF step %6.1f s" % (lave))
print ""
print "Global averages:"
print("Average E: %8.4f +- %4.2f eV" % (eave, evar))
print("Average p: %8.4f +- %4.2f kBar" % (pave, pvar))
print("Average T: %6.2f   +- %3.1f  K" % (tave, tvar))
if steps > 600:
	print ""
	print "500+ steps averages:"
	print("Average E: %8.4f eV" % (e5ave))
	print("Average p: %8.4f kBar" % (p5ave))
	print("Average T: %6.2f   K" % (t5ave))

plt.subplot(3,1,1)
plt.plot(eall,'r-',lw=1)

plt.ylabel('Free Energy /eV')

plt.subplot(3,1,2)
plt.plot(pall,'b-',lw=1)
plt.ylabel('Pressure /kBar')

plt.subplot(3,1,3)
plt.plot(tall,'g-',lw=1)
plt.ylabel('Temperature /K')
plt.xlabel('Step')

plt.show()
		
