#!/bin/bash

docker network create --gateway 172.100.9.253 --subnet 172.100.9.0/24 dble_test
docker-compose -f docker-compose.yml up -d --force
docker exec driver-test sh -c "/etc/init.d/ssh start"
docker exec -it behave bash "/docker-build/init_test_env.sh"

/bin/bash