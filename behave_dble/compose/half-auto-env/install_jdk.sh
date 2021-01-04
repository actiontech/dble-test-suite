#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# this script is tested for jdk-8u121-linux-x64.tar.gz
source_dir=$( dirname ${BASH_SOURCE[0]} )
echo "install jdk from bash dir : ${source_dir}"
rm -rf /usr/java
mkdir -p /usr/java
cd ${source_dir} && tar -zxf jdk-*.tar.gz
jdk_full_name=`ls ${source_dir}| grep "^jdk*" | grep -v ".tar.gz"`
echo "jdk to use: ${jdk_full_name}"
mv ${source_dir}/${jdk_full_name} /usr/java/

echo "config java env"
sed -i -e "/JAVA_HOME/d" -e "/export CLASSPATH=/d " /etc/bashrc

echo "export JAVA_HOME=/usr/java/${jdk_full_name}">>/etc/bashrc
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar'>>/etc/bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH'>>/etc/bashrc
source /etc/bashrc