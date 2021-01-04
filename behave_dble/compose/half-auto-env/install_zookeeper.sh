#!/bin/bash
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
#this script is tested for zookeeper-3.4.9.tar.gz
source_dir=$( dirname ${BASH_SOURCE[0]} )

dble_install=("dble-1" "dble-2" "dble-3")
rm -r /opt/zookeeper
cd ${source_dir} && tar -zxf zookeeper-*.tar.gz
zk_full_name=`ls ${source_dir}| egrep -w "zookeeper*" | grep -v ".tar.gz"`
mv ${source_dir}/${zk_full_name} /opt/zookeeper
mkdir -pv /opt/zookeeper/{data,logs}/
echo " ">> /opt/zookeeper/conf/zoo.cfg
sed -i "$ a tickTime=2000\ninitLimit=10\nsyncLimit=5 \nclientPort=2181" /opt/zookeeper/conf/zoo.cfg
sed -i "$ a dataDir=/opt/zookeeper/data\ndataLoginDir=/opt/zookeeper/logs" /opt/zookeeper/conf/zoo.cfg

sed -i "$ a server.1=dble-1:2888:3888\nserver.2=dble-2:2888:3888\nserver.3=dble-3:2888:3888" /opt/zookeeper/conf/zoo.cfg

for ((i=1; i<4; i+=1));do
    if [[ `hostname` -eq ${dble_install[$i-1]} ]]; then
	    echo $i >> /opt/zookeeper/data/myid
    fi
done

