#!/bin/bash
set -e
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

dble_version=$1

DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}/../../behave_dble/compose/docker-build-behave && bash resetReplication.sh

#restart dble
ssh root@behave "cd /var/lib/go-agent/pipelines/autotest-dble-${dble_version}/behave_dble;pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature;chown -R go:go dble_conf/sql_cover_sharding;chown -R go:go logs"

#compile code
cd ${DIR}/src && g++ *.cpp -l mysqlcppconn -l yaml-cpp

#do run cpp driver test
cd ${DIR} && bash do_run_connector_cpp.sh -c