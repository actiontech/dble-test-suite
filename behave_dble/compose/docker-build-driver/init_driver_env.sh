#!/bin/bash
#run this script for the first time init environment
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}

#ssh with no pwd
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@dble-1
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@dble-2
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@dble-3
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@mysql
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@mysql-master1
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@mysql-master2
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@mysql8-master1
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@mysql8-master2
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@mysql8-slave1
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@mysql8-slave2
sshpass -psshpass ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/id_rsa.pub root@behave