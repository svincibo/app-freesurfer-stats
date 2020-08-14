#!/bin/bash

set -x
set -e

export SUBJECTS_DIR='./'

#### parse inputs ####
freesurfer=`jq -r '.freesurfer' config.json`
ad=`jq -r '.ad' config.json`
fa=`jq -r '.fa' config.json`
md=`jq -r '.md' config.json`
rd=`jq -r '.rd' config.json`
ga=`jq -r '.ga' config.json`
ak=`jq -r '.ak' config.json`
mk=`jq -r '.mk' config.json`
rk=`jq -r '.rk' config.json`
ndi=`jq -r '.ndi' config.json`
isovf=`jq -r '.isovf' config.json`
odi=`jq -r '.odi' config.json`

tmpdir='./tmp'

[ ! -d ${tmpdir} ] && mkdir -p ${tmpdir}

#### parse whether dti and NODDI are included or not ####
echo "parsing input diffusion metrics"
if [[ $fa == "null" ]];
then
	METRIC="ndi isovf odi"
elif [[ $ndi == "null" ]] && [[ $ga == "null" ]]; then
	METRIC="ad fa md rd"
elif [[ $ndi == "null" ]] && [[ ! $ga == "null" ]]; then
	METRIC="ad fa md rd ga ak mk rk"
elif [[ ! $fa == "null" ]] && [[ ! $ndi == "null" ]] && [[ $ga == "null" ]]; then
	METRIC="ad fa md rd ndi isovf odi"
else
	METRIC="ad fa md rd ga ak mk rk ndi isovf odi"
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
	[ ! -f ${tmpdir}/subcort.${MET}.sum ] && mri_segstats --seg ${freesurfer}/mri/aseg.mgz --i ${MET}_ribbon.nii.gz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --nonempty --exclude 0 --sum ${tmpdir}/subcort.${MET}.sum

	# make stats file cleaner
	[ ! -f ${tmpdir}/subcort.${MET}.txt ] && tail ${tmpdir}/subcort.${MET}.sum -n +55 > ${tmpdir}/subcort.${MET}.txt
	[ ! -f ${tmpdir}/subcort_num.${MET}.csv ] && awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13}' ${tmpdir}/subcort.${MET}.txt > ${tmpdir}/subcort_num.${MET}.txt && sed 's/ *$//' ${tmpdir}/subcort_num.${MET}.txt > ${tmpdir}/subcort_num_nospace.${MET}.txt && sed 's/ \+/,/g' ${tmpdir}/subcort_num_nospace.${MET}.txt > ${tmpdir}/subcort_num.${MET}.csv
	
	# error check
	if [ ! -f ${tmpdir}/subcort_num.${MET}.csv ]; then
		echo "stats computation failed. check derivatives and error log"
		exit 1
	fi
done

[ ! -f ${tmpdir}/subcort_cols.txt ] && tail ${tmpdir}/subcort.${MET}.sum -n +54 > ${tmpdir}/tmpdata.txt && head -n 1 ${tmpdir}/tmpdata.txt > ${tmpdir}/subcort_cols_spaces.txt && sed 's/ *$//' ${tmpdir}/subcort_cols_spaces.txt > ${tmpdir}/subcort_cols.txt
