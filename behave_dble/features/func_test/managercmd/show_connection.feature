# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2018/11/6
Feature: show @@connection.sql test

  Background: prepare env
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" />
        </schema>
        <dataNode dataHost="172.100.9.1" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.1" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.1" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.1" database="db4" name="dn4" />
        <dataHost balance="0" maxCon="9" minCon="3" name="172.100.9.1" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.1:3306" user="test">
            </writeHost>
        </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4'"

  @TRIVIAL
  Scenario: query execute time <1ms #1
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose | sql                    | expect  | db       |
      | test  | 111111    | conn_0 | False   | select sleep(0.0001)   | success | schema1  |
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_A"
    Then removal result set "conn_rs_A" contains "@@connection" part
    Given sleep "2" seconds
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_B"
    Then removal result set "conn_rs_B" contains "@@connection" part
    Then check resultsets "conn_rs_A" and "conn_rs_B" are same in following columns
      |column               | column_index |
      |START_TIME          | 4              |
      |EXECUTE_TIME        | 5              |
      |SQL                  | 6              |

  @TRIVIAL
  Scenario: query execute time >1ms #2
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose  | sql               | expect  | db       |
      | test  | 111111    | conn_0 | False    | select sleep(0.1) | success | schema1   |
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_C"
    Then removal result set "conn_rs_C" contains "@@connection" part
    Given sleep "2" seconds
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_D"
    Then removal result set "conn_rs_D" contains "@@connection" part
    Then check resultsets "conn_rs_C" and "conn_rs_D" are same in following columns
      |column               | column_index |
      |START_TIME          | 4              |
      |EXECUTE_TIME        | 5              |
      |SQL                  | 6              |

  @TRIVIAL
  Scenario: multiple session with multiple query display #3
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose  | sql              | expect  | db       |
      | test  | 111111    | conn_1 | False    | select sleep(1)  | success | schema1   |
      | test  | 111111    | conn_0 | False    | select sleep(0.1)| success | schema1   |
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_E"
    Then removal result set "conn_rs_E" contains "@@connection" part
    Given sleep "2" seconds
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_F"
    Then removal result set "conn_rs_F" contains "@@connection" part
    Then check resultsets "conn_rs_E" and "conn_rs_F" are same in following columns
      |column               | column_index |
      |START_TIME          | 4              |
      |EXECUTE_TIME        | 5              |
      |SQL                  | 6              |