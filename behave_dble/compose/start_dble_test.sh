#!/bin/bash

docker exec -it behave bash -c "cd /init_assets/dble-test-suite-master/behave_dble;behave -Ddble_conf=sql_cover_global features/sql_cover/sql_global.feature;behave features/install_uninstall/install_dble.feature;behave features/func_test/"