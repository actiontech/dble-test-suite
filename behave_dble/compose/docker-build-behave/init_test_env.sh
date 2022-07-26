#!/bin/bash
#run this script for the first time init environment
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}

#init mysql passwd
mysql_ips=("172.100.9.1" "172.100.9.2" "172.100.9.3" "172.100.9.4" "172.100.9.5" "172.100.9.6")
Hostname=("dble-1" "dble-2" "dble-3" "mysql" "mysql-1" "mysql-2")

auto_ssh_copy_id(){
   expect -c "set timeout -1;
   spawn ssh-copy-id -i root@$1;
   expect {
    *(yes/no)* {send -- yes\r;exp_continue;}
    *assword:* {send -- $2\r;exp_continue;}
    eof   {exit 0;}
   }";
}

ssh_copy_id_to_all(){
  for((i=0; i<=5; i=i+1)); do
      ssh-keygen -f "/root/.ssh/known_hosts" -R ${mysql_ips[$i]}
      ssh-keygen -f "/root/.ssh/known_hosts" -R ${Hostname[$i]}
      auto_ssh_copy_id ${Hostname[$i]} sshpass
  done
}
ssh_copy_id_to_all