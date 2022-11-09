#!/bin/bash
#run this script for the first time init environment
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}
Hostname=("dble-1" "dble-2" "dble-3" "mysql" "mysql-master1" "mysql-master2" )

count=${#Hostname[@]}
for((i=0; i<count; i=i+1)); do
    ssh root@${Hostname[$i]}  "bash /usr/local/bin/mysql_init.sh"
done

bash ${base_dir}/resetReplication.sh