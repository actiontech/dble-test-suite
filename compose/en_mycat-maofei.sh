#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
mysql_install=("mycat.centos6-1" "mycat.mysql" "mycat.mysql1" "mycat.mysql2")
count=${#mysql_install[@]}
path=/opt/mycat_build/
	for(( i=0;i<count;i=i+1 ));
	do
		echo "install mysql in ${mysql_install[$i]} start"
		cd ${path}
		docker cp mysql-5.7.13-linux-glibc2.5-x86_64.tar.gz ${mysql_install[$i]}:/usr/local \
		&& docker exec ${mysql_install[$i]} sh -c "cd /usr/local && tar xf mysql-5.7.13-linux-glibc2.5-x86_64.tar.gz" \
		&& docker exec ${mysql_install[$i]} sh -c "cd /usr/local && rm -rf mysql-5.7.13-linux-glibc2.5-x86_64.tar.gz" \
		&& docker exec ${mysql_install[$i]} sh -c "cd /usr/local && mv mysql-5.7.13-linux-glibc2.5-x86_64 mysql && groupadd mysql && useradd -r -g mysql -s /bin/false mysql" \
		&& docker exec ${mysql_install[$i]} sh -c "cd /usr/local/mysql && mkdir data mysql-files && chown -R mysql:mysql . " \
		&& docker exec ${mysql_install[$i]} sh -c "yum -y install libaio" \
		&& docker exec ${mysql_install[$i]} sh -c "cd /usr/local/mysql && bin/mysqld --initialize --user=mysql > /initialize.log 2>&1" \
		&& docker exec ${mysql_install[$i]} sh -c "cat /initialize.log|grep 'temporary password' | sed 's/.*@localhost: //' >/usr/local/mysql/tmppwd.log 2>&1" \
		&& docker exec ${mysql_install[$i]} sh -c "yum install -y openssl" \
		&& docker exec ${mysql_install[$i]} sh -c "cd /usr/local/mysql && bin/mysql_ssl_rsa_setup && chown -R root . && chown -R mysql data mysql-files && mkdir -p /var/log/mariadb && touch /var/log/mariadb/mariadb.log" \
		&& docker exec ${mysql_install[$i]} sh -c "cd /usr/local/mysql && support-files/mysql.server start" \
		&& tmppwd=\'$(docker exec "${mysql_install[$i]}" sh -c "cat /usr/local/mysql/tmppwd.log|xargs echo")\' \
		&& docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p${tmppwd} -h127.0.0.1 -e \"alter user user() identified by '111111'\" --connect-expired-password" \
		&& echo "install mysql in ${mysql_install[$i]} finished" \
		&& docker exec ${mysql_install[$i]} sh -c "yum install -y openssh-server" \
		&& docker exec ${mysql_install[$i]} sh -c "sed -i '$ a UseDNS no \nGSSAPIAuthentication no ' /etc/ssh/sshd_config" \
		&& docker exec ${mysql_install[$i]} sh -c "echo 'sshpass' | passwd root --stdin" \
		&& docker exec ${mysql_install[$i]} sh -c "yum install -y net-tools" \
		
		docker exec ${mysql_install[$i]} /etc/init.d/sshd restart
		#docker exec ${mysql_install[$i]} systemctl restart sshd.service
	done
	sleep 10s

	for((i=0;i<count;i=i+1)); do
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create user 'test'@'%' identified by 'test'\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"grant all on *.* to 'test'@'%' with grant option\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database db1\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database db2\" "
	    docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database db3\" "
		docker exec ${mysql_install[$i]} sh -c "/usr/local/mysql/bin/mysql -uroot -p111111 -h127.0.0.1 -e \"create database db4\" "
	done

	for(( i=0;i<count;i=i+1 ));
	do
		if [ $i == 0 ];then
		echo "install JDK in ${mysql_install[0]} start"
		cd ${path}
		docker cp jdk-8u121-linux-x64.tar.gz ${mysql_install[i]}:/usr/local/
		docker exec ${mysql_install[i]} sh -c "cd /usr/local/ && tar xf jdk-8u121-linux-x64.tar.gz"
		docker exec ${mysql_install[i]} sh -c "cd /usr/local/ && rm -rf jdk-8u121-linux-x64.tar.gz"
		docker exec ${mysql_install[i]} sh -c "echo 'export JAVA_HOME=/usr/local/jdk1.8.0_121' >> /etc/profile 2>&1"
		docker exec ${mysql_install[i]} sh -c "echo 'export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar' >> /etc/profile 2>&1" 
		docker exec ${mysql_install[i]} sh -c "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> /etc/profile 2>&1" 
		docker exec ${mysql_install[i]} sh -c "source /etc/profile"
		docker exec ${mysql_install[i]} sh -c "yum -y install wget"
		fi
	done
	for(( i=0;i<count;i=i+1 ));
	do
		if [ $i != 0 ];then
		temp=\'$(docker exec "${mysql_install[$i]}" sh -c "cat /etc/hosts | grep 'mycat'|xargs echo")\'
		docker exec "${mysql_install[0]}" sh -c "echo ${temp} >> /etc/hosts"		
		fi
	done

	mv ~/.ssh/known_hosts /tmp


