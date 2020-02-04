FROM ubuntu:18.04

MAINTAINER Brad Caron <bacaron@iu.edu>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y python3 python3-numpy python3-pip jq

## install pandas and freesurfer-stats
RUN pip3 install pandas
RUN pip3 install --user freesurfer-stats
 
#make it work under singularity 
RUN ldconfig && mkdir -p /N/u /N/home /N/dc2 /N/soft

#https://wiki.ubuntu.com/DashAsBinSh 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
