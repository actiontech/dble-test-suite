#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

cd ../../behave_dble/compose/docker-build-behave && bash resetReplication.sh

#restart dble
behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

cp ../java-interface/JDBCInterfaceTest/sys.config .
java -jar jdbc_api_test.jar

scp -r root@dble-1:/opt/dble/logs ../../dble_logs