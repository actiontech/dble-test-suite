#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# delete all backend mysql tables from db1 ~ db4

set -e

mysql_install_V5=("mysql" "mysql-master1" "mysql-master2" "dble-1" "dble-2" "dble-3")
mysql_install_V8=("mysql8-master1" "mysql8-master2" "mysql8-slave1" "mysql8-slave2")
db=("db1" "db2" "db3" "db4")

count_V5=${#mysql_install_V5[@]}
count_V8=${#mysql_install_V8[@]}
count_db=${#db[@]}

for((i=0; i<count_V5; i=i+1)); do
  for((j=0; j<count_db; j=j+1)); do
      ssh root@${mysql_install_V5[$i]} "mysql -uroot -p111111 -e \"select concat('drop table if exists ',table_name,';') from information_schema.TABLES where table_schema like 'db%' into outfile '/tmp/tables.txt';\" "
      ssh root@${mysql_install_V5[$i]}  "mysql -uroot -p111111 -D${db[$j]} -e \"source /tmp/tables.txt;\" "
      ssh root@${mysql_install_V5[$i]} "rm -rf /tmp/tables.txt"
  done
done

for((i=0; i<count_V8; i=i+1)); do
  for((j=0; j<count_db; j=j+1)); do
    ssh root@${mysql_install_V8[$i]} "mysql -uroot -p111111 -e \"select concat('drop table if exists ',table_name,';') from information_schema.TABLES where table_schema like 'db%' into outfile '/tmp/tables.txt';\" "
    ssh root@${mysql_install_V8[$i]}  "mysql -uroot -p111111 -D${db[$j]} -e \"source /tmp/tables.txt;\" "
    ssh root@${mysql_install_V8[$i]} "rm -rf /tmp/tables.txt"
  done
done

