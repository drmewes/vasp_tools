#!/usr/bin/python
import sys, re
import numpy as np
import matplotlib.pyplot as plt
import math

File  = 'vasprun.xml'
natoms = 0
mass = 0
todo = 0
isfree = 0
ismass = 0
xforce = 0
yforce = 0
zforce = 0
f_all = []
mdstep = 0
temp = 0

kB = 1.38065E-23
R = 8.3145
pi = 3.1416
h = 6.626E-34
eV2J = 1.6022E-19

def running_mean(x, N):
    cumsum = np.cumsum(np.insert(x, 0, 0)) 
    return (cumsum[N:] - cumsum[:-N]) / float(N)

#Get all the numbers from vasprun.xml file (connect multiple OUTCARs with cat!)
print "Working through vasprun.xml file to get simulation data..."
print ""
for line in open(File):
  if '<i name="TEBEG">' in line and temp == 0:
    pre_temp = line.split()[2]
    temp = float(pre_temp.split("<")[0])
    print "Found temperature to be", temp, "K"
  if "<atominfo>" in line and natoms == 0:
    isfree=1
  if "<atoms>" in line:
    if isfree > 0:
      natoms = int(line.split()[1])
      print "Found number of atoms to be ", natoms
      isfree -= 1
  if '<field type="string">pseudopotential</field>' in line and mass == 0:
    ismass = 3
  if ismass > 0:
    ismass -= 1
    if '<rc><c>' in line:
      pre_mass = line.split()[2]
      mass = float(pre_mass.split("<")[0])
      print "Found mass to be ", mass, "u"
      si_mass = mass/(6.023E26) #Atomic mass to SI units

print
print "Got simulation data, now getting forces..."      
for line in open(File):
  if '<varray name="forces" >' in line:
    todo = natoms
  if todo > 0 and "<v>" in line:
    todo -= 1
    xfor = float(line.split()[1])
    yfor = float(line.split()[2])
    zfor = float(line.split()[3])
    f_all.append(np.sqrt(xfor*xfor))
    f_all.append(np.sqrt(yfor*yfor))
    f_all.append(np.sqrt(zfor*zfor))
    xforce += np.sqrt(xfor*xfor)
    yforce += np.sqrt(yfor*yfor)
    zforce += np.sqrt(zfor*zfor)
    #print "Read forces for atom #", natoms-todo
    #print "xforce: ", xforce
    #print "yforce: ", yforce
    #print "zforce: ", zforce
    if todo == 0:
      mdstep += 1
      #print "MD Step # ", mdstep
print "Found forces for", mdstep, "steps... all done!"
print ""

#write forces to file for statistics
file = open('forces.txt', 'w')
for f in f_all:
  file.write("%s\n" % f)

av_xforce = xforce/mdstep/natoms
av_yforce = yforce/mdstep/natoms
av_zforce = zforce/mdstep/natoms
av_force = (av_xforce+av_yforce+av_zforce)/3
si_force = av_force*1.6022E-9 #Convert eV/A (VASP) to SI (J/m)
si_mw_force = si_force/(2*np.sqrt(si_mass)) #Mass-weighting

nu = np.sqrt((si_mw_force*si_mw_force)/(kB*temp))/(2*pi)
nu_in_eV = nu*4.1357E-15

S_qho = 3*kB*( ((h*nu)/(kB*temp))/(np.exp((h*nu)/(kB*temp))-1) - np.log(1-np.exp(-(h*nu)/(kB*temp))))
S_cho = 3*kB*(np.log((kB*temp)/(h*nu))+1)
Ncorr = float((3*natoms-6))/float((3*natoms))

print("Averaged forces (x,y,z) : %8.4f, %6.4f, %6.4f eV/A" % (av_xforce, av_yforce, av_zforce))
print("Spatially averaged force: %8.4f eV/A" % (av_force))
print("Mass weighted & SI units: %6.2f J/m/kg^(1/2)" % (si_mw_force))
print(" Corresponding frequency: %6.2f GHz" % (nu/1E9))
print(" Correction for # of DOF: %8.4f" % (Ncorr))

print ""
print "### ENTROPIES ###"
print "Quantum Harmonic Oscillator:"
print "Entropy per mole  [J/mole/K]", S_qho*6.023E23
print "Entropy per atom [eV/atom/K]", S_qho/eV2J
print "Total Entropy at T [eV/atom]", S_qho*temp/eV2J
print "Corrected for #DOF [eV/atom]", S_qho*temp/eV2J*Ncorr
print ""
print "Classical Harmonic Oscillator:"
#print "Entropy per atom [eV/atom/K]", -S_cho/eV2J
print "Total Entropy at T [eV/atom]", S_cho*temp/eV2J

