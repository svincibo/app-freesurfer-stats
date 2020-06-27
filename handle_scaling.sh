#!/bin/bash

set -x
set -e

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

#### loop through metrics and generate stats text files ####
for MET in ${METRIC}
do
	if [ ! -f ${MET}.nii.gz ]; then
		metric=$(eval "echo \$${MET}")

		# handle scaling issues
		median_val=$(eval "fslstats ${metric} -P 50")
		if [[ $median_val < 0.01 ]]; then 
			fslmaths ${metric} -mul 1000 ./${MET}.nii.gz
			metric="./${MET}.nii.gz"
		else
			cp ${metric} ./
		fi
	fi
done