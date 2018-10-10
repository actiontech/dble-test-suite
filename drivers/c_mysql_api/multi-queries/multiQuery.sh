#!/bin/bash
set -e
make clean
make
./multiQuery.o > curr.output 2>&1
echo "compare multiQuery's output with stand: diff -wy curr.output multiQuery.output"
diff -wq curr.output multiQuery.output
if [[ ${asExpect} -eq 0 ]]; then
    echo "test result is same with std_result, case pass !"
fi

