#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
base_dir=$( dirname ${BASH_SOURCE[0]} )
dble_install=$@
count=${#dble_install[@]}
for((i=0; i<count; i=i+1)); do
    #remove viewConf
    echo "try to remove viewConf in host ${dble_install[$i]}"
    ssh root@${dble_install[$i]} sh -c "rm -rf /opt/dble/viewConf > /dev/null 2>&1"
    echo "try to remove viewConf finished"

    #remove dble registered nodes in zk
    echo "try to remove zookeeper registered key '/dble' in host ${dble_install[$i]}"
    ssh root@${dble_install[$i]} sh -c "cd /opt/zookeeper/bin && (sh zkCli.sh deleteall /dble >/dev/null 2>&1)"
    echo "try to remove zookeeper registered key finished"

    echo "-----------------------------------------------------------"
done