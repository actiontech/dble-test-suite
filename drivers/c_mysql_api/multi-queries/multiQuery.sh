#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
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
