#!/bin/bash

if [ $# -eq 0 ]
  then
    tag='latest'
    ver='r2022b'
  else
    tag=$1
    ver=$tag
fi

# We don't use the base image here for now
# OPTIONS=""
# OPTIONS+="--network host "
# OPTIONS+="-t roahm/matlab-base:$tag "
# OPTIONS+="-t roahm/matlab-base:$ver "
# OPTIONS+="--build-arg MATLAB_RELEASE=$ver "
# if [ -z "$MLM_LICENSE_FILE" ];then
#     MLM_LICENSE_FILE=`cat license-server.txt`
# fi
# if [[ ! -z "$MLM_LICENSE_FILE" ]];then
#     OPTIONS+="--build-arg LICENSE_SERVER=$MLM_LICENSE_FILE "
# fi
# OPTIONS+="-f Dockerfile.base "
# echo $OPTIONS

# # Create the base image
# docker build $OPTIONS .


# Create an all image
# Don't do this on the pinocchio build
# OPTIONS=""
# OPTIONS+="--network host "
# OPTIONS+="-t roahm/matlab-all:$tag "
# OPTIONS+="-t roahm/matlab-all:$ver "
# OPTIONS+="--build-arg MATLAB_RELEASE=$ver "
# #OPTIONS+="--build-arg BASE_IMAGE=roahm/matlab-base "
# OPTIONS+="--build-arg BASE_IMAGE=mathworks/matlab-deps "
# if [ -z "$MLM_LICENSE_FILE" ];then
#     MLM_LICENSE_FILE=`cat license-server.txt`
# fi
# if [[ ! -z "$MLM_LICENSE_FILE" ]];then
#     OPTIONS+="--build-arg LICENSE_SERVER=$MLM_LICENSE_FILE "
# fi
# OPTIONS+="-f Dockerfile.all "
# echo $OPTIONS

# docker build $OPTIONS .


# Create the pinnochio image
OPTIONS=""
OPTIONS+="--network host "
OPTIONS+="-t roahm/matlab-pinocchio:$tag "
OPTIONS+="-t roahm/matlab-pinocchio:$ver "
OPTIONS+="--build-arg MATLAB_RELEASE=$ver "
#OPTIONS+="--build-arg BASE_IMAGE=roahm/matlab-base "
OPTIONS+="--build-arg BASE_IMAGE=roahm/matlab-all "
if [ -z "$MLM_LICENSE_FILE" ];then
    MLM_LICENSE_FILE=`cat license-server.txt`
fi
if [[ ! -z "$MLM_LICENSE_FILE" ]];then
    OPTIONS+="--build-arg LICENSE_SERVER=$MLM_LICENSE_FILE "
fi
OPTIONS+="-f Dockerfile.pinocchio "
echo $OPTIONS

docker build $OPTIONS .
