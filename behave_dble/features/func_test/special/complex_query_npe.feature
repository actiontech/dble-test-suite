# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2021/8/2


Feature: check complex query has not npe in dble.log   ##DBLE0REQ-1288


  Scenario: check complex query has not npe in dble.log   # 1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema2">
        <singleTable name="sing1" shardingNode="dn1" />
      </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,"/>
      """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                   | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sing1                                                   | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                    | success | schema1 |
      | conn_1 | False   | create table schema2.sing1 (id int,name char(20))                                    | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')     | success | schema1 |
      | conn_1 | true    | insert into schema2.sing1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')     | success | schema1 |


    Given delete file "/opt/dble/BtraceAboutrowEof.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutrowEof.java.log" on "dble-1"
    Given prepare a thread run btrace script "BtraceAboutrowEof.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                        | db      |
      | conn_0 | false   | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1    | schema1 |

    Given sleep "6" seconds
    Then check following text exist "Y" in file "/opt/dble/BtraceAboutrowEof.java.log" in host "dble-1"
      """
      get into way
      get into reRegister1
      get into reRegister2
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      """
    Given stop btrace script "BtraceAboutrowEof.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutrowEof.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutrowEof.java.log" on "dble-1"