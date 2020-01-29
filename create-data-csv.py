#!/usr/bin/env python

import csv
import json
import numpy
import glob
import sys
import os
import pandas as pd

with open('config.json') as config_f:
    config = json.load(config_f)
    output_dir = config["freesurfer"]
    parc = config["parcellation"]

# left hemisphere
parc_l_verts = {}
parc_l_surf_area = {}
parc_l_gray_vol = {}
parc_l_thick = {}
parc_l_mean_curv = {}
parc_l_gaus_curv = {}
parc_l_fold_ind = {}
parc_l_curv_ind = {}

stat = open(output_dir+'/stats/lh.'+parc+'.stats')
for line in stat.readlines():
	if line[0] == "#":
		continue
	values = line.split()
	struct_name = values[0]  
	num_vert = int(values[1])
	surf_area = int(values[2])
	gray_vol = int(values[3])
	thick_avg = float(values[4])
	thick_std = float(values[5])
	mean_curv = float(values[6])
	gaus_curv = float(values[7])
	fold_ind = int(values[8])
	curv_ind = float(values[9])

	#print index, struct_name, n_voxels
	if not struct_name in parc_l_gray_vol:
		parc_l_verts[struct_name] = []
		parc_l_surf_area[struct_name] = []
		parc_l_gray_vol[struct_name] = []
		parc_l_thick[struct_name] = []
		parc_l_mean_curv[struct_name] = []
		parc_l_gaus_curv[struct_name] = []
		parc_l_fold_ind[struct_name] = []
		parc_l_curv_ind[struct_name] = []
		parc_l_verts[struct_name] = num_vert
		parc_l_surf_area[struct_name] = surf_area
		parc_l_gray_vol[struct_name] = gray_vol
		parc_l_thick[struct_name] = thick_avg
		parc_l_mean_curv[struct_name] = mean_curv
		parc_l_gaus_curv[struct_name] = gaus_curv
		parc_l_fold_ind[struct_name] = fold_ind
		parc_l_curv_ind[struct_name] = curv_ind

dl = {'col1': parc_l_verts.keys(),'col2': parc_l_verts.values(),'col3': parc_l_surf_area.values(),'col4': parc_l_gray_vol.values(),'col5': parc_l_thick.values(),'col6': parc_l_mean_curv.values(),'col7': parc_l_gaus_curv.values(),'col8': parc_l_fold_ind.values(),'col9': parc_l_curv_ind.values()}
dfl = pd.DataFrame(data=dl)
dfl = dfl.rename(columns={'col1': "label name",'col2': "number of vertices",'col3': "surface area",'col4': "volume",'col5': "cortical thickness",'col6': "mean curvature",'col7': "gaussian curvature",'col8': "fold index",'col9': "curvature index"})
dfl.to_csv('lh.'+parc+'.csv',index=False)

# right hemisphere
parc_r_verts = {}
parc_r_surf_area = {}
parc_r_gray_vol = {}
parc_r_thick = {}
parc_r_mean_curv = {}
parc_r_gaus_curv = {}
parc_r_fold_ind = {}
parc_r_curv_ind = {}

stat = open(output_dir+'/stats/rh.'+parc+'.stats')
for line in stat.readlines():
    if line[0] == "#":
        continue
    values = line.split()
    struct_name = values[0]  
    num_vert = int(values[1])
    surf_area = int(values[2])
    gray_vol = int(values[3])
    thick_avg = float(values[4])
    thick_std = float(values[5])
    mean_curv = float(values[6])
    gaus_curv = float(values[7])
    fold_ind = int(values[8])
    curv_ind = float(values[9])

    #print index, struct_name, n_voxels
    if not struct_name in parc_r_gray_vol:
    	parc_r_verts[struct_name] = []
    	parc_r_surf_area[struct_name] = []
    	parc_r_gray_vol[struct_name] = []
    	parc_r_thick[struct_name] = []
    	parc_r_mean_curv[struct_name] = []
    	parc_r_gaus_curv[struct_name] = []
    	parc_r_fold_ind[struct_name] = []
    	parc_r_curv_ind[struct_name] = []
    	parc_r_verts[struct_name] = num_vert
    	parc_r_surf_area[struct_name] = surf_area
    	parc_r_gray_vol[struct_name] = gray_vol
    	parc_r_thick[struct_name] = thick_avg
    	parc_r_mean_curv[struct_name] = mean_curv
    	parc_r_gaus_curv[struct_name] = gaus_curv
    	parc_r_fold_ind[struct_name] = fold_ind
    	parc_r_curv_ind[struct_name] = curv_ind

dr = {'col1': parc_r_verts.keys(),'col2': parc_r_verts.values(),'col3': parc_r_surf_area.values(),'col4': parc_r_gray_vol.values(),'col5': parc_r_thick.values(),'col6': parc_r_mean_curv.values(),'col7': parc_r_gaus_curv.values(),'col8': parc_r_fold_ind.values(),'col9': parc_r_curv_ind.values()}
dfr = pd.DataFrame(data=dl)
dfr = dfl.rename(columns={'col1': "label name",'col2': "number of vertices",'col3': "surface area",'col4': "volume",'col5': "cortical thickness",'col6': "mean curvature",'col7': "gaussian curvature",'col8': "fold index",'col9': "curvature index"})
dfr.to_csv('rh.'+parc+'.csv',index=False)