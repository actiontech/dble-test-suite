#!/bin/bash

mysql_ips=("172.100.9.1" "172.100.9.2" "172.100.9.3" "172.100.9.4" "172.100.9.5" "172.100.9.6" )
Hostname=("dble-1" "dble-2" "dble-3" "mysql" "mysql-master1" "mysql-master2" "mysql8-master1" )

count=${#Hostname[@]}

auto_ssh_copy_id(){
   expect -c "set timeout -1;
   spawn ssh-copy-id -i root@$1;
   expect {
    *(yes/no)* {send -- yes\r;exp_continue;}
    *assword:* {send -- $2\r;exp_continue;}
    eof   {exit 0;}
   }";
}

# ci环境使用go用户运行，know_hosts改为家目录下的
ssh_copy_id_to_all(){
  for((i=0; i< count; i=i+1)); do
      docker ps 1>/dev/null 2>/dev/null
      if [ $? = 0 ];then
          echo "==========清除密钥信息=========="
          ssh-keygen -f "/root/.ssh/known_hosts" -R ${mysql_ips[$i]}
          ssh-keygen -f "/root/.ssh/known_hosts" -R ${Hostname[$i]}
      fi
      
      sudo grep "${mysql_ips[$i]} ${Hostname[$i]}" /etc/hosts 1>/dev/null 2>/dev/null
      if [ $? != 0 ];then
        echo "==== hostname写入hosts文件 ===="
        echo "${mysql_ips[$i]} ${Hostname[$i]}" | sudo tee -a /etc/hosts
      fi

      auto_ssh_copy_id ${Hostname[$i]} sshpass
  done
}
ssh_copy_id_to_all