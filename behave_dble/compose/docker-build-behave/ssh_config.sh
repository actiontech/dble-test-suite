#!/bin/bash

mysql_ips=("172.100.9.1" "172.100.9.2" "172.100.9.3" "172.100.9.4" "172.100.9.5" "172.100.9.6" "172.100.9.9" "172.100.9.10" "172.100.9.11" "172.100.9.12")
Hostname=("dble-1" "dble-2" "dble-3" "mysql" "mysql-master1" "mysql-master2" "mysql8-master1" "mysql8-master2" "mysql8-slave1" "mysql8-slave2")

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
   #   ssh-keygen -f "/root/.ssh/known_hosts" -R ${mysql_ips[$i]}
   #   ssh-keygen -f "/root/.ssh/known_hosts" -R ${Hostname[$i]}
      echo "${mysql_ips[$i]}  ${Hostname[$i]}" >> /etc/hosts 
      auto_ssh_copy_id ${Hostname[$i]} sshpass
  done
}
ssh_copy_id_to_all