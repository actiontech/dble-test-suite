#!/bin/bash
SUBNET="172.100.9"

cat << EOF
version: '2'
networks:
    net:
        driver: bridge
        ipam:
            driver: default
            config:
                - subnet: ${SUBNET}.0/24
                  gateway: ${SUBNET}.253
services:
EOF
NAME=uproxy.centos7-1
cat <<EOF
    ${NAME}:
        image: docker-registry:5000/actiontech/balm-runtime-centos7 
        container_name: ${NAME}
        hostname: ${NAME}
        privileged: true
        stdin_open: true
        tty: true
        volumes:
            - /lib/modules/$(uname -r):/lib/modules/$(uname -r)
        ports:
            - "7120:1234"
        networks:
            net:
              ipv4_address: ${SUBNET}.1

EOF
NAME=uproxy.centos6-1
cat <<EOF
    ${NAME}:
        image: docker-registry:5000/actiontech/balm-runtime-centos6
        container_name: ${NAME}
        hostname: ${NAME}
        privileged: true
        stdin_open: true
        tty: true
        volumes:
            - /lib/modules/$(uname -r):/lib/modules/$(uname -r)
        ports:
            - "7121:1234"
        networks:
            net:
              ipv4_address: ${SUBNET}.2
EOF
NAME=uproxy.mysql
cat <<EOF
    ${NAME}:
        image: docker-registry:5000/actiontech/centos7-mysqlsandbox
        container_name: ${NAME}
        hostname: ${NAME}
        privileged: true
        stdin_open: true
        tty: true
        ports:
            - "7122:5713"
        networks:
            net:
              ipv4_address: ${SUBNET}.3

EOF
NAME=uproxy.mysql-replication
cat <<EOF
    ${NAME}:
        image: docker-registry:5000/actiontech/centos7-mysqlsandbox
        container_name: ${NAME}
        hostname: ${NAME}
        privileged: true
        stdin_open: true
        tty: true
        ports:
            - "7123:19388"
            - "7124:19389"
            - "7125:19390"
        networks:
            net:
              ipv4_address: ${SUBNET}.4
EOF