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
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@behave:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@mysql8-master1:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@mysql8-master2:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@mysql8-slave1:/root/.ssh/authorized_keys
sshpass -psshpass scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa.pub root@mysql8-slave2:/root/.ssh/authorized_keys