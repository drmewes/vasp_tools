# The MIT License (MIT)
#
# Copyright (c) 2014 Muratahan Aykol
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE

import numpy as np

xdatcar = open('XDATCAR', 'r')
xyz = open('XDATCAR.xyz', 'w')
xyz_fract = open('XDATCAR_fract.xyz', 'w')


system = xdatcar.readline()
scale = float(xdatcar.readline().rstrip('\n'))
print scale

#get lattice vectors
a1 = np.array([ float(s)*scale for s in xdatcar.readline().rstrip('\n').split() ])
a2 = np.array([ float(s)*scale for s in xdatcar.readline().rstrip('\n').split() ])
a3 = np.array([ float(s)*scale for s in xdatcar.readline().rstrip('\n').split() ])

print a1
print a2
print a3

#Save scaled lattice vectors
lat_rec = open('lattice.vectors', 'w')
lat_rec.write(str(a1[0])+' '+str(a1[1])+' '+str(a1[2])+'\n')
lat_rec.write(str(a2[0])+' '+str(a2[1])+' '+str(a2[2])+'\n')
lat_rec.write(str(a3[0])+' '+str(a3[1])+' '+str(a3[2]))
lat_rec.close()


#Read xdatcar
element_names = xdatcar.readline().rstrip('\n').split()

element_dict = {}
element_numbers = xdatcar.readline().rstrip('\n').split()

i = 0
N = 0
for t in range(len(element_names)):
    element_dict[element_names[t]] = int(element_numbers[i])
    N += int(element_numbers[i])
    i += 1

print element_dict

while True:
    line = xdatcar.readline()
    if len(line) == 0:
        break
    xyz.write(str(N) + "\ncomment\n")
    xyz_fract.write(str(N)+"\ncomment\n")
    for el in element_names:
        for i in range(element_dict[el]):
            p = xdatcar.readline().rstrip('\n').split() 
            coords = np.array([ float(s) for s in p ])
#            print coords
            cartesian_coords = coords[0]*a1+coords[1]*a2+coords[2]*a3 
            xyz.write(el+ " " + str(cartesian_coords[0])+ " " + str(cartesian_coords[1]) + " " + str(cartesian_coords[2]) +"\n")
            xyz_fract.write(el+ " " + str(coords[0])+ " " + str(coords[1]) + " " + str(coords[2]) +"\n")
xdatcar.close()
xyz.close()
xyz_fract.close()

