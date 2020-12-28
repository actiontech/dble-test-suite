#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
DIR="$(cd "$( dirname "$0" )" && pwd)"
cd ${DIR}/../../behave_dble/compose/docker-build-behave && bash resetReplication.sh

#restart dble
cd ${DIR}/../../behave_dble && behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

cd ${DIR} && cp ../java-interface/JDBCInterfaceTest/sys.config .
cd ${DIR} && java -jar jdbc_api_test.jar

scp -r root@dble-1:/opt/dble/logs ${DIR}/dble_logs
