#!/bin/bash
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
behave -Dreinstall=true -Dis_cluster=true features/install_uninstall/single_dble_and_zk_cluster.feature features/install_uninstall/install_dble_cluster.feature features/install_uninstall/stop_dble_cluster.feature