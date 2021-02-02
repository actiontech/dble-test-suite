#!/bin/bash
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}
#clean mysqld before testing, including: drop none-sys databases, reset replication relation, prepare uproxy wanted database and table for delay checking
mysql_install=("mysql" "mysql-master1" "mysql-master2" "mysql8-master1" "mysql8-master2" "dble-1" "dble-2" "dble-3" "mysql8-slave1" "mysql8-slave2")

count=${#mysql_install[@]}

#restart all mysqlds
for((i=0; i<count; i=i+1)); do
	echo "restart mysql and delete none-sys dbs in ${mysql_install[$i]}"
	ssh root@${mysql_install[$i]}  "sed -i -e '/lower_case_table_names/d' -e '/server-id/a lower_case_table_names = 0' /etc/my.cnf" \
	&& ssh root@${mysql_install[$i]}  "/usr/local/mysql/support-files/mysql.server restart" \
	&& scp ${base_dir}/deleteDb.sql "root@${mysql_install[$i]}:/" \
	&& sleep 5s \
	&& ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 < /deleteDb.sql"
done

#clear xa id in mysql-master
for((i=1; i<5; i=i+1)); do
	echo "clear xa in ${mysql_install[$i]}"
	xid=(`ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e 'xa recover'|grep -v data|awk '{print $4}'"`)
	for ((j=0;j<${#xid[@]};j++));do
        ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -P3306 -e\"xa rollback '${xid[j]}'\""
    done
done

echo "reset replication for mysql5.7"
bash ${base_dir}/ChangeMaster.sh mysql-master2 dble-2 dble-3

echo "reset replication for mysql8.0"
bash ${base_dir}/ChangeMaster.sh mysql8-master2 mysql8-slave1 mysql8-slave2

echo "create database in compare mysql"
ssh root@${mysql_install[0]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database schema1;create database schema2;create database schema3;\" "
ssh root@${mysql_install[0]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database testdb\" "

for((i=0; i<6; i=i+1)); do
    echo "add some users and database in ${mysql_install[$i]}"
    ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"drop user if exists 'test'@'%';create user 'test'@'%' identified by '111111'\" "
	ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"grant all on *.* to 'test'@'%' with grant option\" "
	ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"drop user if exists 'sharding'@'%';create user 'sharding'@'%' identified by '111111'\" "
	ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"grant all on *.* to 'sharding'@'%' with grant option\" "
	ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"drop user if exists 'rwSplit'@'%';create user 'rwSplit'@'%' identified by '111111'\" "
	ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"grant all on *.* to 'rwSplit'@'%' with grant option\" "
	ssh root@${mysql_install[$i]}  "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database db1;create database db2;create database db3;create database db4\" "
done