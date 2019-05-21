#!/bin/bash
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
(bash resetReplication.sh && \
cd ../ && \
behave -Dreset=false -D dble_conf=template features/install_uninstall/install_dble.feature features/func_test && \
behave -Dreinstall=true -Dis_cluster=true features/install_uninstall/single_dble_and_zk_cluster.feature features/install_uninstall/install_dble_cluster.feature features/cluster/ \
features/install_uninstall/stop_dble_cluster.feature) | tee -a fun_and_zk.log
