# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by Rita at 2019/5/6
Feature: show @@binlog.status

  Scenario: show @@binlog.status should query success even none of related physical database be created #1
             # source:github issue #1088
    Given delete the following xml segment
        |file         | parent         | child               |
        |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
        |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
        |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
       <schema name="schema1" sqlMaxLimit="100">
		   <table dataNode="dn1,dn2" name="test" type="global" />
	    </schema>
	    <dataNode dataHost="ha_group1" database="db11" name="dn1" />
	    <dataNode dataHost="ha_group1" database="db22" name="dn2" />
	    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" switchType="1">
		   <heartbeat>select user()</heartbeat>
		   <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		   </writeHost>
	    </dataHost>
     """
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                             | expect   |  db  |
        | test | 111111 | conn_0 | False    | drop database if exists db11 | success  |      |
        | test | 111111 | conn_0 | True     | drop database if exists db22 | success  |      |
    Then execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@binlog.status" named "sql_rs"
    Then check resultset "sql_rs" has lines with following column values
        | Url-0 |
        | 172.100.9.5:3306 |
