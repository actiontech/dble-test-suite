#!/bin/bash
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

echo '=======                 restore the running environment              ======='
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd ${DIR}/../../behave_dble/compose/docker-build-behave && bash resetReplication.sh

echo '=======           restart dble with sql_cover_sharding               ======='
cd ${DIR}/../../behave_dble && pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

echo '=======                       compile                                ======='
cd ${DIR}/netdriver && csc -out:test.exe -r:MySql.Data.dll -r:YamlDotNet.dll *.cs

echo '=======                        driver test                           ======='
cd ${DIR} && source do_run_connector_dotnet.sh -c
if [ ${#res} -gt 0 ]; then
    echo "Oop! results are different with the standard ones, try 'diff -qwr ${cmp_std_res_dir}/.../file1 ${cmp_real_res_dir}/.../file2' to see the details"
    echo "${res}"
     #save logs for ci artifacts
    scp -r root@dble-1:/opt/dble/logs ${DIR}/dble_logs
    mv ${DIR}/sql_logs ${DIR}/dble_logs/sql_logs
    exit 1
else
    echo "pass"
     #save logs for ci artifacts
    scp -r root@dble-1:/opt/dble/logs ${DIR}/dble_logs
    mv ${DIR}/sql_logs ${DIR}/dble_logs/sql_logs
    exit 0
fi
