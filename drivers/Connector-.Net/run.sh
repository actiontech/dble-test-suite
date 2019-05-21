#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
need_compare=${1-"false"}

rm -rf sql_logs
cd netdriver/
mono test.exe "run" "Properties/auto_dble_test.yaml" "driver_test_manager.sql" "driver_test_client.sql"

mv sql_logs ../sql_logs
cd ../

if [ "$need_compare" = "-c" ]; then
    echo "comparing results..."
    bash compare_result.sh std_sql_logs sql_logs
fi
