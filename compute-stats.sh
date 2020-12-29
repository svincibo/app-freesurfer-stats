#!/bin/bash

freesurfer=`jq -r '.freesurfer' config.json`
lh_annot=`jq -r '.lh_annot' config.json`
rh_annot=`jq -r '.rh_annot' config.json`
key=`jq -r '.key' config.json`
hemi="lh rh"

# copy freesurfer directory
[ ! -d ./output/ ] && mkdir output && cp -R ${freesurfer}/* ./output/ && chmod -R +rw ./output

# export subjects_dir to pwd
export SUBJECTS_DIR=./

# loop through hemisphere annotations and convert to usable gii and compute stats
for HEMI in ${hemi}
do
	echo "converting files for ${HEMI}"
	parc=$(eval "echo \$${HEMI}_annot")
	pial="./output/surf/${HEMI}.pial"

	# convert surface parcellations that came from multi atlas transfer tool
	#### convert annotation files to useable label giftis ####
	[ ! -f ${HEMI}.parc.annot ] && mris_convert --annot ${parc} \
		${pial} \
		./${HEMI}.parc.annot

	#### compute stats with mris_anatomical_stats ####
	[ ! -f ${HEMI}.parc.stats ] && mris_anatomical_stats -th3 \
		-mgz \
		-b \
		-a ./${HEMI}.parc.annot \
		-f ./${HEMI}.parc.stats \
		-c ./lut.txt \
		output \
		${HEMI} \
		white
done