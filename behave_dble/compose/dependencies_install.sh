#!/bin/bash

#file which list all dependencies
filename=${1}

for line in `cat ${filename}`
do
    pip install ${line}
done