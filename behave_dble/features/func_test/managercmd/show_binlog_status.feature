# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by Rita at 2019/5/6
Feature: show @@binlog.status

  Scenario: show @@binlog.status should query success even none of related physical database be created #1
             # source:github issue #1088
    Given delete the following xml segment
        |file         | parent         | child               |
        |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
        |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
        |sharding.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
       <schema name="schema1" sqlMaxLimit="100">
		   <globalTable shardingNode="dn1,dn2" name="test" />
	    </schema>
	    <shardingNode dbGroup="ha_group1" database="db11" name="dn1" />
	    <shardingNode dbGroup="ha_group1" database="db22" name="dn2" />
	 """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          |
      | conn_0 | False    | drop database if exists db11 |
      | conn_0 | True     | drop database if exists db22 |
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs"
      | sql                  |
      | show @@binlog.status |
    Then check resultset "sql_rs" has lines with following column values
        | Url-0 |
        | 172.100.9.5:3306 |
