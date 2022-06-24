#!/bin/bash
#run this script for the first time init environment
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}

#ssh with no pwd
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@dble-1:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@dble-2:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@dble-3:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@mysql:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@mysql-master1:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@mysql-master2:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@driver-test:/root/.ssh/authorized_keys

#init mysql passwd
mysql_install=("mysql" "mysql-master1" "mysql-master2" "dble-1" "dble-2" "dble-3")
count=${#mysql_install[@]}
for((i=0; i<count; i=i+1)); do
    ssh root@${mysql_install[$i]}  "bash /usr/local/bin/mysql_init.sh"
done

bash /docker-build/resetReplication.sh