#!/bin/bash

mkdir /opt/behave/
cd /opt/behave/ && git clone https://github.com/actiontech/dble-test-suite.git
cd /opt/behave/dble-test-suite/behave_dble/compose/
docker network create --gateway 172.100.9.8 --subnet 172.100.9.0/24 dble_test
docker-compose -f docker-compose.yml up -d --force

/bin/bash