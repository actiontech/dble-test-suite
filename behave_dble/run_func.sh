#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
behave -Dreset=false -D dble_conf=template -f allure_behave.formatter:AllureFormatter -o report1 features/install_uninstall/install_dble.feature features/func_test;test ${PIPESTATUS[0]} -eq 0
if [ $? -ne 0 ]; then
    echo "testCases failed, please check result detail at 'http://10.186.18.19:8082/index.html' !"
    exit 1
else
    echo "testCases success, please check result detail at 'http://10.186.18.19:8082/index.html' !"
fi
