#!/bin/bash

mkdir /opt/behave/
cd /opt/behave/ && git clone https://github.com/actiontech/dble-test-suite.git
cd /opt/behave/dble-test-suite/behave_dble/compose/
#docker network create --gateway 172.100.9.253 --subnet 172.100.9.0/24 dble_test
docker network create -d bridge --ipv6 --subnet "2001:3984:3989::/64" --gateway "2001:3984:3989::1" --gateway 172.100.9.253 --subnet 172.100.9.0/24 dble_test
docker-compose -f docker-compose.yml up -d --force
docker exec driver-test sh -c "/etc/init.d/ssh start"
docker exec -it behave bash "/init_assets/dble-test-suite/behave_dble/compose/docker-build-behave/init_test_env.sh"

/bin/bash