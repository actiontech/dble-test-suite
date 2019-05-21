#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.

#file which list all dependencies
filename=${1}

for line in `cat ${filename}`
do
    pip install ${line}
done