#!/bin/bash

freesurfer=`jq -r '.freesurfer' config.json`
ad=`jq -r '.ad' config.json`
fa=`jq -r '.fa' config.json`
md=`jq -r '.md' config.json`
rd=`jq -r '.rd' config.json`
ndi=`jq -r '.ndi' config.json`
isovf=`jq -r '.isovf' config.json`
odi=`jq -r '.odi' config.json`

# parse whether dti and NODDI are included or not
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

mri_convert ${freesurfer}/mri/ribbon.mgz ribbon.nii.gz

for MET in ${METRIC}
do
	metric=$(eval "echo \$${MET}")
	mri_vol2vol --mov ${metric} --targ ribbon.nii.gz --regheader --o ${MET}_ribbon.nii.gz

	mri_segstats --seg ${freesurfer}/mri/aseg.mgz --i ${MET}_ribbon.nii.gz --ctab $FREESURFER_HOME/FreesurferColorLUT.txt --nonempty --exclude 0 --sum subcort.${MET}.sum

	tail stats/subcort.${METRICS}.sum -n +55 > subcort.${METRICS}.txt
	awk '{print $2,$3,$6,$7,$8,$9,$10}' subcort.${METRICS}.txt > label/$METRICS/subcort_num.${METRICS}.txt;
done
