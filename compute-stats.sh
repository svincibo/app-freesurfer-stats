#!/bin/bash

freesurfer=`jq -r '.freesurfer' config.json`
parc=`jq -r '.parcellation' config.json`

# copy freesurfer directory
[ ! -d ./output/ ] && mkdir output && cp -R ${freesurfer}/* ./output/ && chmod -R +rw ./output

# copy parcellation
[ ! -d ./parc.nii.gz ] && cp ${parc} ./output/mri/parc.nii.gz && chmod +rw ./output/mri/parc.nii.gz

export SUBJECTS_DIR=./

# move parc into ribbon space
[ ! -f ./parc.nii.gz ] && mri_vol2vol --mov ./output/mri/parc.nii.gz --targ ./output/mri/ribbon.mgz --regheader --interp nearest --o ./output/mri/parc.nii.gz

# convert thickness to volume
[ ! -f ./thickness.nii.gz ] && mri_surf2vol --o ./thickness.nii.gz --subject output --so ./output/surf/lh.white ./output/surf/lh.thickness --so ./output/surf/rh.white ./output/surf/rh.thickness --ribbon ./output/mri/ribbon.mgz

# compute stats within parcellation
[ ! -f ./thickness.sum ] && mri_segstats --seg ./output/mri/parc.nii.gz --ctab ./lut.txt --i ./thickness.nii.gz --sum ./thickness.sum

# make stats file cleaner
[ ! -f ./thickness.txt ] && tail ./thickness.sum -n +54 > ./thickness.txt
[ ! -f ./thickness.csv ] && awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13}' ./thickness.txt > ./thickness_num.txt && sed 's/ *$//' ./thickness_num.txt > ./thickness_num_nospace.txt && sed 's/ \+/,/g' ./thickness_num_nospace.txt > ./thickness.csv

# error check
if [ ! -f ./thickness.csv ]; then
	echo "stats computation failed. check derivatives and error log"
	exit 1
fi

[ ! -f ./thickness_cols.txt ] && tail ./thickness.sum -n +53 > ./tmpdata.txt && head -n 1 ./tmpdata.txt > ./thickness_cols_spaces.txt && sed 's/ *$//' ./thickness_cols_spaces.txt > ./thickness_cols.txt