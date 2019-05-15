#!/usr/bin/env bash
echo " ">> /opt/zookeeper/conf/zoo.cfg
sed -i "$ a tickTime=2000\ninitLimit=10\nsyncLimit=5 \nclientPort=2181" /opt/zookeeper/conf/zoo.cfg
sed -i "$ a dataDir=/opt/zookeeper/data\ndataLoginDir=/opt/zookeeper/logs" /opt/zookeeper/conf/zoo.cfg
sed -i "$ a server.1=dble-1:2888:3888\nserver.2=dble-2:2888:3888\nserver.3=dble-3:2888:3888" /opt/zookeeper/conf/zoo.cfg
mkdir /opt/zookeeper/data/
echo "$1">> /opt/zookeeper/data/myid

sed -i "/server-id/c server-id=$1" /etc/my.cnf
mkdir -p /var/lib/mysql
touch /var/lib/mysql/auto.cnf
echo "server-uuid=$(uuidgen)" > /var/lib/mysql/auto.cnf
/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --skip-grant-tables --user=mysql >/dev/null 2>&1 &
sleep 30s && /usr/local/mysql/bin/mysql -uroot --skip-password -e "flush privileges;alter user root@'localhost' identified by '111111'"