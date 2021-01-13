#!/bin/bash
echo -e "alias log='cat /init_assets/dble-test-suite/behave_dble/logs/behave_debug.log'" >> /root/.bashrc
echo -e "alias logs='tail -f /init_assets/dble-test-suite/behave_dble/logs/behave_debug.log'" >> /root/.bashrc
echo -e "alias zk='cd /init_assets/dble-test-suite/behave_dble && behave -Dreset=false -Dis_cluster=true features/install_uninstall/install_dble_cluster.feature'" >> /root/.bashrc
echo -e "alias dble='cd /init_assets/dble-test-suite/behave_dble && behave -Dreset=false features/install_uninstall/install_dble.feature'" >> /root/.bashrc
