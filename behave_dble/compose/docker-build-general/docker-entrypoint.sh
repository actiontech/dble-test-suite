#!/bin/bash
echo $1 >/tmp/zhjtest.log
if [ "$1" = "dble" ]; then
    echo "$2"> /opt/zookeeper/data/myid
fi

if [ "$1" = "mysql" -o "$1" = "dble" ]; then
    sed -i "/server-id=/c server-id=$2" /etc/my.cnf
fi

exec /usr/sbin/sshd -D