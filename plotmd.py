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
pmsum  = 0
tmsum  = 0
emsum  = 0
p2msum  = 0
t2msum  = 0
e2msum  = 0
p4msum  = 0
t4msum  = 0
e4msum  = 0
pall  = []
tall  = []
eall  = []
isfree = 0
avesteps1 = 1000
avesteps2 = 2000
avesteps3 = 4000 

def running_mean(x, N):
    cumsum = np.cumsum(np.insert(x, 0, 0)) 
    return (cumsum[N:] - cumsum[:-N]) / float(N)

if len(sys.argv) > 1 :
        print 'Using custom averages after', int(sys.argv[1]),',', int(sys.argv[1])/2, 'and', int(sys.argv[1])/4, 'steps.'
        avesteps3 = int(sys.argv[1])
	avesteps2 = int(avesteps3/2)
	avesteps1 = int(avesteps3/4)	
else:
        print "Using default averages after 1000, 2000 and 4000 steps."

avesteps1p = avesteps1+100
avesteps2p = avesteps2+100
avesteps3p = avesteps2+100     

#Get all the numbers from OUTCAR file (connect multiple OUTCARs with cat!)
print "Working through OUTCAR file..."
for line in open(File):
	if "total pressure" in line:
		p = float(line.split()[3])
		psum += p
		if steps > avesteps1:
			pmsum += p
		#print steps
                if steps > avesteps2:
                        p2msum += p
                if steps > avesteps3:
                        p4msum += p
                #print steps
		pall.append(p)
	if "(temperature " in line:
		t = float(line.split()[5])
		tsum += t
		if steps > avesteps1:
			tmsum += t
                if steps > avesteps2:
                        t2msum += t
                if steps > avesteps3:
                        t4msum += t
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
			if steps > avesteps1:
				emsum += e
                        if steps > avesteps2:
                                e2msum += e
                        if steps > avesteps3:
                                e4msum += e
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
	
if steps > avesteps1p:
	tmave = tmsum/(steps-avesteps1)		
	pmave = pmsum/(steps-avesteps1)
	emave = emsum/(steps-avesteps1)
if steps > avesteps2p:
        t2mave = t2msum/(steps-avesteps2)
        p2mave = p2msum/(steps-avesteps2)
        e2mave = e2msum/(steps-avesteps2)
if steps > avesteps3p:
        t4mave = t4msum/(steps-avesteps3)
        p4mave = p4msum/(steps-avesteps3)
        e4mave = e4msum/(steps-avesteps3)

elast = plast = tlast = 0 

#Running Average over N elements
if steps > 1099:
        N=steps/10
else:
        N=100

if steps > 200:
	tlast50 = tall[-N:] 
	plast50 = pall[-N:]
	elast50 = eall[-N:]
	for p in plast50:
		plast += p
	plast /= N
	for t in tlast50:
		tlast += t
	tlast /= N
	for e in elast50:
		elast += e
	elast /= N

#Print results to terminal
print ""
print "MD has done", steps, "steps."
print("Average time per SCF step %6.1f s, that is %5d steps per day." % (lave, 24*3600/lave))
print("Using running average of %4d (steps/10 but at least 100)" % (N))
print ""
print "Global averages and deviation:"
print("Average E: %8.4f +- %4.2f eV" % (eave, evar))
print("Average p: %8.4f +- %4.2f kBar" % (pave, pvar))
print("Average T: %6.2f   +- %3.1f  K" % (tave, tvar))
if steps > avesteps1p:
	print ""
	print avesteps1, "steps averages and diff to global:"
	print("Average E: %8.4f (%+6.4f) eV" % (emave, emave-eave))
	print("Average p: %8.4f (%+6.4f) kBar" % (pmave, pmave-pave))
	print("Average T: %6.2f   (%+4.2f)   K" % (tmave, tmave-tave))
if steps > avesteps2p:
        print ""
        print avesteps2, "steps averages and diff to global:"
        print("Average E: %8.4f (%+6.4f) eV" % (e2mave, e2mave-eave))
        print("Average p: %8.4f (%+6.4f) kBar" % (p2mave, p2mave-pave))
        print("Average T: %6.2f   (%+4.2f)   K" % (t2mave, t2mave-tave))
if steps > avesteps3p:
        print ""
        print avesteps3, "steps averages and diff to global:"
        print("Average E: %8.4f (%+6.4f) eV" % (e4mave, e4mave-eave))
        print("Average p: %8.4f (%+6.4f) kBar" % (p4mave, p4mave-pave))
        print("Average T: %6.2f   (%+4.2f)   K" % (t4mave, t4mave-tave))
if steps > 200:
	print ""
	print "Latest averages (last ", N ," steps)"
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

