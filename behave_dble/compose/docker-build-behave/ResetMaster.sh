#!/bin/bash
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}
mysql_install=("mysql-master2" "dble-2" "dble-3")


echo "reset master "
ssh root@${mysql_install[0]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"reset master;stop slave;reset slave all;\" "
ssh root@${mysql_install[0]}  "sed -i -e '/log-bin=/d' -e '/binlog_format=/d' -e '/relay-log=/d' -e '/\[mysqld\]/a log-bin=mysql-bin \nbinlog_format=row \nrelay-log=mysql-relay-bin' /etc/my.cnf"
ssh root@${mysql_install[0]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -e \"create user if not exists 'repl'@'%' identified by '111111';\""
ssh root@${mysql_install[0]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -e \"grant replication slave on *.* to 'repl'@'%' identified by '111111';\""
ssh root@${mysql_install[0]}  "/usr/local/mysql/support-files/mysql.server restart"
sleep 30s

echo "reset slave "
ssh root@${mysql_install[1]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"reset master;stop slave;reset slave all;\" "
ssh root@${mysql_install[1]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -e \"change master to master_host='172.100.9.6', master_user='repl', master_password='111111', master_auto_position=1;\""
ssh root@${mysql_install[1]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"start slave;\" "

echo "reset slave"
ssh root@${mysql_install[2]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"reset master;stop slave;reset slave all;\" "
ssh root@${mysql_install[2]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -e \"change master to master_host='172.100.9.6', master_user='repl', master_password='111111', master_auto_position=1;\""
ssh root@${mysql_install[2]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"start slave;\" "
