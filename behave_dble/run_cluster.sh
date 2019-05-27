#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
behave -Dreinstall=true -Dis_cluster=true -f allure_behave.formatter:AllureFormatter -o report2 features/install_uninstall/single_dble_and_zk_cluster.feature features/install_uninstall/install_dble_cluster.feature features/cluster/ features/install_uninstall/stop_dble_cluster.feature;test ${PIPESTATUS[0]} -eq 0
if [ $? -ne 0 ]; then
    echo "testCases failed, please check result detail at 'http://10.186.18.19:8082/index.html' !"
    exit 1
else
    echo "testCases success, please check result detail at 'http://10.186.18.19:8082/index.html' !"
fi
