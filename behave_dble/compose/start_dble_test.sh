#!/bin/bash

docker exec -it behave bash -c "cd /init_assets/dble-test-suite/behave_dble;behave -Dreset=false -Dinstall_from_local=true features/install_uninstall/install_dble.feature;behave -Ddble_conf=sql_cover_global -Dinstall_from_local=true features/sql_cover/sql_global.feature;behave -Dinstall_from_local=true features/func_test/"