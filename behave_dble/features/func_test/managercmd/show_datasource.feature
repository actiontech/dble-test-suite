# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yexiaoli at 2019/3/5
Feature: show_datasource

  Scenario: verify manage-cmd show @@datasource
             requirment from github issue #942 #: result should not display negative number for "ACTIVE" column,github issue #1070 #1

     Given stop mysql in host "mysql-master1"
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs"
       | sql               |
       | show @@datasource |
     Then check resultset "sql_rs" has lines with following column values
        | NAME-1 | HOST-2         |  PORT-3 | ACTIVE-5  | IDLE-6  |
        | hostM1 | 172.100.9.5   | 3306     |    0      |      0    |
    Given start mysql in host "mysql-master1"

  Scenario: github issue #1064 #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	   <dataHost balance="0" maxCon="10" minCon="10" name="ha_group1" slaveThreshold="100" >
		   <heartbeat>select user()</heartbeat>
		   <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		   </writeHost>
	   </dataHost>
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs2"
      | sql               |
      | show @@datasource |
    Then check resultset "sql_rs2" has lines with following column values
        | NAME-1 | HOST-2        |  PORT-3  | ACTIVE-5 |
        | hostM1 | 172.100.9.5   | 3306     |    1     |