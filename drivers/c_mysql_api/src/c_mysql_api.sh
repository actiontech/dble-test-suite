#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}/../../../behave_dble/compose/docker-build-behave && bash resetReplication.sh

#restart dble
cd ${DIR}/../../../behave_dble&&pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

#compile code
cd ${DIR} && make clean && make

#run cases
cd ${DIR} && ./c_mysql_api.o > curr.output 2>&1

#do result compare
echo "compare c_mysql_api's output with stand: diff -wy curr.output c_mysql_api.output"
asExpect=$(diff -wq curr.output c_mysql_api.output)
if [[ $? -eq 0 ]]; then
    echo "test result is same with std_result, case pass !"
    exit 0
else
    echo ${asExpect}
    exit 1
fi