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
      | schema.xml | {'tag':'root'} | {'tag':'dataHost'} |
    Given add xml segment to node with attribute "{'tag':'root','prev':'dataNode'}" in "schema.xml"
    """
    <dataNode name="dn1" dataHost="ha_group1" database="db1"/>
    <dataNode name="dn2" dataHost="ha_group1" database="db2"/>
    <dataNode name="dn3" dataHost="ha_group1" database="db3"/>
    <dataNode name="dn4" dataHost="ha_group1" database="db4"/>
    <dataNode name="dn5" dataHost="ha_group1" database="db5"/>
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
    <readHost host="hostS1" url="172.100.9.6:3306" password="errpwd" user="test"/>
    </writeHost>
    </dataHost>
    """
    # 不加-s后端不可用会终止reload的执行并返回报错
    Then execute admin cmd "reload @@config_all" get the following output
    """
    there are some datasource connection failed, pls check these datasource:{DataHost[ha_group1.hostS1]}
    """
    Given record current dble log line number in "log_linenu"
    # 加-s后端连接不可用时不会终止reload的执行，只会在日志中输出相关错误信息
    Then execute admin cmd "reload @@config_all -s"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    there are some datasource connection failed, pls check these datasource:{DataHost\[ha_group1.hostS1\]}
    """

    Given add xml segment to node with attribute "{'tag':'root','prev':'dataNode'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
    <readHost host="hostS1" url="172.100.9.6:3306" password="111111" user="test"/>
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -s"
