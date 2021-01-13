#!/bin/bash

echo -e "alias log='cat /init_assets/dble-test-suite/behave_dble/logs/behave_debug.log'" >> /root/.bashrc
echo -e "alias db='vim /opt/dble/conf/db.xml'" >> /root/.bashrc
echo -e "alias user='vim /opt/dble/conf/user.xml'" >> /root/.bashrc
echo -e "alias sharding='vim /opt/dble/conf/sharding.xml'" >> /root/.bashrc
echo -e "alias boot='vim /opt/dble/conf/bootstrap.cnf'" >> /root/.bashrc
echo -e "alias cluster='vim /opt/dble/conf/cluster.cnf'" >> /root/.bashrc
echo -e "alias catdb='cat /opt/dble/conf/db.xml'" >> /root/.bashrc
echo -e "alias catuser='cat /opt/dble/conf/user.xml'" >> /root/.bashrc
echo -e "alias catsharding='cat /opt/dble/conf/sharding.xml'" >> /root/.bashrc
echo -e "alias catboot='cat /opt/dble/conf/bootstrap.cnf'" >> /root/.bashrc
echo -e "alias catcluster='cat /opt/dble/conf/cluster.cnf'" >> /root/.bashrc
echo -e "alias log='cat /opt/dble/logs/dble.log'" >> /root/.bashrc
echo -e "alias wrapper='cat /opt/dble/logs/wrapper.log'" >> /root/.bashrc
echo -e "alias dblerestart='/opt/dble/bin/dble restart'" >> /root/.bashrc
echo -e "alias dblestop='/opt/dble/bin/dble stop'" >> /root/.bashrc
echo -e "alias zk='cd /opt/zookeeper/bin && ./zkCli.sh'" >> /root/.bashrc
echo -e "alias 8066='mysql -h127.0.0.1 -utest -p111111 -P8066 -Dschema1'" >> /root/.bashrc
echo -e "alias 9066='mysql -h127.0.0.1 -uroot -p111111 -P9066 -Ddble_information'" >> /root/.bashrc
echo -e "alias zw='export LANG=en_US.UTF-8 && mysql -p111111 -utest -P8066 -h127.0.0.1 -Dschema1 && set collation_database=utf8mb4_general_ci && set collation_connection=utf8mb4_general_ci && set collation_server=utf8mb4_general_ci'" >> /root/.bashrc
