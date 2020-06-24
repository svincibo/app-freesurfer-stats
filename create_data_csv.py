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
    lh = lines_var[lines_var.index([ f for f in lines_var if 'lhCerebralWhiteMatter' in f ][0])]
    lh = lh.replace(',','')
    rh = lines_var[lines_var.index([ f for f in lines_var if 'rhCerebralWhiteMatter' in f ][0])]
    rh = rh.replace(',','')
    tot = lines_var[lines_var.index([ f for f in lines_var if 'Total cerebral white matter volume' in f ][0])]
    tot = tot.replace(',','')
    lh_wm_vol = float(lh.split()[10])
    rh_wm_vol = float(rh.split()[10])
    tot_wm_vol = float(tot.split()[9])

    return [lh_wm_vol,rh_wm_vol,tot_wm_vol]


def main():
    with open('config.json') as config_f:
        config = json.load(config_f)
        output_dir = config["freesurfer"]
        parc = config["parcellation"]
        subjectID = config['_inputs'][0]['meta']['subject']

    # left hemisphere
    lh_stats = CorticalParcellationStats.read(output_dir+'/stats/lh.'+parc+'.stats')
    dfl = lh_stats.structural_measurements
    dfl.rename(columns={'structure_name': 'structureID','Unnamed: 0': 'parcID'},inplace=True)
    dfl['structureID'] = [ 'lh_'+dfl['structureID'][f] for f in range(len(dfl['structureID'])) ]
    dfl['subjectID'] = [ subjectID for x in range(len(dfl['structureID'])) ]
    dfl['parcID'] = dfl['parcID'] + 1
    dfl['nodeID'] = [ int(1) for f in range(len(dfl['structureID'])) ]
    dfl = dfl.reindex(columns=['parcID','subjectID','structureID','nodeID','number_of_vertices', 'surface_area_mm^2','gray_matter_volume_mm^3', 'average_thickness_mm','thickness_stddev_mm', 'integrated_rectified_mean_curvature_mm^-1','integrated_rectified_gaussian_curvature_mm^-2', 'folding_index','intrinsic_curvature_index'])
    dfl.to_csv('lh.cortex.csv',index=False)

    # right hemisphere
    rh_stats = CorticalParcellationStats.read(output_dir+'/stats/rh.'+parc+'.stats')
    dfr = rh_stats.structural_measurements
    dfr.rename(columns={'structure_name': 'structureID','Unnamed: 0': 'parcID'},inplace=True)
    dfr['structureID'] = [ 'rh_'+dfr['structureID'][f] for f in range(len(dfr['structureID'])) ]
    dfr['subjectID'] = [ subjectID for x in range(len(dfr['structureID'])) ]
    dfr['parcID'] = dfr['parcID'] + 1
    dfr['nodeID'] = [ int(1) for f in range(len(dfr['structureID'])) ]
    dfr = dfr.reindex(columns=['parcID','subjectID','structureID','nodeID','number_of_vertices', 'surface_area_mm^2','gray_matter_volume_mm^3', 'average_thickness_mm','thickness_stddev_mm', 'integrated_rectified_mean_curvature_mm^-1','integrated_rectified_gaussian_curvature_mm^-2', 'folding_index','intrinsic_curvature_index'])
    dfr.to_csv('rh.cortex.csv',index=False)

    # concat left and righ hemispheres
    dft = pd.concat([dfl,dfr],ignore_index=True)
    dft.to_csv('cortex.csv')
    
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

    whole_brain.to_csv('whole_brain.csv',index=False)
