#!/bin/bash
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
behave -Dreset=true -D dble_conf=template features/install_uninstall/install_dble.feature features/func_test/global_var_init/ features/func_test/load_data/  features/func_test/safety/  features/func_test/sequence/  features/func_test/sharding_func_test/  features/func_test/slow_log/  features/func_test/special/ features/func_test/sql_plan/ features/func_test/trace/  features/func_test/heartbeat/ features/func_test/metalock/