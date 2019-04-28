#!/bin/bash

docker-compose up -d

docker cp ~/.ssh/id_rsa.pub dble-1:/root/.ssh/authorized_keys
docker cp ~/.ssh/id_rsa.pub dble-2:/root/.ssh/authorized_keys
docker cp ~/.ssh/id_rsa.pub dble-3:/root/.ssh/authorized_keys
docker cp ~/.ssh/id_rsa.pub mysql:/root/.ssh/authorized_keys
docker cp ~/.ssh/id_rsa.pub mysql-master1:/root/.ssh/authorized_keys
docker cp ~/.ssh/id_rsa.pub mysql-master2:/root/.ssh/authorized_keys
docker cp ~/.ssh/id_rsa.pub driver-test:/root/.ssh/authorized_keys

nohup docker exec dble-1 sh -c "/usr/sbin/sshd -D" &
nohup docker exec dble-2 sh -c "/usr/sbin/sshd -D" &
nohup docker exec dble-3 sh -c "/usr/sbin/sshd -D" &
nohup docker exec mysql sh -c "/usr/sbin/sshd -D" &
nohup docker exec mysql-master1 sh -c "/usr/sbin/sshd -D" &
nohup docker exec mysql-master2 sh -c "/usr/sbin/sshd -D" &
nohup docker exec driver-test sh -c "/etc/init.d/ssh start" &
