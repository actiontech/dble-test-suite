#!/bin/bash
echo "install jdk 1.8"
install_jdk_rpm="jdk-8u121-linux-x64.rpm"
mkdir -p /usr/java
cd /init_assets && tar -zxf jdk-8u121-linux-x64.tar.gz
mv jdk1.8.0_121 /usr/java/
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_121'>>/etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar'>>/etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH'>>/etc/profile
source /etc/profile