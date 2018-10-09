#!/bin/bash
make clean
make
./multiQuery.o > curr.output 2>&1
`diff -wq curr.output multiQuery.output`
let asExpect=`echo $?`
echo $asExpect
exit $asExpect

