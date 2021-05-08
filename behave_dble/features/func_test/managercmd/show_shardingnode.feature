# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/04/15

Feature: test with show @@shardingnode

   Scenario: add/delete shardingNode/db_Group  &&  execute show @@shardingNode(s) [ where ... ]   #1

     #CASE1 show @@shardingNode
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
       | conn   | toClose | sql                        | db               |
       | conn_0 | False   | show @@shardingNode        | dble_information |
     Then check resultset "A" has lines with following column values
       | NAME-0 | DB_GROUP-1      | SCHEMA_EXISTS-2 |SIZE-5   |
       | dn1    | ha_group1/db1   | true            | 1000    |
       | dn2    | ha_group2/db1   | true            |1000     |
       | dn3    | ha_group1/db2   | true            | 1000    |
       | dn4    | ha_group2/db2   | true            | 1000    |
       | dn5    | ha_group1/db3   | true            | 1000    |

     #CASE2 add new shardingNode &&  show @@shardingNode
     Given delete the following xml segment
       |file          | parent          | child                   |
       |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}        |
       |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
     <schema shardingNode="dn6" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
     </schema>

     <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
     <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
     <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
     <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
     <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
     """
     Then execute admin cmd "reload @@config_all"
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
       | conn   | toClose  | sql                        | db               |
       | conn_0 | False    | show @@shardingNode        | dble_information |
     Then check resultset "B" has lines with following column values
       | NAME-0 | DB_GROUP-1        | SCHEMA_EXISTS-2 |SIZE-5     |
       | dn1    | ha_group1/db1     | true            |  1000     |
       | dn2    | ha_group2/db1     | true            |  1000     |
       | dn3    | ha_group1/db2     | true            |  1000     |
       | dn4    | ha_group2/db2     | true            |  1000     |
       | dn6    | ha_group2/db3     | true            |  1000     |

     #CASE add new db_group  && execute show @@shardingNode
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     """
     Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
     <schema shardingNode="dn7" name="schema2" sqlMaxLimit="100"/>
     <shardingNode dbGroup="ha_group3" database="db4" name="dn7"/>
     """
     Then execute admin cmd "reload @@config_all"
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
       | conn   | toClose  | sql                        | db               |
       | conn_0 | False    | show @@shardingNode        | dble_information |
     Then check resultset "C" has lines with following column values
       | NAME-0 | DB_GROUP-1      | SCHEMA_EXISTS-2 |SIZE-5   |
       | dn1  | ha_group1/db1     | true            |1000     |
       | dn2  | ha_group2/db1     | true            |1000     |
       | dn3  | ha_group1/db2     | true            |1000     |
       | dn4  | ha_group2/db2     | true            |1000     |
       | dn6  | ha_group2/db3     | true            |1000     |
       | dn7  | ha_group3/db4     | true            |1000     |

     #CASE show @@shardingNodes where schema=? and table=?;
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "D"
       | conn   | toClose  | sql                                                                 | db               |
       | conn_0 | False    | show @@shardingNodes where schema = schema1 and table = test        | dble_information |
     Then check resultset "D" has lines with following column values
       | NAME-0 | SEQUENCE-1 | HOST-2        | PORT-3 | PHYSICAL_SCHEMA-4 | USER-5 | PASSWORD-6 |
       | dn1    | 0          | 172.100.9.5   | 3306   | db1               | test   | 111111     |
       | dn2    | 1          | 172.100.9.6   | 3306   | db1               | test   | 111111     |
       | dn3    | 2          | 172.100.9.5   | 3306   | db2               | test   | 111111     |
       | dn4    | 3          | 172.100.9.6   | 3306   | db2               | test   | 111111     |

     #CASE show @@shardingNode where schema=?
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "E"
       | conn   | toClose  | sql                                               | db               |
       | conn_0 | False    | show @@shardingNode  where schema = schema2       | dble_information |
     Then check resultset "E" has lines with following column values
       | NAME-0 | DB_GROUP-1      | SCHEMA_EXISTS-2 |SIZE-5     |
       | dn7    | ha_group3/db4   | true            |1000       |





















