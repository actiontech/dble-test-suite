# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/9/24
  Feature: support special sql

  Scenario: can support special sql like when don't set a value for variable "@id_a" #1
#case https://github.com/actiontech/dble/issues/1650
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                             | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                              | schema1 |
      | conn_0 | False   | drop table if exists sharding_3_t1                                              | schema1 |
      | conn_0 | False   | create table sharding_2_t1(id int(4), B float(8,2))                             | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values(1,234.25),(2,67.29),(3,1.25),(12,1),(1,234.25) | schema1 |
      | conn_0 | False   | create table sharding_3_t1(id int(4), B int(4))                                 | schema1 |
      | conn_0 | False   | insert into sharding_3_t1 values (10, 1),(11, 2),(10,2)                         | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
      | conn   | toClose | sql                                                                                 | db      |
      | conn_0 | False   | select * from sharding_2_t1 a left join sharding_3_t1 c on a.id=c.id and a.id=@id_a | schema1 |
    Then check resultset "A" has lines with following column values
      | id-0 | B-1    | id-2 | B-3  |
      | 1    | 234.25 | None | None |
      | 1    | 234.25 | None | None |
      | 2    | 67.29  | None | None |
      | 3    | 1.25   | None | None |
      | 12   | 1.0    | None | None |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1 | schema1 |
      | conn_0 | False   | drop table if exists sharding_3_t1 | schema1 |


  Scenario: can support special sql like when execute a complex query after executing insert into multi-nodes query  #2
#case https://github.com/actiontech/dble/issues/1762
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect       | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                       | success      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int, code int)             | success      | schema1 |
      | conn_0 | False   | set autocommit=0                                         | success      | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values (5,5),(6,6),(7,7),(8,8) | success      | schema1 |
      | conn_0 | False   | select count(*) from sharding_4_t1 order by id           | success      | schema1 |
      | conn_0 | False   | commit                                                   | success      | schema1 |
      | conn_0 | False   | select count(*) from sharding_4_t1 order by id           | has{((4,),)} | schema1 |
      | conn_0 | False   | drop table if exists sharding_4_t1                       | success      | schema1 |



  Scenario: can support special sql like when try to pushdown the OR condition   #3
#case https://github.com/actiontech/dble/issues/1705
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <shardingTable name="s1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    <shardingTable name="s2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    <shardingTable name="s3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect       | db      |
      | conn_0 | False   | drop table if exists s1                                                 | success      | schema1 |
      | conn_0 | False   | drop table if exists s2                                                 | success      | schema1 |
      | conn_0 | False   | drop table if exists s3                                                 | success      | schema1 |
      | conn_0 | False   | create table s1(pk_id int,remark int,audit_status int,`status` int)     | success      | schema1 |
      | conn_0 | False   | create table s2(fk_store_comp_id int)                                   | success      | schema1 |
      | conn_0 | False   | create table s3(fk_store_comp_id int,audit_status int)                  | success      | schema1 |
      | conn_0 | False   | SELECT count(0) FROM( SELECT c.pk_id, c.remark FROM s1 c LEFT JOIN s2 s ON c.pk_id = s.fk_store_comp_id INNER JOIN s3 ca ON ca.fk_store_comp_id = c.pk_id WHERE c.`status` = 1 AND ( c.audit_status = 2 OR ca.audit_status = 2) ) t    | success      | schema1 |
      | conn_0 | False   | drop table if exists s1                                                 | success      | schema1 |
      | conn_0 | False   | drop table if exists s2                                                 | success      | schema1 |
      | conn_0 | False   | drop table if exists s3                                                 | success      | schema1 |


  Scenario: can support special sql like when select same column with different alias   #4
#case https://github.com/actiontech/dble/issues/1716
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <shardingTable name="s1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    <shardingTable name="s2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                               | expect  | db      |
      | conn_0 | False   | drop table if exists s1                                                                           | success | schema1 |
      | conn_0 | False   | drop table if exists s2                                                                           | success | schema1 |
      | conn_0 | False   | create table s1(id int,code int )                                                                 | success | schema1 |
      | conn_0 | False   | create table s2(id int,code int )                                                                 | success | schema1 |
      | conn_0 | False   | select * from (select a.id aid,b.id bid,a.id xid,3 mark from s1 a left join s2 b on a.id= b.id) t | success | schema1 |
      | conn_0 | False   | drop table if exists s1                                                                           | success | schema1 |
      | conn_0 | true    | drop table if exists s2                                                                           | success | schema1 |


  Scenario: can support special sql like when selecting from global table more times in xa transaction   #5
#case https://github.com/actiontech/dble/issues/1725
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2" sqlMaxLimit="100" shardingNode="dn5">
        <globalTable name="global_4_t2" shardingNode="dn1,dn2,dn3,dn4" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists global_4_t2                       | success | schema2 |
      | conn_0 | False   | create table `global_4_t2` (`id` int(11) DEFAULT NULL) | success | schema2 |
      | conn_0 | False   | set autocommit=0                                       | success | schema2 |
      | conn_0 | False   | set xa=on                                              | success | schema2 |
      | conn_0 | False   | delete from global_4_t2                                | success | schema2 |
      | conn_0 | False   | commit                                                 | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | true    | insert into global_4_t2 values (1)                     | success | schema2 |
      | conn_0 | False   | drop table if exists global_4_t2                       | success | schema2 |

