# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/15
#2.19.11.0#dble-7850
# -s 在测试链接阶段，后端链接不可用时不会终止reload的执行，只会在日志中输出相关错误信息。默认不加此参数时遇到后端不可用的情况，会终止reload的执行并返回报错。
Feature: reload @@config_all -s

  Scenario: execute manager cmd "reload @@config_all -s" after change user of dbInstance and password of dbInstance #1
    Given delete the following xml segment
      | file       | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'dbGroup'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode name="dn1" dbGroup="ha_group1" database="db1"/>
    <shardingNode name="dn2" dbGroup="ha_group1" database="db2"/>
    <shardingNode name="dn3" dbGroup="ha_group1" database="db3"/>
    <shardingNode name="dn4" dbGroup="ha_group1" database="db4"/>
    <shardingNode name="dn5" dbGroup="ha_group1" database="db5"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup name="ha_group1" rwSplitMode="0" delayThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM1" url="172.100.9.5:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true" readWeight="1">
        </dbInstance>
        <dbInstance name="hostS1" url="172.100.9.6:3306" user="test" password="errpwd" maxCon="1000" minCon="10" readWeight="2">
        </dbInstance>
    </dbGroup>
    """
    # 不加-s后端不可用会终止reload的执行并返回报错
    Then execute admin cmd "reload @@config_all" get the following output
    """
    there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostS1]}
    """
    Given record current dble log line number in "log_linenu"
    # 加-s后端连接不可用时不会终止reload的执行，只会在日志中输出相关错误信息
    Then execute admin cmd "reload @@config_all -s"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    there are some dbInstance connection failed, pls check these dbInstance:{dbInstance\[ha_group1.hostS1\]}
    """
    # 3.22.07开始，本次执行reload因配置未发生变更所以执行成功
    Then execute admin cmd "reload @@config_all"

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup name="ha_group1" rwSplitMode="0" delayThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM1" url="172.100.9.5:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true" readWeight="1">
        </dbInstance>
        <dbInstance name="hostS1" url="172.100.9.6:3306" user="test" password="111111" maxCon="1000" minCon="10" readWeight="2">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -s"
