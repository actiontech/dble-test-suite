# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/7/25

Feature: #test the correctness of sql transformation

  Scenario: #test the explain result of `limit` #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                      | expect    | db     |
      | conn_0 | False    | drop table if exists sharding_4_t1                       | success   | schema1 |
      | conn_0 | False    | drop table if exists sharding_3_t1                       | success   | schema1 |
      | conn_1 | False    | drop table if exists sharding_4_t3                       | success   | schema3 |
      | conn_0 | False    | create table sharding_4_t1 (id int,c_flag char(255))     | success   | schema1 |
      | conn_0 | False    | create table sharding_3_t1 (id int,c_flag char(255))     | success   | schema1 |
      | conn_1 | True     | create table sharding_4_t3 (id int,c_flag char(255))     | success   | schema3 |
      | conn_0 | False    | explain select * from schema1.sharding_4_t1              | hasStr{'SELECT * FROM sharding_4_t1 LIMIT 100'}              | schema1 |
      | conn_0 | False    | explain select * from schema3.sharding_4_t3              | hasStr{'select * from sharding_4_t3'}                        | schema1 |
      | conn_0 | False    | explain select distinct(id) from sharding_4_t1           | hasStr{SELECT id FROM sharding_4_t1 GROUP BY id LIMIT 100'}  | schema1 |
      | conn_0 | False    | explain select 1                                         | hasStr{('dn5', 'BASE SQL', 'select 1'),}                     | schema1 |
      | conn_0 | True     | explain select * from sharding_4_t1,sharding_3_t1        | hasNoStr{LIMIT}                                              | schema1 |
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="table_a" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="table_b" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" sqlMaxLimit="-1"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                              | expect    | db      |
      | conn_0 | False    | drop table if exists table_a                     | success   | schema1 |
      | conn_0 | False    | create table table_a (id int,c_flag char(255))   | success   | schema1 |
      | conn_0 | False    | drop table if exists table_b                     | success   | schema1 |
      | conn_0 | False    | create table table_b (id int,c_flag char(255))   | success   | schema1 |
      | conn_0 | False    | explain select * from table_a where id=1         | has{('dn2', 'BASE SQL', 'select * from table_a where id=1'),}   | schema1 |
      | conn_0 | True     | explain select * from table_b                    | hasStr{('dn1', 'BASE SQL', 'select * from table_b'),}           | schema1 |
    Given update file content "/opt/dble/conf/cacheservice.properties" in "dble-1" with sed cmds
     """
      a/#layedpool.TableID2DataNodeCache=encache,10000,18000
      a/layedpool.TableID2DataNodeCacheType=encache
    """
    Then check following text exist "Y" in file "/opt/dble/conf/cacheservice.properties" in host "dble-1"
    """
    #layedpool.TableID2DataNodeCache=encache,10000,18000
    layedpool.TableID2DataNodeCacheType=encache
    """
    Then check following text exist "N" in file "/opt/dble/conf/cacheservice.properties" in host "dble-1"
    """
    #layedpool.TableID2DataNodeCacheType=encache
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect    | db     |
      | conn_0 | True    | explain select * from global_4_t1                         | hasStr{'SELECT * FROM global_4_t1 LIMIT 100'}   | schema2 |
      | conn_0 | True    | explain select * from sharding_4_t1                       | hasStr{'SELECT * FROM sharding_4_t1 LIMIT 100'}    | schema1 |
      | conn_0 | True    | explain select * from table_a where id=1                  | hasStr{'select * from table_a where id=1'}   | schema1 |
      | conn_0 | True    | explain select * from table_a where c_flag=1              | hasStr{'SELECT * FROM table_a WHERE c_flag = 1 LIMIT 100'}   | schema1 |
      | conn_0 | True    | explain select * from table_a order by id limit 3,9       | hasStr{ASC LIMIT 12}   | schema1 |
    Given update file content "/opt/dble/conf/cacheservice.properties" in "dble-1" with sed cmds
     """
      s/#layedpool.TableID2DataNodeCache=encache,10000,18000/layedpool.TableID2DataNodeCache=encache,10000,18000/
      s/layedpool.TableID2DataNodeCacheType=encache/#layedpool.TableID2DataNodeCacheType=encache/
    """
    Then check following text exist "Y" in file "/opt/dble/conf/cacheservice.properties" in host "dble-1"
    """
    layedpool.TableID2DataNodeCache=encache,10000,18000
    #layedpool.TableID2DataNodeCacheType=encache
    """
    Then check following text exist "N" in file "/opt/dble/conf/cacheservice.properties" in host "dble-1"
    """
    #layedpool.TableID2DataNodeCache=encache,10000,18000
    """
