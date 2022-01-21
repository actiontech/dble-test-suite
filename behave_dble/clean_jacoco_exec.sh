#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
#for code coverage, clean up the dble_jacoco.exec for every new ci instance runs

dble_install=("dble-1" "dble-2" "dble-3")
count=${#dble_install[@]}
for((i=0; i<count; i=i+1)); do
	echo "clean up dble_jacoco.exec in ${dble_install[$i]}"
	ssh root@${dble_install[$i]}  "rm -rf /opt/dble_jacoco.exec" \
	&& sleep 2s
done
