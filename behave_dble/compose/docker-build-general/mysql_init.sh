#!/usr/bin/env bash
/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --skip-grant-tables --user=mysql >/dev/null 2>&1 &
sleep 30s && /usr/local/mysql/bin/mysql -uroot --skip-password -e "flush privileges;alter user root@'localhost' identified by '111111'"