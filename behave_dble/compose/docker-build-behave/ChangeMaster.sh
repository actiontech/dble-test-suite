#!/bin/bash
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}

master_ip=`ssh root@${1} "hostname -i" | cut -d " " -f 2`
echo "master ip is ${master_ip}"

echo "==================  reset master ${1}  =================="
ssh root@${1}  "mysql -e \"reset master;stop slave;reset slave all;\" "
ssh root@${1}  "sed -i -e '/log-bin=/d' -e '/binlog_format=/d' -e '/relay-log=/d' -e '/\[mysqld\]/a log-bin=mysql-bin \nbinlog_format=row \nrelay-log=mysql-relay-bin' /root/sandboxes/sandbox/master/my.sandbox.cnf"
ssh root@${1}  "/root/sandboxes/sandbox/master/restart"
ssh root@${1}  "mysql -e \"create user if not exists 'repl'@'%' identified by '111111';\""
ssh root@${1}  "mysql -e \"grant replication slave on *.* to 'repl'@'%';\""

sleep 5s

echo "==================  reset slave ${2}  =================="
ssh root@${2}  "mysql2 -e \"reset master;stop slave;reset slave all;set global gtid_purged='';\" "
ssh root@${2}  "mysql2 -e \"change master to master_host='${master_ip}', master_port=3306, master_user='repl', master_password='111111', master_auto_position=1;\""
ssh root@${2}  "mysql2 -e \"start slave;\" "

if [ $# -eq 3 ]; then
    echo "==================  reset slave ${3}  =================="
    ssh root@${3}  "mysql3 -e \"reset master;stop slave;reset slave all;set global gtid_purged='';\" "
    ssh root@${3}  "mysql3 -e \"change master to master_host='${master_ip}', master_port=3306, master_user='repl', master_password='111111', master_auto_position=1;\""
    ssh root@${3}  "mysql3 -e \"start slave;\" "
fi
