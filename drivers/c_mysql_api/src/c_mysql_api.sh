#!/bin/bash
set -e
make clean
make
./c_mysql_api.o > curr.output 2>&1
echo "compare c_mysql_api's output with stand: diff -wy curr.output c_mysql_api.output"
diff -wq curr.output c_mysql_api.output
if [[ ${asExpect} -eq 0 ]]; then
    echo "test result is same with std_result, case pass !"
fi
