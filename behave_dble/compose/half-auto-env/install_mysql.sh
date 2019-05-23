#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
#install mysql, the script is tested for mysql-5.7.13-linux-glibc2.5-x86_64.tar.gz
echo "bash dir : $( dirname ${BASH_SOURCE[0]} )"

rm -rf /usr/local/mysql
tar -zxf mysql-*.tar.gz
mysql_full_name=`ls | egrep -w "mysql*" | grep -v ".tar.gz"`
echo "mysql install package to use: $mysql_full_name"
mv ${mysql_full_name} /usr/local/mysql

echo "groupadd"
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
cd /usr/local/mysql && mkdir data && chown -R mysql:mysql .
#yum -y install libaio
#yum -y install dos2unix

echo "configure my.cnf!"
cp /usr/local/mysql/support-files/my-default.cnf /etc/my.cnf
sed -i '/mysqld_safe/,+2d' /etc/my.cnf
sed -i -e '$a [client] \nuser=test \npassword=111111 \nhost=127.0.0.1 \n' -e "/\[mysqld\]/a server-id=$(($1+2)) \nsession_track_schema=1 \nsession_track_state_change=1 \nsession_track_system_variables=\"*\" \ngtid-mode=on \nenforce_gtid_consistency=on \nearly-plugin-load=keyring_file.so" /etc/my.cnf

echo "mysql initialize!"
rm -rf /var/lib/mysql
/usr/local/mysql/bin/mysqld --initialize-insecure --basedir=/usr/local/mysql --user=mysql >/dev/null 2>&1

echo "openssl install!"
yum install -y openssl > /tmp/install_openssl.log
yum install -y openssh-server

echo "mysql_ssl_rsa_setup!"
/usr/local/mysql/bin/mysql_ssl_rsa_setup > /tmp/mysql_ssl_rsa_setup.log

echo "mysql start skip grant tables!"
/usr/local/mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf --skip-grant-tables --user=mysql >/dev/null 2>&1 &

sleep 5s
/usr/local/mysql/bin/mysql -uroot --skip-password -e "flush privileges;alter user root@'localhost' identified by '111111'"

/usr/local/mysql/support-files/mysql.server restart

echo "net-tools install!"
yum install -y net-tools > /dev/null 2>&1

rm -rf /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
