#!/usr/bin/env bash

if [[ -z "$MLM_LICENSE_FILE" ]];then
    unset MLM_LICENSE_FILE
fi

# Get current time and set target wait time
waituntil=$(($(date +%s) + 30))

# Launch MATLAB + args
matlab ${@:1}

# Sleep until taget time reached so if activation prompt opens,
# we catch it.
sleep_seconds=$(($waituntil - $(date +%s)))
sleep $sleep_seconds 2> /dev/null
# In case the activation script was launched instead...
activation=$(($(pidof MathWorksProductAuthorizer)))
while [ -e /proc/$activation ]
do
    sleep 1
done

