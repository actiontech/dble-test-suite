#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
need_compare=${1-"false"}

rm -rf sql_logs

cd src
./a.out "" "conf/auto_dble_test.yaml" "driver_test_client.sql" "driver_test_manager.sql"

mv sql_logs ../sql_logs
cd ../
if [ "$need_compare" = "-c" ]; then
    echo "comparing results..."
    bash compare_result.sh std_sql_logs sql_logs
fi
