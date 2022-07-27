#!/bin/bash
#config zookeeper's myid
dble_install=("dble-1" "dble-2" "dble-3")
for((i=0; i<3; i=i+1)); do
  myid=`expr ${i} + 1`
  #docker的-t参数会为输出添加一个伪终端Allocate a pseudo-TTY ,导致ci无法捕获结果
  docker exec -i ${dble_install[$i]}  bash -c "echo '${myid}'> /opt/zookeeper/data/myid"
done