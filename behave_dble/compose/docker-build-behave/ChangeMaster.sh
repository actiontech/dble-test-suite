#!/bin/bash
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}
echo "master is ${1},slaves are ${2} and ${3},and mysql version is ${4}"
master_ip=`ssh root@${1} "hostname -i"`
echo "master ip is ${master_ip}"

mysql_version=`echo ${4} | sed 's/\./\_/g'`

echo "==================  reset master ${1}  =================="
ssh root@${1}  "mysql -uroot -p111111 -e \"reset master;stop slave;reset slave all;\" "
ssh root@${1}  "sed -i -e '/log-bin=/d' -e '/binlog_format=/d' -e '/relay-log=/d' -e '/\[mysqld\]/a log-bin=mysql-bin \nbinlog_format=row \nrelay-log=mysql-relay-bin' /root/sandboxes/msb_${mysql_version}/my.sandbox.cnf"
ssh root@${1}  "/root/sandboxes/msb_${mysql_version}/restart"
ssh root@${1}  "mysql -uroot -p111111 -e \"create user if not exists 'repl'@'%' identified by '111111';\""
ssh root@${1}  "mysql -uroot -p111111 -e \"grant replication slave on *.* to 'repl'@'%';\""

sleep 5s

echo "==================  reset slave ${2}  =================="
ssh root@${2}  "mysql -uroot -p111111 -e \"reset master;stop slave;reset slave all;set global gtid_purged='';\" "
ssh root@${2}  "mysql -uroot -p111111 -e \"change master to master_host='${master_ip}', master_port=3307, master_user='repl', master_password='111111', master_auto_position=1;\""
ssh root@${2}  "mysql -uroot -p111111 -e \"start slave;\" "

echo "==================  reset slave ${3}  =================="
ssh root@${3}  "mysql -uroot -p111111 -e \"reset master;stop slave;reset slave all;set global gtid_purged='';\" "
ssh root@${3}  "mysql -uroot -p111111 -e \"change master to master_host='${master_ip}', master_port=3307, master_user='repl', master_password='111111', master_auto_position=1;\""
ssh root@${3}  "mysql -uroot -p111111 -e \"start slave;\" "