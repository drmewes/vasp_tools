#!/usr/bin/python
import sys
import numpy as np
import matplotlib.pyplot as plt

Bsize = 0
File  = 'ener.txt'

if len(sys.argv) > 1 :
	print 'Using max Blocksize: ', sys.argv[1]
	Bsize = int(sys.argv[1])
else:
	print "Using default max Blocksize (Steps/10)"
	

fdata = []

with open(File) as f:
        for line in f:
                data=float(line)
                fdata.append(data)

#blockAverage magic ensues
def blockAverage(datastream, isplot=True, maxBlockSize=0):
    	import numpy as np
	import matplotlib.pyplot as plt

	"""This program computes the block average of a potentially correlated timeseries "x", and 
	provides error bounds for the estimated mean <x>. 
	As input provide a vector or timeseries "x", and the largest block size.
	
	Check out writeup in the following blog posts for more:
	http://sachinashanbhag.blogspot.com/2013/08/block-averaging-estimating-uncertainty_14.html
	http://sachinashanbhag.blogspot.com/2013/08/block-averaging-estimating-uncertainty.html
	"""
 
	Nobs         = len(datastream)           # total number of observations in datastream
	minBlockSize = 1;                        # min: 1 observation/block
 
	if maxBlockSize == 0:
		maxBlockSize = int(Nobs/10);        # max: 4 blocs (otherwise can't calc variance)
  
	NumBlocks = maxBlockSize - minBlockSize   # total number of block sizes

	blockMean = np.zeros(NumBlocks)               # mean (expect to be "nearly" constant)
	blockVar  = np.zeros(NumBlocks)               # variance associated with each blockSize
	blockCtr  = 0
	
				#
				#  blockSize is # observations/block
				#  run them through all the possibilities
				#
 
	for blockSize in range(minBlockSize, maxBlockSize):

		Nblock    = int(Nobs/blockSize)               # total number of such blocks in datastream
		obsProp   = np.zeros(Nblock)                  # container for parcelling block 

		# Loop to chop datastream into blocks
		# and take average
		for i in range(1,Nblock+1):
			
			ibeg = (i-1) * blockSize
			iend =  ibeg + blockSize
			obsProp[i-1] = np.mean(datastream[ibeg:iend])

		blockMean[blockCtr] = np.mean(obsProp)
		blockVar[blockCtr]  = np.var(obsProp)/(Nblock - 1)
		blockCtr += 1
 
	v = np.arange(minBlockSize,maxBlockSize)
 
	if isplot:

		plt.subplot(2,1,1)
		plt.plot(v, np.sqrt(blockVar),'ro-',lw=2)
		plt.xlabel('block size')
		plt.ylabel('std')

		plt.subplot(2,1,2)
		plt.errorbar(v, blockMean, np.sqrt(blockVar))
		plt.ylabel('<x>')
		plt.xlabel('block size')

		print "<x> = {0:f} +/- {1:f}\n".format(blockMean[-1], np.sqrt(blockVar[-1]))

		plt.show()
		
	return v, blockVar, blockMean

blockAverage(fdata, 1, Bsize)



