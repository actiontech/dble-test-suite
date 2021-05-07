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

#init mysql passwd
mysql_install=("dble-1" "dble-2" "dble-3" "mysql" "mysql-master1" "mysql-master2" "mysql8-master1" "mysql8-master2" "mysql8-slave1" "mysql8-slave2")
count=${#mysql_install[@]}
for((i=0; i<=5; i=i+1)); do
  server_id=`expr ${i} + 1`
  ssh root@${mysql_install[$i]}  "bash /docker-build/dbdeployer_deploy_mysql.sh 5.7.25 ${server_id}"
done
for((i=6; i<count; i=i+1)); do
  server_id=`expr ${i} + 3`
  ssh root@${mysql_install[$i]}  "bash /docker-build/dbdeployer_deploy_mysql.sh 8.0.18 ${server_id}"
done

bash ${base_dir}/resetReplication.sh

#config zookeeper's myid
dble_install=("dble-1" "dble-2" "dble-3")
count=${#dble_install[@]}
for((i=0; i<3; i=i+1)); do
  myid=`expr ${i} + 1`
  ssh root@${dble_install[$i]}  "echo '${myid}'> /opt/zookeeper/data/myid"
done