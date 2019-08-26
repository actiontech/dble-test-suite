#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo $1
dble_install=$@
count=${#dble_install[@]}
for((i=0; i<count; i=i+1)); do
    echo "reset views in ${dble_install[$i]} starting"
    #remove viewConf
    echo "remove viewConf in ${dble_install[$i]}"
    ssh root@${dble_install[$i]} sh -c "rm -rf /opt/dble/viewConf"
    echo "remove viewConf in ${dble_install[$i]} success"

    #remove dble registered nodes in zk
    echo "remove dble registered nodes ${dble_install[$i]}"
    ssh root@${dble_install[$i]} sh -c "cd /opt/zookeeper/bin && sh zkCli.sh deleteall /dble"
    echo "remove dble in ${dble_install[$i]} success"

    echo "reset views in ${dble_install[$i]} success"
    echo "-----------------------------------------------------------"
done