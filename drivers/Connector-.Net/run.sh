#!/bin/bash

need_compare=${1-"false"}

cd netdriver/
mono test.exe "run" "Properties/auto_dble_test.yaml" "driver_test_manager.sql" "driver_test_client.sql"

mv sql_logs ../sql_logs
cd ../

if [ "$need_compare" = "-c" ]; then
    echo "comparing results..."
    bash compare_result.sh std_sql_logs sql_logs
fi
