# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2019/11/15
#2.19.11.0#dble-7850
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
    Then execute admin cmd "reload @@config_all -s"
    Then execute admin cmd "reload @@config_all" get the following output
    """
    there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group1.hostS1]}
    """

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
