# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/11/30

Feature: check mysql is stop,but set xxx route to the first alive shardingNode to check grammer success

  @restore_mysql_service
  Scenario: set xxx route to the first alive shardingNode to check grammer success #case from github:1434 #1
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given delete the following xml segment
      | file         | parent           | child                   |
      | sharding.xml | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml | {'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="-1">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="-1">
        <singleTable name="sharding_1_t1" shardingNode="dn2" />
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
     <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
     """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                    | expect  | db      |
      | conn_0 | False   | set sql_select_limit=3 | success | schema1 |
      | conn_1 | False   | set sql_select_limit=3 | success | schema2 |
    Given stop mysql in host "mysql-master1"
#case mysql stop,but has alive shardingnode
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                    | expect  | db      |
      | conn_0 | False   | set sql_select_limit=3 | success | schema1 |
      | conn_1 | False   | set sql_select_limit=3 | success | schema2 |
    Given start mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                    | expect  | db      |
      | conn_0 | true   | set sql_select_limit=3 | success | schema1 |
      | conn_1 | true   | set sql_select_limit=3 | success | schema2 |
