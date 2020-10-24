#!/usr/bin/env python3

import json
import pandas as pd
import numpy as np

def createColorLUT(keyfile,outfile):
	
	# load key.txt file from parcellation datatype
	df = pd.read_csv(keyfile,delimiter='\t',header=None)

	# extract relevant data
	df = df[[2,3]]

	# rename the columns to freesurfer format
	df = df.rename(columns={2: '#No.',3: 'Label Name:'})

	# reformat label names to remove unnecessary spaces and equal signs
	df['Label Name:'] = [ f.split('== ')[1].split(' ')[0] for f in df['Label Name:'] ]

	# generate red, green, blue and alpha values
	df['R'] = [np.random.random_integers(0,255,size=1).tolist()[0] for f in range(len(df['#No.']))]
	df['G'] = [np.random.random_integers(0,255,size=1).tolist()[0] for f in range(len(df['#No.']))]
	df['B'] = [np.random.random_integers(0,255,size=1).tolist()[0] for f in range(len(df['#No.']))]
	df['A'] = [0 for f in range(len(df['#No.']))]

	# write out colorlut file
	df.to_csv(outfile,sep='\t',index=False)

def main():

	# load config
	with open('config.json','r') as config_f:
		config = json.load(config_f)

	# parcellation key file
	keyfile = config['key']

	# outfile for color lut
	outfile = 'lut.txt'

	# create color lut
	createColorLUT(keyfile,outfile)

if __name__ == '__main__':
	main()
