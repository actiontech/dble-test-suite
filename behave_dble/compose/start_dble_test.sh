#!/bin/bash

docker exec -it behave bash -c "cd /init_assets/dble-test-suite/behave_dble;behave -Dreset=false -Dinstall_from_local=true -Dtest_config=auto_test_dble_release.yaml features/install_uninstall/install_dble.feature;behave -Ddble_conf=sql_cover_global -Dtest_config=auto_test_dble_release.yaml features/sql_cover/sql_global.feature;behave -Dtest_config=auto_test_dble_release.yaml features/func_test/"