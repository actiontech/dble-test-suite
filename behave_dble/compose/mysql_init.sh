#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
sed -i '2c server-id='$1' ' /etc/my.cnf
sed -i '2c server-uuid='$(uuidgen)' ' /var/lib/mysql/auto.cnf
/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --skip-grant-tables --user=mysql >/dev/null 2>&1 &
sleep 15s && /usr/local/mysql/bin/mysql -uroot --skip-password -e "flush privileges;alter user root@'localhost' identified by '111111'"

if [ "$1" -eq "6" ]; then
sed -i -e '/log_bin/d' -e '/\[mysqld\]/a log-bin=mysql-bin \nbinlog_format=row \nrelay-log=mysql-relay-bin' /etc/my.cnf
/usr/local/mysql/bin/mysql -uroot -p111111 -e "create user 'repl'@'%' identified by '111111'"
/usr/local/mysql/bin/mysql -uroot -p111111 -e "grant replication slave on *.* to 'repl'@'%' identified by '111111'"
/usr/local/mysql/support-files/mysql.server restart
fi

/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create database testdb"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create database tpccdb"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create user 'test'@'%' identified by '111111'"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "grant all on *.* to 'test'@'%' with grant option"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create database db1;create database db2;create database db3;create database db4"
/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e "create database schema1;create database schema2;create database schema3"

/bin/bash