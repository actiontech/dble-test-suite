#!/bin/bash
set -e
base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}
#clean mysqld before testing, including: drop none-sys databases, reset replication relation, prepare uproxy wanted database and table for delay checking
mysql_install_all=("172.100.9.4" "172.100.9.5" "172.100.9.6" "172.100.9.9" "172.100.9.10" "172.100.9.1" "172.100.9.2" "172.100.9.3" "172.100.9.11" "172.100.9.12")
mysql_install_V5=("172.100.9.4" "172.100.9.5" "172.100.9.6" "172.100.9.1" "172.100.9.2" "172.100.9.3")
mysql_install_V8=("172.100.9.9" "172.100.9.10" "172.100.9.11" "172.100.9.12")
count_all=${#mysql_install_all[@]}
count_V5=${#mysql_install_V5[@]}
count_V8=${#mysql_install_V8[@]}

#restart all mysqlds
for((i=0; i<count_V5; i=i+1)); do
	echo "restart mysql and delete none-sys dbs in ${mysql_install_V5[$i]}"
	ssh root@${mysql_install_V5[$i]}  "sed -i -e '/lower_case_table_names/d' -e '/server-id/a lower_case_table_names = 0' /root/sandboxes/msb_5_7_25/my.sandbox.cnf" \
	&& ssh root@${mysql_install_V5[$i]}  "/root/sandboxes/msb_5_7_25/restart" \
	&& ssh root@${mysql_install_V5[$i]} "rm -rf /usr/bin/mysql && ln -sf /root/opt/mysql/5.7.25/bin/mysql /usr/bin/mysql" \
  && ssh root@${mysql_install_V5[$i]} "rm -f /tmp/mysql.sock  && ln -s /tmp/mysql_sandbox3307.sock /tmp/mysql.sock" \
	&& scp ${base_dir}/deleteDb.sql "root@${mysql_install_V5[$i]}:/" \
	&& sleep 5s \
	&& ssh root@${mysql_install_V5[$i]}  "mysql -uroot -p111111 < /deleteDb.sql"
done

for((i=0; i<count_V8; i=i+1)); do
	echo "restart mysql and delete none-sys dbs in ${mysql_install_V8[$i]}"
	ssh root@${mysql_install_V8[$i]}  "sed -i -e '/lower_case_table_names/d' -e '/server-id/a lower_case_table_names = 0' /root/sandboxes/msb_8_0_18/my.sandbox.cnf" \
	&& ssh root@${mysql_install_V8[$i]}  "/root/sandboxes/msb_8_0_18/restart" \
	&& ssh root@${mysql_install_V8[$i]} "rm -rf /usr/bin/mysql && ln -sf /root/opt/mysql/8.0.18/bin/mysql /usr/bin/mysql" \
	&& ssh root@${mysql_install_V8[$i]} "rm -f /tmp/mysql.sock  && ln -s /tmp/mysql_sandbox3307.sock /tmp/mysql.sock" \
	&& scp ${base_dir}/deleteDb.sql "root@${mysql_install_V8[$i]}:/" \
	&& sleep 5s \
	&& ssh root@${mysql_install_V8[$i]}  "mysql -uroot -p111111 < /deleteDb.sql"
done

#clear xa id in mysql-master
for((i=1; i<5; i=i+1)); do
	echo "clear xa in ${mysql_install_all[$i]}"
	xid=(`ssh root@${mysql_install_all[$i]}  "mysql -uroot -p111111 -e 'xa recover'|grep -v data|cut -f 4"`)
	#check if remained xid or not
	if [ ${#xid[@]} -eq 0 ];then
	  echo "There is no remained xid in ${mysql_install_all[$i]}"
	  continue
	else
	  echo "need rollback xids in ${mysql_install_all[$i]} are ${xid}"
	  for ((j=0;j<${#xid[@]};j++));do
	      echo "rollback xid is ${xid[j]}"
        ssh root@${mysql_install_all[$i]}  "mysql -uroot -p111111 -e\"xa rollback '${xid[j]}'\""
    done
	fi
done

echo "reset replication for mysql5.7"
bash ${base_dir}/ChangeMaster.sh 172.100.9.6 172.100.9.2 172.100.9.3 5.7.25

echo "reset replication for mysql8.0"
bash ${base_dir}/ChangeMaster.sh 172.100.9.10 172.100.9.11 172.100.9.12 8.0.18

echo "create database in compare mysql"
ssh root@${mysql_install_all[0]}  "mysql -uroot -p111111 -e \"create database schema1;create database schema2;create database schema3;\" "
ssh root@${mysql_install_all[0]}  "mysql -uroot -p111111 -e \"create database testdb\" "

for((i=0; i<6; i=i+1)); do
    echo "add some users and database in ${mysql_install_all[$i]}"
	ssh root@${mysql_install_all[$i]}  "mysql -uroot -p111111 -e \"drop user if exists 'sharding'@'%';create user 'sharding'@'%' identified by '111111'\" "
	ssh root@${mysql_install_all[$i]}  "mysql -uroot -p111111 -e \"grant all on *.* to 'sharding'@'%' with grant option\" "
	ssh root@${mysql_install_all[$i]}  "mysql -uroot -p111111 -e \"drop user if exists 'rwSplit'@'%';create user 'rwSplit'@'%' identified by '111111'\" "
	ssh root@${mysql_install_all[$i]}  "mysql -uroot -p111111 -e \"grant all on *.* to 'rwSplit'@'%' with grant option\" "
	ssh root@${mysql_install_all[$i]}  "mysql -uroot -p111111 -e \"create database db1;create database db2;create database db3;create database db4\" "
done