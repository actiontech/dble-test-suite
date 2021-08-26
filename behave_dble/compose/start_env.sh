#!/bin/bash

base_dir=$( dirname ${BASH_SOURCE[0]} )
echo ${base_dir}

mkdir /opt/behave/
#cd /opt/behave/ && git clone https://github.com/actiontech/dble-test-suite.git
cd /opt/behave/ && git clone git@github.com:actiontech/dble-test-suite.git
cd /opt/behave/dble-test-suite/behave_dble/compose/
docker network create -d bridge --ipv6 --subnet "2001:3984:3989::/64" --gateway "2001:3984:3989::1" --gateway 172.100.9.253 --subnet 172.100.9.0/24 dble_test
docker-compose -f docker-compose.yml up -d --force

mysql_install=("mysql" "mysql-master1" "mysql-master2" "dble-1" "dble-2" "dble-3" "mysql8-master1" "mysql8-master2" "mysql8-slave1" "mysql8-slave2")
count=${#mysql_install[@]}
for((i=0; i<count; i=i+1)); do
    docker cp ${base_dir}/dbdeployer_deploy_mysql.sh ${mysql_install[$i]}:/docker-build/
done

docker exec -it behave bash "/init_assets/dble-test-suite/behave_dble/compose/docker-build-behave/init_test_env.sh"

/bin/bash