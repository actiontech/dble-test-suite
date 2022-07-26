#!/bin/bash
#config zookeeper's myid
dble_install=("dble-1" "dble-2" "dble-3")
for((i=0; i<3; i=i+1)); do
  myid=`expr ${i} + 1`
  docker exec -it ${dble_install[$i]}  bash -c "echo '${myid}'> /opt/zookeeper/data/myid"
done