#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}/../../../behave_dble/compose/docker-build-behave && bash resetReplication.sh

#restart dble
cd ${DIR}/../../../behave_dble&&pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

#compile multiquery code
cd ${DIR} && make clean && make

#run multiquery cases
cd ${DIR} && ./multiQuery.o > curr.output 2>&1

#do result compare
echo "compare multiQuery's output with stand: diff -wy curr.output multiQuery.output"
asExpect=$( diff -wq curr.output multiQuery.output )
if [[ $? -eq 0 ]]; then
    echo "test result is same with std_result, case pass !"
    exit 0
else
    echo ${asExpect}
    exit 1
fi
