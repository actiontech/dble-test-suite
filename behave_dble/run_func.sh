#!/bin/bash
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
behave -Dreset=false -D dble_conf=template features/install_uninstall/install_dble.feature features/func_test/cfg_test/charset.feature features/func_test/cfg_test/dataNode_caseSensitive.feature features/func_test/cfg_test/lower_case_table_names.feature features/func_test/sharding_func_test features/func_test/ddl features/func_test/xa_transaction