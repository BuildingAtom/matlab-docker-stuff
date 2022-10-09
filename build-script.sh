#!/bin/bash

if [ $# -eq 0 ]
  then
    tag='latest'
    ver='r2022b'
  else
    tag=$1
    ver=$tag
fi

if [ -z "$MLM_LICENSE_FILE" ];then
    MLM_LICENSE_FILE=`cat license-server.txt`
fi

# Create the base image
docker build                                       \
    --network host                                 \
    -t roahm/matlab-base:$tag                      \
    --build-arg MATLAB_RELEASE=$ver                \
    --build-arg MLM_LICENSE_FILE=$MLM_LICENSE_FILE \
    -f Dockerfile.base .

