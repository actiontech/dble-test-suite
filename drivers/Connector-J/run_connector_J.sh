#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}/../../behave_dble/compose/docker-build-behave && bash resetReplication.sh

#restart dble
cd ${DIR}/../../behave_dble && behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

#driver java test code is compiled in connector_j.jar
cp /var/lib/go-agent/pipelines/connector_j.jar ${DIR}/target/

#do run driver test
cd ${DIR} && bash do_run_connector_J.sh connector_j.jar -c

#save logs for ci artifacts
scp -r root@dble-1:/opt/dble/logs ${DIR}/dble_logs
mv ${DIR}/sql_logs ${DIR}/dble_logs/sql_logs