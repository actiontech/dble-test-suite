#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
dble_install=("dble-1" "dble-2" "dble-3")
rm -r /opt/zookeeper
cd /init_assets && tar -zxf zookeeper-3.4.9.tar.gz
mv /init_assets/zookeeper-3.4.9 /opt/zookeeper
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

