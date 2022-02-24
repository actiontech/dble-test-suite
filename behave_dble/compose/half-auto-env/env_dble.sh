#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
#mainly: config mysqld, config 1m2s replication, create some mysqld users for testing
mysql_install=("mysql" "mysql-master1" "mysql-master2" "dble-1" "dble-2" "dble-3")
dble_install=("dble-1" "dble-2" "dble-3")
count=${#mysql_install[@]}

cp ./install_mysql.sh /opt/auto_build
cp ./sources/mysql-*.tar.gz /opt/auto_build/

for(( i=0;i<count;i=i+1 ));
do
	docker exec ${mysql_install[$i]} sh -c "mkdir ~/.ssh"
	docker cp ~/.ssh/id_rsa.pub ${mysql_install[$i]}:/root/.ssh/authorized_keys

	echo "install mysql in ${mysql_install[$i]} start $i"
	docker exec ${mysql_install[$i]} bash /init_assets/install_mysql.sh $i
	echo "install mysql in ${mysql_install[$i]} finished"

#	if container is centos6
    docker exec ${mysql_install[$i]} sh -c "sed -i '$ a UseDNS no \nGSSAPIAuthentication no ' /etc/ssh/sshd_config" \
    docker exec ${mysql_install[$i]} sh -c "echo 'sshpass' | passwd root --stdin"
    docker exec ${mysql_install[$i]} /usr/sbin/sshd restart
#    end if centos6
done

sleep 10s

for(( i=1;i<count;i=i+1 ));
do
	temp=\'$(docker exec "${mysql_install[$i]}" sh -c "cat /etc/hosts | grep '${mysql_install[$i]}'|xargs echo")\'
	for(( j=0;j<3;j=j+1));
	do
	    docker exec "${dble_install[$j]}" sh -c "echo ${temp} >> /etc/hosts"
	done
done

#start master and slaves
for((i=2; i<3; i=i+1)); do
	echo "set and restart master ${mysql_install[$i]}"
	docker exec ${mysql_install[$i]} sh -c "sed -i -e '/log_bin/d' -e '/\[mysqld\]/a log-bin=mysql-bin \nbinlog_format=row \nrelay-log=mysql-relay-bin' /etc/my.cnf \
		&& mysql -uroot -e \"create user 'repl'@'%' identified by '111111'\" \
		&& mysql -uroot -e \"grant replication slave on *.* to 'repl'@'%' identified by '111111'\" \
		&& /usr/local/mysql/support-files/mysql.server restart"
done
sleep 60s
for((i=4; i<6; i=i+1)); do
	echo "set and start slave ${mysql_install[$i]}"
	docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/support-files/mysql.server restart \
	&& mysql -uroot -e \"change master to master_host='172.100.9.6', \
	master_user='repl', \
	master_password='111111', \
	master_auto_position=1\" \
	&& mysql -uroot -e \"start slave\" "
done

for((i=0; i<3; i=i+1)); do
    echo "add some user and database in ${mysql_install[$i]}"
    if [[ ${mysql_install[$i]} == "mysql" ]]; then
        docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database schema1\" "
        docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database testdb\" "
        docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database tpccdb\" "
    fi
    docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create user 'test'@'%' identified by '111111'\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"grant all on *.* to 'test'@'%' with grant option\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database db1;create database db2;create database db3;create database db4\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database schema1;create database schema2;create database schema3\" "
done

cp ./install_jdk.sh /opt/auto_build
cp ./install_zookeeper.sh /opt/auto_build
cp ./sources/jdk-*.tar.gz /opt/auto_build/
cp ./sources/zookeeper-*.tar.gz /opt/auto_build/

for((i=0; i<3; i=i+1)); do
    docker exec ${dble_install[$i]} bash /init_assets/install_jdk.sh $i
    echo "install jdk in ${mysql_install[$i]} finished"
    docker exec ${dble_install[$i]} bash /init_assets/install_zookeeper.sh $i
    echo "install zookeeper in ${dble_install[$i]} finished"
    sleep 2s
done