#!/usr/bin/env bash
 mkdir -p /var/lib/mysql && touch /var/lib/mysql/auto.cnf && echo "server-uuid=$(uuidgen)" > /var/lib/mysql/auto.cnf
/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --skip-grant-tables --user=mysql >/dev/null 2>&1 &
sleep 30s && /usr/local/mysql/bin/mysql -uroot --skip-password -e "flush privileges;alter user root@'localhost' identified by '111111'"