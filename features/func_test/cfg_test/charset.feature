# -*- coding=utf-8 -*-
# Created by zhaohongjie at 2018/10/8
Feature: set charset in server.xml,check backend charsets are as set
  backend charsets info get via "show @@backend", resultset of column: CHARACTER_SET_CLIENT, COLLATION_CONNECTION,CHARACTER_SET_RESULTS
  front connection charset is not controlled by server.xml property charset,
  but verify the default value here for convenient.

  @BLOCKER
  Scenario: set dble config charset same or different to session charset, session charset priorier to config charset #1
    #   1.1 set backend charset utf8, front charset utf8;
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <system>
         <property name="charset">utf-8</property>
     </system>
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <dataHost maxCon="100" minCon="10" name="172.100.9.6" balance="1" switchType="-1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
                <readHost host="hosts1" url="172.100.9.2:3306" user="test" password="111111"/>
                <readHost host="hosts2" url="172.100.9.3:3306" user="test" password="111111"/>
            </writeHost>
        </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then get resultset of admin cmd "show @@backend" named "backend_rs_A"
    Then check resultset "backend_rs_A" has lines with following column values
      | HOST-3      | CHARACTER_SET_CLIENT-13 | COLLATION_CONNECTION-14 | CHARACTER_SET_RESULTS-15 |
      | 172.100.9.6 |     utf8                | utf8_general_ci         | utf8                     |
      | 172.100.9.2 |     utf8                | utf8_general_ci         | utf8                     |
      | 172.100.9.3 |     utf8                | utf8_general_ci         | utf8                     |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                         | expect  | db     |charset|
      | test | 111111  | conn_0 | False   | drop table if exists aly_test               | success | mytest | utf8  |
      | test | 111111  | conn_0 | False   | create table aly_test(id int, name char(10)) default charset=utf8| success | mytest | utf8  |
      | test | 111111  | conn_0 | False   | insert into aly_test value(1, '中')         | success | mytest | utf8  |
      | test | 111111  | conn_0 | False   | select name from aly_test                   | has{('中')}| mytest | utf8  |
      | test | 111111  | conn_0 | False   | set names utf8                              | success | mytest | utf8  |
    Then get resultset of admin cmd "show @@connection" named "conn_rs_A"
    Then check resultset "conn_rs_A" has lines with following column values
      | CHARACTER_SET_CLIENT-7 | COLLATION_CONNECTION-8 | CHARACTER_SET_RESULTS-9 |
      |    utf8                | utf8_general_ci        | utf8                    |
    #   1.2 set backend charset latin1, front charset default latin1;
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <system>
     <property name="charset">latin1</property>
     </system>
     """
    Given Restart dble in "dble-1" success
    Then get resultset of admin cmd "show @@backend" named "backend_rs_B"
    Then check resultset "backend_rs_B" has not lines with following column values
      | HOST-3      | CHARACTER_SET_CLIENT-13 | COLLATION_CONNECTION-14 | CHARACTER_SET_RESULTS-15 |
      | 172.100.9.6 |     utf8                | utf8_general_ci         | utf8                     |
      | 172.100.9.2 |     utf8                | utf8_general_ci         | utf8                     |
      | 172.100.9.3 |     utf8                | utf8_general_ci         | utf8                     |
    Then check resultset "backend_rs_B" has lines with following column values
      | HOST-3      | CHARACTER_SET_CLIENT-13 | COLLATION_CONNECTION-14 | CHARACTER_SET_RESULTS-15 |
      | 172.100.9.6 |     latin1              | latin1_swedish_ci       | latin1                   |
      | 172.100.9.2 |     latin1              | latin1_swedish_ci       | latin1                   |
      | 172.100.9.3 |     latin1              | latin1_swedish_ci       | latin1                   |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd  | conn   | toClose | sql                                         | expect  | db     |
        | test | 111111  | conn_1 | False   | drop table if exists aly_test               | success | mytest |
        | test | 111111  | conn_1 | False   | create table aly_test(id int, name char(10)) default charset=utf8| success | mytest |
        | test | 111111  | conn_1 | False   | insert into aly_test value(1, '中')         | ordinal not in range | mytest |
    Then get resultset of admin cmd "show @@connection" named "conn_rs_B"
    Then check resultset "conn_rs_B" has lines with following column values
      | CHARACTER_SET_CLIENT-7 | COLLATION_CONNECTION-8 | CHARACTER_SET_RESULTS-9 |
      |    latin1              | latin1_swedish_ci      | latin1                  |
    #   1.3 set backend charset latin1, but set front charset utf8 to indirectly change used backend charset;
    Then execute sql in "dble-1" in "user" mode
        | user | passwd  | conn   | toClose | sql                                 | expect  | db     |charset|
        | test | 111111  | conn_2 | False   | insert into aly_test value(1, '中') | success | mytest |utf8  |
        | test | 111111  | conn_2 | True    | select name from aly_test           | has{('中')} | mytest |utf8  |