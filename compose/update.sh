#!/bin/bash
pkill java
rm -rf /tmp/dble_conf
mv /opt/dble/conf /tmp/dble_conf
rm -rf dble actiontech-dble.tar.gz
cd /opt && wget ftp://ftp:ftp@10.186.18.20/actiontech-mycat/qa/9.9.9.9/actiontech-dble.tar.gz
cd /opt && tar -zxf actiontech-dble.tar.gz
rm -rf /opt/dble/conf
mv /tmp/dble_conf /opt/dble/conf
rm -rf /usr/bin/dble
ln -s /opt/dble/bin/dble /usr/bin/dble
dble start