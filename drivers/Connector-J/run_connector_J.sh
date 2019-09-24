#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

jar_name=${1}
need_compare=${2-"false"}

echo $jar_name""

java -jar target/${jar_name} "" "conf/auto_dble_test.yaml" "driver_test_client.sql" "driver_test_manager.sql"

if [ "$need_compare" = "-c" ]; then
    echo "comparing results..."
    bash compare_result.sh std_sql_logs sql_logs
fi
