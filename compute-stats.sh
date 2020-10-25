#!/bin/bash

freesurfer=`jq -r '.freesurfer' config.json`
parc=`jq -r '.parcellation' config.json`
key=`jq -r '.key' config.json`
hemi="lh rh"

# copy freesurfer directory
[ ! -d ./output/ ] && mkdir output && cp -R ${freesurfer}/* ./output/ && chmod -R +rw ./output

# copy parcellation
[ ! -d ./parc.nii.gz ] && cp ${parc} ./parc.nii.gz && chmod +rw ./parc.nii.gz && parc="./parc.nii.gz"

export SUBJECTS_DIR=./

# convert ribbon
[ ! -f ./ribbon.nii.gz ] && mri_convert ./output/mri/ribbon.mgz ./ribbon.nii.gz

# move parc into ribbon space
[ ! -f ./parc.nii.gz ] && mri_vol2vol --mov ${parc} --targ ./ribbon.nii.gz --regheader --interp nearest --o ./parc.nii.gz

# create hemispheric annotation files (lut needs to be created first)
for HEMI in ${hemi}
do
	# create annotation file from parc volume
	[ ! -f ./${HEMI}.parc.annot ] && mris_sample_parc -ct ./lut.txt output ${HEMI} ./parc.nii.gz ./${HEMI}.parc.annot

	# compute stats
	[ ! -f ./${HEMI}.parc.stats ] && mris_anatomical_stats -a ./${HEMI}.parc.annot -f ./${HEMI}.parc.stats output ${HEMI}
done
