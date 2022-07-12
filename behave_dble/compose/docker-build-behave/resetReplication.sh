#!/bin/bash
set -e
base_dir=$( dirname ${BASH_SOURCE[0]} )
#clean mysqld before testing, including: drop none-sys databases, reset replication relation, prepare uproxy wanted database and table for delay checking

mysql_version_line=`sed -n '5p' ../../conf/auto_dble_test.yaml`
mysql_version=${mysql_version_line: 33: 3}

if [ ${mysql_version} = "5.7" ]; then
    mysql_version=${mysql_version}".25"
else
    mysql_version=${mysql_version}".18"
fi
echo "begin execute resetReplication.sh with mysql version: ${mysql_version}"

mysql_install_all=("mysql" "mysql-master1" "mysql-master2" "mysql-master3")
count_all=${#mysql_install_all[@]}

#restart all mysqlds
for((i=0; i<count_all; i=i+1)); do
	echo "restart mysql and delete none-sys dbs in ${mysql_install_all[$i]}"

	if [ ${mysql_install_all[$i]} = "mysql" ]; then
	    ssh root@${mysql_install_all[$i]}  "/root/sandboxes/sandbox/restart_all" \
	    && scp ${base_dir}/deleteDb.sql "root@${mysql_install_all[$i]}:/" \
	    && sleep 5s \
      && ssh root@${mysql_install_all[$i]}  "mysql1 < /deleteDb.sql" \
      && ssh root@${mysql_install_all[$i]}  "mysql2 < /deleteDb.sql"
	elif [ ${mysql_install_all[$i]} = "mysql-master2" ]; then
      ssh root@${mysql_install_all[$i]}  "/root/sandboxes/sandbox/restart_all" \
      && scp ${base_dir}/deleteDb.sql "root@${mysql_install_all[$i]}:/" \
      && sleep 5s \
      && ssh root@${mysql_install_all[$i]}  "mysql1 < /deleteDb.sql" \
      && ssh root@${mysql_install_all[$i]}  "mysql2 < /deleteDb.sql" \
      && ssh root@${mysql_install_all[$i]}  "mysql3 < /deleteDb.sql"
  else
    	ssh root@${mysql_install_all[$i]}  "/root/sandboxes/sandbox/restart" \
	    && scp ${base_dir}/deleteDb.sql "root@${mysql_install_all[$i]}:/" \
	    && sleep 5s \
      && ssh root@${mysql_install_all[$i]}  "mysql1 < /deleteDb.sql"
	fi
done

echo "begin to rollback xid"
#clear xa id in mysql-master
for((i=0; i<count_all; i=i+1)); do
	echo "clear xa in ${mysql_install_all[$i]}"
	xid=(`ssh root@${mysql_install_all[$i]}  "mysql -e 'xa recover'|grep -v data|cut -f 4"`)
	#check if remained xid or not
	if [ ${#xid[@]} -eq 0 ];then
	  echo "There is no remained xid in ${mysql_install_all[$i]}"
	  continue
	else
	  echo "need rollback xids in ${mysql_install_all[$i]} are ${xid}"
	  for ((j=0;j<${#xid[@]};j++));do
	      echo "rollback xid is ${xid[j]}"
        ssh root@${mysql_install_all[$i]}  "mysql -e\"xa rollback '${xid[j]}'\""
    done
	fi
done

echo "begin to reset replication"
bash ${base_dir}/ChangeMaster.sh mysql-master2 mysql-slave1 mysql-slave2
bash ${base_dir}/ChangeMaster.sh mysql mysql-slave3

echo "create database in compare mysql"
ssh root@${mysql_install_all[0]}  "mysql -e \"create database schema1;create database schema2;create database schema3;create database testdb\""

for((i=0; i<count_all; i=i+1)); do
    echo "add database in ${mysql_install_all[$i]}"
	ssh root@${mysql_install_all[$i]}  "mysql -e \"create database db1;create database db2;create database db3;create database db4\""
done