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

def running_mean(x, N):
    cumsum = np.cumsum(np.insert(x, 0, 0)) 
    return (cumsum[N:] - cumsum[:-N]) / float(N)

#Get all the numbers from OUTCAR file (connect multiple OUTCARs with cat!)
print "Working though OUTCAR file..."
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
print "... all done!"

#Calculate averages and deviation
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

elast = plast = tlast = 0 

if steps > 100:
	tlast50 = tall[-50:] 
	plast50 = pall[-50:]
	elast50 = eall[-50:]
	for p in plast50:
		plast += p
	plast /= 50
	for t in tlast50:
		tlast += t
	tlast /= 50
	for e in elast50:
		elast += e
	elast /= 50

#Running Average over N elements
if steps > 800:
	N=steps/20
else:
	N=50

#Print results to terminal
print ""
print "MD has done", steps, "steps."
print("Average time per SCF step %6.1f s" % (lave))
print("Using running average of %4d (steps/20 but at least 50)" % (N))
print ""
print "Global averages and deviation:"
print("Average E: %8.4f +- %4.2f eV" % (eave, evar))
print("Average p: %8.4f +- %4.2f kBar" % (pave, pvar))
print("Average T: %6.2f   +- %3.1f  K" % (tave, tvar))
if steps > 600:
	print ""
	print "500+ steps averages and diff to global:"
	print("Average E: %8.4f (%+6.4f) eV" % (e5ave, e5ave-eave))
	print("Average p: %8.4f (%+6.4f) kBar" % (p5ave, p5ave-pave))
	print("Average T: %6.2f   (%+4.2f)   K" % (t5ave, t5ave-tave))
if steps > 100:
	print ""
	print "Latest averages (last 50 steps)"
	print("Average E: %8.4f " % (elast))
	print("Average p: %8.4f " % (plast))
	print("Average T: %6.2f  K" % (tlast))


#write the good stuff to files
file = open('pres.txt', 'w')
for p in pall:
	file.write("%s\n" % p)

file = open('ener.txt', 'w')
for e in eall:
	file.write("%s\n" % e)

file = open('temp.txt', 'w')
for t in tall:
	file.write("%s\n" % t)

#Throw in some nice plots	
plt.subplot(3,1,1)
plt.plot(eall,'r-',lw=1)
plt.plot(running_mean(eall, N),'b-',lw=2)
plt.ylabel('Free Energy /eV')

plt.subplot(3,1,2)
plt.plot(pall,'b-',lw=1)
plt.plot(running_mean(pall, N),'r-',lw=2)
plt.ylabel('Pressure /kBar')

plt.subplot(3,1,3)
plt.plot(tall,'g-',lw=1)
plt.plot(running_mean(tall, N),'b-',lw=2)
plt.ylabel('Temperature /K')
plt.xlabel('Step')

plt.show()
		
