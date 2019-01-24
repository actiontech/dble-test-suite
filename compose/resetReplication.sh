#!/bin/bash
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}
#clean mysqld before testing, including: drop none-sys databases, reset replication relation, prepare uproxy wanted database and table for delay checking
mysql_install=("mysql" "mysql-master1" "mysql-master2" "dble-1" "dble-2" "dble-3")

#mysql_install=("centos7-1" "mysql" "mysql-master" "mysql-slave1" "mysql-slave2" "centos6-1")
count=${#mysql_install[@]}

#restart all mysqlds
for((i=0; i<count; i=i+1)); do
	echo "restart mysql and delete none-sys dbs in ${mysql_install[$i]}"
	docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/support-files/mysql.server restart" \
	&& docker cp ${base_dir}/deleteDb.sql "${mysql_install[$i]}:/" \
	&& sleep 5s \
	&& docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 < /deleteDb.sql"
done

echo "reset master ${mysql_install[2]}"
docker exec ${mysql_install[2]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"reset master;\" "

sleep 60s

#i=4 stands for mysql slave in dble-2, i=5 stands for mysql slave in dble-3
for((i=4; i<6; i=i+1)); do
	echo "reset slave ${mysql_install[$i]}"
	docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"stop slave; reset slave; change master to master_auto_position=1\" "
	docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"reset master; set global gtid_purged='';\" "
done

for((i=4; i<6; i=i+1)); do
	echo "start slave ${mysql_install[$i]}"
	docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e \"start slave;\" "
done

echo "create database in compare mysql"
docker exec ${mysql_install[0]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database schema1\" "
docker exec ${mysql_install[0]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database testdb\" "
docker exec ${mysql_install[0]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database tpccdb\" "

for((i=0; i<3; i=i+1)); do
    echo "add some user and database in ${mysql_install[$i]}"
    docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"drop user if exists 'test'@'%';create user 'test'@'%' identified by '111111'\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"grant all on *.* to 'test'@'%' with grant option\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database db1;create database db2;create database db3;create database db4\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database schema1;create database schema2;create database schema3;\" "
done