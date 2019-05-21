#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
echo " ">> /opt/zookeeper/conf/zoo.cfg
sed -i "$ a tickTime=2000\ninitLimit=10\nsyncLimit=5 \nclientPort=2181" /opt/zookeeper/conf/zoo.cfg
sed -i "$ a dataDir=/opt/zookeeper/data\ndataLoginDir=/opt/zookeeper/logs" /opt/zookeeper/conf/zoo.cfg
sed -i "$ a server.1=dble-1:2888:3888\nserver.2=dble-2:2888:3888\nserver.3=dble-3:2888:3888" /opt/zookeeper/conf/zoo.cfg
mkdir /opt/zookeeper/data/
echo "$1">> /opt/zookeeper/data/myid

sed -i '2c server-uuid='$(uuidgen)' ' /var/lib/mysql/auto.cnf
sed -i '2c server-id='$1' ' /etc/my.cnf
/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --skip-grant-tables --user=mysql >/dev/null 2>&1 &
sleep 30s && /usr/local/mysql/bin/mysql -uroot --skip-password -e "flush privileges;alter user root@'localhost' identified by '111111'"

if [ "$1" -gt "1" ]; then
sleep 45s
/usr/local/mysql/bin/mysql -uroot -p111111 -e "change master to master_host='172.100.9.6', master_user='repl', master_password='111111', master_auto_position=1"
/usr/local/mysql/bin/mysql -uroot -p111111 -e "start slave"
else
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create database testdb"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create database tpccdb"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create database db1;create database db2;create database db3;create database db4"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create database schema1;create database schema2;create database schema3"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create user 'test'@'%' identified by '111111'"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "grant all on *.* to 'test'@'%' with grant option"
fi

/bin/bash