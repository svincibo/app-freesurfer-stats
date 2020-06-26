#!/bin/bash

#set -x
#set -e

export SUBJECTS_DIR='./'

#### parse inputs ####
freesurfer=`jq -r '.freesurfer' config.json`
ad=`jq -r '.ad' config.json`
fa=`jq -r '.fa' config.json`
md=`jq -r '.md' config.json`
rd=`jq -r '.rd' config.json`
ndi=`jq -r '.ndi' config.json`
isovf=`jq -r '.isovf' config.json`
odi=`jq -r '.odi' config.json`

#### parse whether dti and NODDI are included or not ####
echo "parsing input diffusion metrics"
if [[ $fa == "null" ]];
then
	METRIC="ndi isovf odi"
elif [[ $ndi == "null" ]]; then
	METRIC="ad fa md rd"
else
	METRIC="ad fa md rd ndi isovf odi"
fi
echo "input diffusion metrics set"

#### convert ribbon to nifti ####
[ ! -f ribbon.nii.gz ] && mri_convert ${freesurfer}/mri/ribbon.mgz ribbon.nii.gz

#### loop through metrics and generate stats text files ####
for MET in ${METRIC}
do
	metric=${MET}.nii.gz

	# put diffusion measures in ribbon space
	[ ! -f ${MET}_ribbon.nii.gz ] && mri_vol2vol --mov ${metric} --targ ribbon.nii.gz --regheader --o ${MET}_ribbon.nii.gz

	# generate stats file
	[ ! -f subcort.${MET}.sum ] && mri_segstats --seg ${freesurfer}/mri/aseg.mgz --i ${MET}_ribbon.nii.gz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --nonempty --exclude 0 --sum subcort.${MET}.sum

	# make stats file cleaner
	[ ! -f subcort.${MET}.txt ] && tail subcort.${MET}.sum -n +55 > subcort.${MET}.txt
	[ ! -f subcort_num.${MET}.csv ] && awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13}' subcort.${MET}.txt > subcort_num.${MET}.txt && sed 's/ *$//' subcort_num.${MET}.txt > subcort_num_nospace.${MET}.txt && sed 's/ \+/,/g' subcort_num_nospace.${MET}.txt > subcort_num.${MET}.csv
	
	# error check
	if [ ! -f subcort_num.${MET}.csv ]; then
		echo "stats computation failed. check derivatives and error log"
		exit 1
	fi
done

[ ! -f subcort_cols.txt ] && tail subcort.${MET}.sum -n +54 > tmpdata.txt && head -n 1 tmpdata.txt > subcort_cols_spaces.txt && sed 's/ *$//' subcort_cols_spaces.txt > subcort_cols.txt