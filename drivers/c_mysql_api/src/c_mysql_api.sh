#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"

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