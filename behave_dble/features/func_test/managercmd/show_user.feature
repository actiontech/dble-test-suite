# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2019/8/27
Feature: test show user related manager command

  @NORMAL
  Scenario: test "show @@user"，"show @@user.privilege" #1
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema dataNode="dn1" name="schema2" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="sharding_4_t1" rule="hash-four" />
            <table dataNode="dn1,dn2,dn3,dn4" name="sharding_4_t2" rule="hash-four" />
        </schema>
     """
      Then execute admin cmd "reload @@config_all"
      Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"

      """
      <user name="test1">
           <property name="password">123456</property>
           <property name="maxCon">40</property>
           <property name="readOnly">false</property>
           <property name="schemas">schema,schema2</property>
           <privileges check="true">
                <schema name="schema" dml="0111" >
                        <table name="test" dml="0000"></table>
                        <table name="sharding_4_t1" dml="1111"></table>
                </schema>
                <schema name="schema2" dml="0101" >
                        <table name="sharding_4_t1" dml="1001"></table>
                </schema>
           </privileges>
      </user>
      """
       Then execute admin cmd "reload @@config_all"
       Given execute single sql in "dble-1" in "admin" mode and save resultset in "user_rs_A"
         | sql         |
         | show @@user |
       Then check resultset "user_rs_A" has lines with following column values
      | Username-0 | Manager-1  | Readonly-2   | Max_con-3    |
      |    test1        | N         | N         | 40      |
       Given execute single sql in "dble-1" in "admin" mode and save resultset in "userPrivilege_rs_A"
         | sql                   |
         | show @@user.privilege |
       Then check resultset "userPrivilege_rs_A" has lines with following column values
      | Username-0 | Schema-1  | Table-2       | INSERT-3    | UPDATE-4   | SELECT-5 | DELETE-6  |
      |    test1   | schema    | test          | N           | N          | N        | N         |
      |    test1   | schema    | sharding_4_t1 | Y           | Y          | Y        | Y         |
      |    test1   | schema2   | sharding_4_t1 | Y           | N          | N        | Y         |
      |    test1   | schema2   | *             | N           | Y          | N        | Y         |
       Given execute single sql in "dble-1" in "admin" mode and save resultset in "help_rs_A"
         | sql         |
         | show @@help |
       Then check resultset "help_rs_A" has lines with following column values
      | STATEMENT-0             | DESCRIPTION-1                                      |
      | show @@user             | Report all user in this dble                       |
      | show @@user.privilege   | Report privilege of all business user in this dble |