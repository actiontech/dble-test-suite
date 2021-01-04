#!/usr/bin/env bash
/usr/local/mysql/bin/mysqld --initialize-insecure --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data  --user=mysql >/dev/null 2>&1
mkdir -p /var/lib/mysql && touch /var/lib/mysql/auto.cnf && echo "server-uuid=$(uuidgen)" > /var/lib/mysql/auto.cnf
/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --user=mysql >/dev/null 2>&1 &
sleep 30s && /usr/local/mysql/bin/mysql -uroot -p111111 -e "flush privileges;alter user root@'localhost' identified by '111111'"
echo -e "alias mysql='mysql -uroot -p111111'" >> /root/.bashrc
. ~/.bashrc
