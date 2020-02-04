#!/usr/bin/env python3

import csv
import json
import numpy
import glob
import sys
import os
import pandas as pd
from freesurfer_stats import CorticalParcellationStats

def extract_wm_stats(input_data_lines):
    lines_var = input_data_lines.readlines()
    lh = lines_var[14]
    lh = lh.replace(',','')
    rh = lines_var[15]
    rh = rh.replace(',','')
    tot = lines_var[16]
    tot = tot.replace(',','')
    lh_wm_vol = float(lh.split()[10])
    rh_wm_vol = float(rh.split()[10])
    tot_wm_vol = float(tot.split()[9])

    return [lh_wm_vol,rh_wm_vol,tot_wm_vol]


with open('config.json') as config_f:
    config = json.load(config_f)
    output_dir = config["freesurfer"]
    parc = config["parcellation"]

# left hemisphere
lh_stats = CorticalParcellationStats.read(output_dir+'/stats/lh.'+parc+'.stats')
dfl = lh_stats.structural_measurements
dfl.to_csv('lh.cortex.csv')

# right hemisphere
rh_stats = CorticalParcellationStats.read(output_dir+'/stats/rh.'+parc+'.stats')
dfr = rh_stats.structural_measurements
dfr.to_csv('rh.cortex.csv')

# whole brain
white_matter_stats = open(output_dir+'/stats/wmparc.stats')
[lh_wm_vol,rh_wm_vol,tot_wm_vol] = extract_wm_stats(white_matter_stats)

whole_brain = lh_stats.whole_brain_measurements[['brain_segmentation_volume_mm^3','estimated_total_intracranial_volume_mm^3']]
whole_brain = whole_brain.rename(columns={"brain_segmentation_volume_mm^3": "Total Brain Volume", "estimated_total_intracranial_volume_mm^3": "Total Intracranial Volume"})
whole_brain.insert(2,"Total Cortical Gray Matter Volume",lh_stats.whole_brain_measurements['total_cortical_gray_matter_volume_mm^3'],True)
whole_brain.insert(3,"Total White Matter Volume",tot_wm_vol,True)
whole_brain.insert(4,"Left Hemisphere Cortical Gray Matter Volume",numpy.sum(lh_stats.structural_measurements['gray_matter_volume_mm^3']),True)
whole_brain.insert(5,"Right Hemisphere Cortical Gray Matter Volume",numpy.sum(rh_stats.structural_measurements['gray_matter_volume_mm^3']),True)
whole_brain.insert(6,"Left Hemisphere White Matter Volume",lh_wm_vol,True)
whole_brain.insert(7,"Right Hemisphere White Matter Volume",rh_wm_vol,True)
whole_brain.insert(8,"Left Hemisphere Mean Cortical Gray Matter Thickness",lh_stats.whole_brain_measurements['mean_thickness_mm'],True)
whole_brain.insert(9,"Right Hemisphere Mean Cortical Gray Matter Thickness",rh_stats.whole_brain_measurements['mean_thickness_mm'],True)

whole_brain.to_csv('whole_brain.csv')
