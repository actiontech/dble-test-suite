# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/11/30

Feature: check mysql is stop,but set xxx route to the first alive dataNode to check grammer success

  @restore_mysql_service
  Scenario: set xxx route to the first alive dataNode to check grammer success #case from github:1434 #1
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete the following xml segment
      | file       | parent           | child               |
      | schema.xml | {'tag':'root'}   | {'tag':'schema'}    |
      | schema.xml | {'tag':'root'}   | {'tag':'dataNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="-1">
        <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two" />
    </schema>
    <schema name="schema2" sqlMaxLimit="-1">
        <table name="sharding_1_t1" dataNode="dn2" />
    </schema>

    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db1" name="dn2" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
      <user name="test">
         <property name="password">111111</property>
         <property name="schemas">schema1,schema2</property>
      </user>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                    | expect  | db      |
      | conn_0 | False   | set sql_select_limit=3 | success | schema1 |
      | conn_1 | False   | set sql_select_limit=3 | success | schema2 |
    Given stop mysql in host "mysql-master1"
#case mysql stop,but has alive dataNode
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                    | expect  | db      |
      | conn_0 | False   | set sql_select_limit=3 | success | schema1 |
      | conn_1 | False   | set sql_select_limit=3 | success | schema2 |
    Given start mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                    | expect  | db      |
      | conn_0 | true   | set sql_select_limit=3 | success | schema1 |
      | conn_1 | true   | set sql_select_limit=3 | success | schema2 |
