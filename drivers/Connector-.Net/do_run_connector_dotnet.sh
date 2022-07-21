#!/bin/bash
set -e
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
need_compare=${1-"false"}

rm -rf sql_logs
cd netdriver/
mono test.exe "run" "conf/auto_dble_test.yaml" "driver_test_manager.sql" "driver_test_client.sql"

mv sql_logs ../sql_logs
cd ../

if [ "$need_compare" = "-c" ]; then
    echo "comparing results..."
    bash compare_result.sh std_sql_logs sql_logs
fi
