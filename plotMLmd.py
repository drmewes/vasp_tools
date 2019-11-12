#!/usr/bin/python
import sys, re
import numpy as np
import matplotlib.pyplot as plt

File  = 'OUTCAR'

steps = 0
nonMLsteps = 0
psum  = 0
tsum  = 0
Desum  = 0
MLesum = 0
lsum  = 0
p5sum  = 0
t5sum  = 0
MLe5sum  = 0
pmsum  = 0
tmsum  = 0
MLemsum  = 0
pall  = []
tall  = []
Deall  = [] #collects difference between ML-e and SCF-e
MLeall = []
SCFsteps = []
isfree = 0
isMLfree = 0
eSCF = 0 

def running_mean(x, N):
    cumsum = np.cumsum(np.insert(x, 0, 0)) 
    return (cumsum[N:] - cumsum[:-N]) / float(N)

#Get all the numbers from OUTCAR file (connect multiple OUTCARs with cat!)
print "Working through OUTCAR file..."
for line in open(File):
	if "total pressure" in line:
		p = float(line.split()[3])
		psum += p
		if steps > 500:
			p5sum += p
		#print steps
                if steps > 1000:
                        pmsum += p
                #print steps
		pall.append(p)
	if "(temperature " in line:
		t = float(line.split()[5])
		tsum += t
		if steps > 500:
			t5sum += t
                if steps > 1000:
                        tmsum += t
		tall.append(t)
	if "LOOP+" in line:
		l = 1 #float(line.split()[6])
		lsum += l
	if ("  Total+kin.  " in line) or ("   total drift:   " in line):
		isfree=13
	if "free  energy   TOTEN  =" in line:
		if isfree > 0:  
			eSCF = float(line.split()[4])
			nonMLsteps += 1
	isfree -= 1
        if "    OFIELD:  cpu time" in line:
                isMLfree=11
        if "free  energy   TOTEN  =" in line:
                if isMLfree > 0:
                        MLe = float(line.split()[4])
                        MLesum += MLe                        
			if steps > 500:
                                MLe5sum += MLe
                        if steps > 1000:
                                MLemsum += MLe
                        MLeall.append(MLe)
                        steps += 1
			if isfree > -55:
				Deall.append(MLe-eSCF)
                        	Desum += (MLe-eSCF)
				SCFsteps.append(steps)
        isMLfree -= 1

print "... all done!"

#Calculate averages and deviation
tave = tsum/steps		
pave = psum/nonMLsteps
Deave = Desum/nonMLsteps
MLeave = MLesum/steps
lave = lsum/steps

tvar = 0.0
pvar = 0.0
evar = 0.0
Devar = 0.0
MLevar = 0.0

for t in tall:
#	print t, tave
	tvar += np.square(t - tave)

for p in pall:
	pvar += np.square(p - pave)

for e in MLeall:
	MLevar += np.square(e - MLeave)

for e in Deall:
	Devar += np.square(e - Deave)

tvar = np.sqrt(tvar/steps)	
pvar = np.sqrt(pvar/nonMLsteps)	
Devar = np.sqrt(Devar/nonMLsteps)	
MLevar = np.sqrt(MLevar/nonMLsteps)

if steps > 600:
	t5ave = t5sum/(steps-500)		
	MLe5ave = MLe5sum/(steps-500)
if steps > 1100:
        tmave = tmsum/(steps-1000)
        MLemave = MLemsum/(steps-1000)

elast = tlast = 0 

#Running Average over N elements
if steps > 1099:
        N=steps/10
else:
        N=100

if steps > 200:
	tlast50 = tall[-N:] 
	elast50 = MLeall[-N:]
	for t in tlast50:
		tlast += t
	tlast /= N
	for e in elast50:
		elast += e
	elast /= N

#Print results to terminal
print ""
print "MD has done", steps, "steps, thereof", nonMLsteps, "with actual SCF calculation (nonML)."
print("Average time per SCF step %6.1f s, that is %5d steps per day." % (lave, 24*3600/lave))
print("Using running average of %4d (steps/10 but at least 100)" % (N))
print ""
print "Global averages and deviation:"
print("Average  E: %8.4f +- %4.2f eV" % (MLeave, MLevar))
print("Average dE: %8.4f +- %4.2f eV" % (Deave, Devar))
print("Average  p: %8.4f +- %4.2f kBar" % (pave, pvar))
print("Average  T: %6.2f   +- %3.1f  K" % (tave, tvar))
if steps > 600:
	print ""
	print "500+ steps averages and diff to global:"
	print("Average E: %8.4f (%+6.4f) eV" % (MLe5ave, MLe5ave-MLeave))
	print("Average T: %6.2f   (%+4.2f)   K" % (t5ave, t5ave-tave))
if steps > 1100:
        print ""
        print "1000+ steps averages and diff to global:"
        print("Average E: %8.4f (%+6.4f) eV" % (MLemave, MLemave-MLeave))
        print("Average T: %6.2f   (%+4.2f)   K" % (tmave, tmave-tave))
if steps > 200:
	print ""
	print "Latest averages (last ", N ," steps)"
	print("Average E: %8.4f " % (elast))
	print("Average T: %6.2f  K" % (tlast))
print ""
print "Steps with SCF calculation:", SCFsteps
#write the good stuff to files
file = open('pres.txt', 'w')
for p in pall:
	file.write("%s\n" % p)

file = open('ener.txt', 'w')
for e in MLeall:
	file.write("%s\n" % e)

file = open('temp.txt', 'w')
for t in tall:
	file.write("%s\n" % t)

#Throw in some nice plots	
plt.subplot(4,1,1)
plt.plot(MLeall,'r-',lw=1)
plt.plot(running_mean(MLeall, N),'b-',lw=2)
plt.ylabel('G /eV')

plt.subplot(4,1,2)
plt.plot(tall,'g-',lw=1)
plt.plot(running_mean(tall, N),'r-',lw=2)
plt.ylabel('T /K')
plt.xlabel('Step')

plt.subplot(4,1,3)
plt.plot(pall,'b-',lw=1)
plt.plot(running_mean(pall, N),'g-',lw=2)
plt.ylabel('p /kBar (SCF)')

plt.subplot(4,1,4)
plt.plot(Deall,'r-',lw=1)
plt.ylabel('dE(SCF-MLFF)')


plt.show()
		
