#!/usr/bin/env bash


## Configuration for script vars
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MOUNT_DIR=$SCRIPT_DIR
STARTING_DIR=$SCRIPT_DIR
NAME="matlab"
USE_UNIQUE=true
ADD_UNAME=true
#IMAGE="mathworks/matlab:r2022b"
IMAGE="roahm/matlab-pinocchio:r2022b"
if [ -z "$MLM_LICENSE_FILE" ];then
    MLM_LICENSE_FILE=`cat license-server.txt`
fi
if $USE_UNIQUE;then
    NAME+="-$(cat /proc/sys/kernel/random/uuid)"
fi
if $ADD_UNAME;then
    NAME="$(id -un)-$NAME"
fi

## Setup uid requirements and workdir for temporaries
if [ -z "$HOME" ];then
    HOME=/tmp
fi
if [ -z "$ID" ];then
    ID=$(id -u)
fi
WORKDIR="$HOME/.docker"
mkdir -p "$WORKDIR"
getent passwd $(id -u) > "$WORKDIR/.$ID.passwd"
getent group $(id --groups) > "$WORKDIR/.$ID.group"

## Prep for GUI
XSOCK=/tmp/.X11-unix
XAUTH=$WORKDIR/.$ID.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

## GPU Capabilities
# Base
CAPABILITIES+="compute,utility"
# Display
CAPABILITIES+=",graphics,display"
# Video
CAPABILITIES+=",video"
# Combine
CAPABILITIES_STR=\""capabilities=$CAPABILITIES\""

## For MATLAB Preferences
MATLAB_PREF=$HOME/.matlab
mkdir -p $MATLAB_PREF

## Build out the Docker options
DOCKER_OPTIONS=""
DOCKER_OPTIONS+="-it "
DOCKER_OPTIONS+="--rm "
DOCKER_OPTIONS+="--shm-size=512M "

## USER ACCOUNT STUFF
DOCKER_OPTIONS+="--user $(id -u):$(id -g) "
DOCKER_OPTIONS+="$(id --groups | sed 's/\(\b\w\)/--group-add \1/g') "
# extrausers trick doesn't work here'
DOCKER_OPTIONS+="-v $WORKDIR/.$ID.passwd:/etc/passwd:ro "
DOCKER_OPTIONS+="-v $WORKDIR/.$ID.group:/etc/group:ro "

## GUI STUFF
DOCKER_OPTIONS+="-e DISPLAY=$DISPLAY "
DOCKER_OPTIONS+="-v $XSOCK:$XSOCK "
DOCKER_OPTIONS+="-v $XAUTH:/tmp/docker.xauth "
DOCKER_OPTIONS+="-e XAUTHORITY=/tmp/docker.xauth "
DOCKER_OPTIONS+="-e SDL_VIDEODRIVER=x11 "
# for generic graphics acceleration. comment out if having issues
DOCKER_OPTIONS+="--device=/dev/dri:/dev/dri "
# May need the following if using iris graphics on some systems
# Ideally, it shouldn't be used.
# Ubuntu 22.04 based image will not work with iris graphics
# Ubuntu 20.04 based image will work, but in compatability mode
DOCKER_OPTIONS+="-e MESA_LOADER_DRIVER_OVERRIDE=i965 "

## PROJECT
DOCKER_OPTIONS+="--mount type=tmpfs,destination=$HOME,tmpfs-mode=1777 "
DOCKER_OPTIONS+="-v $MATLAB_PREF:$MATLAB_PREF "
DOCKER_OPTIONS+="-v $MOUNT_DIR:$MOUNT_DIR "
#DOCKER_OPTIONS+="-v $DOCKER_HOME:$HOME "
if [[ ! -z "$MLM_LICENSE_FILE" ]];then
    DOCKER_OPTIONS+="-e MLM_LICENSE_FILE=$MLM_LICENSE_FILE "
fi
DOCKER_OPTIONS+="--name $NAME "
#DOCKER_OPTIONS+="--entrypoint bash "
#DOCKER_OPTIONS+="--entrypoint matlab "
# Setting the workdir crashes matlab??
#DOCKER_OPTIONS+="--workdir=$MOUNT_DIR "
DOCKER_OPTIONS+="--net=host "
# For Nvidia compute and acceleration. Comment out if having issues.
#DOCKER_OPTIONS+="--gpus=all,$CAPABILITIES_STR "


## RUN
docker run $DOCKER_OPTIONS $IMAGE -sd $STARTING_DIR
#docker run $DOCKER_OPTIONS $IMAGE


