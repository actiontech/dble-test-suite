# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2020/12/21

Feature: test group by
  @NORMAL
  Scenario: the version of all backend mysql nodes are 5.7.* #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
          """
           <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
              <heartbeat>select user()</heartbeat>
              <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
              </dbInstance>
              <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false"/>
           </dbGroup>
          """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                   | expect                                          | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                                                                                | success                                         | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(20),age int)                                                                    | success                                         | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'a',10),(2,'c',5),(3,'b',20),(4,'d',30),(5,'aa',1),(6,'bc',86),(7,'j',24),(8,'e',60)| success                                        | schema1 |
      | conn_0 | False    | select name from sharding_4_t1 group by name                                                                                      | has{(('a',),('aa',),('b',),('bc',),('c',),('d',),('e',),('j',))}   | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'a',300),(2,'d',9),(21,'bc',102),(30,'a',23),(31,'d',24),(99,'bc',20)                  | success                                      | schema1 |
      | conn_0 | False    | select name,age from sharding_4_t1 group by name,age                                                                            | has{(('a', 10), ('a', 23), ('a', 300), ('aa', 1), ('b', 20), ('bc', 20), ('bc', 86), ('bc', 102), ('c', 5), ('d', 9), ('d', 24), ('d', 30), ('e', 60), ('j', 24))}   | schema1 |
    #1.for complex query, group by will followed by order by
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                         |
      | conn_0 | False   | explain select name from sharding_4_t1 group by name |
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn2_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn3_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn4_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0 |
      | aggregate_1        | AGGREGATE        | merge_and_order_1 |
      | limit_1            | LIMIT            | aggregate_1 |
      | shuffle_field_1   | SHUFFLE_FIELD | limit_1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                                  |
      | conn_0 | True    | explain select name,age from sharding_4_t1 group by name,age |
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn2_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn3_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn4_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                    |
      | aggregate_1       | AGGREGATE       | merge_and_order_1                                                                                                                                                                             |
      | limit_1           | LIMIT           | aggregate_1                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | limit_1                                                                                                                                                                                      |
    #2.for sharding table broadcast, group by will followed by order by
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                     | expect                                          | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                                                                                 | success                                         | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(20))                                                                              | success                                         | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,1),(21,2),(3,3),(24,4),(9,200)                                                             | success                                        | schema1 |
      | conn_0 | False    | select id from sharding_4_t1 group by id order by id                                                                            | has{((1,), (3,), (9,), (21,), (24,))}                  | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                                  |
      | conn_0 | True    | explain select id from sharding_4_t1 group by id order by id  |
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn2_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn3_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn4_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0 |
      | aggregate_1 | AGGREGATE | merge_and_order_1 |
      | limit_1 | LIMIT | aggregate_1 |
      | shuffle_field_1 | SHUFFLE_FIELD | limit_1 |
    #3.for global table,nosharding table,and known-route sql, group by will not followed by order by
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                     | expect                                          | db      |
      | conn_0 | False    | drop table if exists no_sharding                                                                                                   | success                                         | schema1 |
      | conn_0 | False    | create table no_sharding (id int, name varchar(50))                                                                             | success                                         | schema1 |
      | conn_0 | False    | insert into no_sharding values(1,'d'),(2,'c'),(13,'b'),(24,'a')                                                                | success                                        | schema1 |
      | conn_0 | False    | select name from no_sharding group by name                                                                                        | has{(('a',),('b',),('c',),('d',))}                          | schema1 |

      | conn_0 | False     | drop table if exists test                                                                                                           | success                                         | schema1 |
      | conn_0 | False     | create table test(id int, name varchar(50))                                                                                      |  success                                        | schema1 |
      | conn_0 | False     | insert into test values(1,'d'),(2,'c'),(13,'b'),(24,'a')                                                                       | success                                          | schema1  |
      | conn_0 | False     | select name from test group by name                                                                                               | has{(('a',),('b',),('c',),('d',))}            | schema1  |

      | conn_0 | False     | drop table if exists sharding_2_t1                                                                                                 | success                                         | schema1 |
      | conn_0 | False     | create table sharding_2_t1(id int, name varchar(50))                                                                             |  success                                        | schema1 |
      | conn_0 | False     | insert into sharding_2_t1 values(1,'d'),(2,'c'),(13,'b'),(24,'a'),(13,'u'),(5,'z'),(9,'w')                                 | success                                          | schema1  |
      | conn_0 | False     | /*!dble:sql=select id from sharding_2_t1 where id=1*/select name from sharding_2_t1 group by name                         | has{(('b',),('d',),('u',),('w',),('z',))}                       | schema1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                                  |
      | conn_0 | False   | explain select name from no_sharding group by name            |
    Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn5 | BASE SQL | SELECT name FROM no_sharding GROUP BY name LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                                  |
      | conn_0 | False   | explain select name from test group by name                     |
    Then check resultset "rs_E" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                    |
      | /*AllowDiff*/dn3  | BASE SQL | SELECT name FROM test GROUP BY name LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                                                                                    |
      | conn_0 | True    | explain /*!dble:sql=select id from sharding_2_t1 where id=1*/select name from sharding_2_t1 group by name|
    Then check resultset "rs_F" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                    |
      | dn2 | BASE SQL | select name from sharding_2_t1 group by name |

  @NORMAL
  Scenario: Scenario: the version of all backend mysql nodes are 8.0.* #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test" maxCon="1000" minCon="10" primary="true">
      </dbInstance>
      </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM2" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true">
      </dbInstance>
      <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="1000" minCon="10" primary="false"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                   | expect                                          | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                                                                                | success                                         | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(20),age int)                                                                    | success                                         | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'a',10),(2,'c',5),(3,'b',20),(4,'d',30),(5,'aa',1),(6,'bc',86),(7,'j',24),(8,'e',60)| success                                        | schema1 |
      | conn_0 | False    | select name from sharding_4_t1 group by name                                                                                      | has{(('a',),('aa',),('b',),('bc',),('c',),('d',),('e',),('j',))}   | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'a',300),(2,'d',9),(21,'bc',102),(30,'a',23),(31,'d',24),(99,'bc',20)                  | success                                      | schema1 |
      | conn_0 | False    | select name,age from sharding_4_t1 group by name,age                                                                            | has{(('a', 10), ('a', 23), ('a', 300), ('aa', 1), ('b', 20), ('bc', 20), ('bc', 86), ('bc', 102), ('c', 5), ('d', 9), ('d', 24), ('d', 30), ('e', 60), ('j', 24))}   | schema1 |
    #1.for complex query, group by will followed by order by
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                         |
      | conn_0 | False   | explain select name from sharding_4_t1 group by name |
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn2_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn3_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn4_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0 |
      | aggregate_1        | AGGREGATE        | merge_and_order_1 |
      | limit_1            | LIMIT            | aggregate_1 |
      | shuffle_field_1   | SHUFFLE_FIELD | limit_1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                                  |
      | conn_0 | True    | explain select name,age from sharding_4_t1 group by name,age |
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn2_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn3_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn4_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                    |
      | aggregate_1       | AGGREGATE       | merge_and_order_1                                                                                                                                                                             |
      | limit_1           | LIMIT           | aggregate_1                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | limit_1                                                                                                                                                                                      |
    #2.for sharding table broadcast, group by will followed by order by
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                     | expect                                          | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                                                                                 | success                                         | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(20))                                                                              | success                                         | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,1),(21,2),(3,3),(24,4),(9,200)                                                             | success                                        | schema1 |
      | conn_0 | False    | select id from sharding_4_t1 group by id order by id                                                                            | has{((1,), (3,), (9,), (21,), (24,))}                  | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                                  |
      | conn_0 | True    | explain select id from sharding_4_t1 group by id order by id  |
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn2_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn3_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn4_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0 |
      | aggregate_1 | AGGREGATE | merge_and_order_1 |
      | limit_1 | LIMIT | aggregate_1 |
      | shuffle_field_1 | SHUFFLE_FIELD | limit_1 |
    #3.for global table,nosharding table,and known-route sql, group by will not followed by order by
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                     | expect                                          | db      |
      | conn_0 | False    | drop table if exists no_sharding                                                                                                   | success                                         | schema1 |
      | conn_0 | False    | create table no_sharding (id int, name varchar(50))                                                                             | success                                         | schema1 |
      | conn_0 | False    | insert into no_sharding values(1,'d'),(2,'c'),(13,'b'),(24,'a')                                                                | success                                        | schema1 |
      | conn_0 | False    | select name from no_sharding group by name                                                                                        | has{(('d',),('c',),('b',),('a',))}                          | schema1 |

      | conn_0 | False     | drop table if exists test                                                                                                           | success                                         | schema1 |
      | conn_0 | False     | create table test(id int, name varchar(50))                                                                                      |  success                                        | schema1 |
      | conn_0 | False     | insert into test values(1,'d'),(2,'c'),(13,'b'),(24,'a')                                                                       | success                                          | schema1  |
      | conn_0 | False     | select name from test group by name                                                                                               | has{(('d',),('c',),('b',),('a',))}            | schema1  |

      | conn_0 | False     | drop table if exists sharding_2_t1                                                                                                 | success                                         | schema1 |
      | conn_0 | False     | create table sharding_2_t1(id int, name varchar(50))                                                                             |  success                                        | schema1 |
      | conn_0 | False     | insert into sharding_2_t1 values(1,'d'),(2,'c'),(13,'b'),(24,'a'),(13,'u'),(5,'z'),(9,'w')                                 | success                                          | schema1  |
      | conn_0 | False     | /*!dble:sql=select id from sharding_2_t1 where id=1*/select name from sharding_2_t1 group by name                         | has{(('d',),('b',),('u',),('z',),('w',))}                       | schema1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                                  |
      | conn_0 | False   | explain select name from no_sharding group by name            |
    Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn5 | BASE SQL    | SELECT name FROM no_sharding GROUP BY name LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                                  |
      | conn_0 | False   | explain select name from test group by name                     |
    Then check resultset "rs_E" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                    |
      | /*AllowDiff*/dn3  | BASE SQL | SELECT name FROM test GROUP BY name LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                                                                                    |
      | conn_0 | True    | explain /*!dble:sql=select id from sharding_2_t1 where id=1*/select name from sharding_2_t1 group by name|
    Then check resultset "rs_F" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                    |
      | dn2 | BASE SQL | select name from sharding_2_t1 group by name |

  @NORMAL
  Scenario: Scenario: the version of all backend mysql nodes are mixed with 5.7.* and 8.0.* #3
        Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test" maxCon="1000" minCon="10" primary="true">
      </dbInstance>
      </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
      </dbInstance>
      <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                   | expect                                          | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                                                                                | success                                         | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(20),age int)                                                                    | success                                         | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'a',10),(2,'c',5),(3,'b',20),(4,'d',30),(5,'aa',1),(6,'bc',86),(7,'j',24),(8,'e',60)| success                                        | schema1 |
      | conn_0 | False    | select name from sharding_4_t1 group by name                                                                                      | has{(('a',),('aa',),('b',),('bc',),('c',),('d',),('e',),('j',))}   | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'a',300),(2,'d',9),(21,'bc',102),(30,'a',23),(31,'d',24),(99,'bc',20)                  | success                                      | schema1 |
      | conn_0 | False    | select name,age from sharding_4_t1 group by name,age                                                                            | has{(('a', 10), ('a', 23), ('a', 300), ('aa', 1), ('b', 20), ('bc', 20), ('bc', 86), ('bc', 102), ('c', 5), ('d', 9), ('d', 24), ('d', 30), ('e', 60), ('j', 24))}   | schema1 |
    #1.for complex query, group by will followed by order by
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                         |
      | conn_0 | False   | explain select name from sharding_4_t1 group by name |
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn2_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn3_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | dn4_0              | BASE SQL         | select `sharding_4_t1`.`name` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name` ORDER BY `sharding_4_t1`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0 |
      | aggregate_1        | AGGREGATE        | merge_and_order_1 |
      | limit_1            | LIMIT            | aggregate_1 |
      | shuffle_field_1   | SHUFFLE_FIELD | limit_1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                                  |
      | conn_0 | True    | explain select name,age from sharding_4_t1 group by name,age |
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn2_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn3_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | dn4_0             | BASE SQL        | select `sharding_4_t1`.`name`,`sharding_4_t1`.`age` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`name`,`sharding_4_t1`.`age` ORDER BY `sharding_4_t1`.`name` ASC,`sharding_4_t1`.`age` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                    |
      | aggregate_1       | AGGREGATE       | merge_and_order_1                                                                                                                                                                             |
      | limit_1           | LIMIT           | aggregate_1                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | limit_1                                                                                                                                                                                      |
    #2.for sharding table broadcast, group by will followed by order by
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                     | expect                                          | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                                                                                 | success                                         | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int,name varchar(20))                                                                              | success                                         | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,1),(21,2),(3,3),(24,4),(9,200)                                                             | success                                        | schema1 |
      | conn_0 | False    | select id from sharding_4_t1 group by id order by id                                                                            | has{((1,), (3,), (9,), (21,), (24,))}                  | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                                  |
      | conn_0 | True    | explain select id from sharding_4_t1 group by id order by id  |
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn2_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn3_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | dn4_0 | BASE SQL | select `sharding_4_t1`.`id` from  `sharding_4_t1` GROUP BY `sharding_4_t1`.`id` ORDER BY `sharding_4_t1`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0 |
      | aggregate_1 | AGGREGATE | merge_and_order_1 |
      | limit_1 | LIMIT | aggregate_1 |
      | shuffle_field_1 | SHUFFLE_FIELD | limit_1 |
    #3.for global table,nosharding table,and known-route sql, group by will not followed by order by
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                     | expect                                          | db      |
      | conn_0 | False    | drop table if exists no_sharding                                                                                                   | success                                         | schema1 |
      | conn_0 | False    | create table no_sharding (id int, name varchar(50))                                                                             | success                                         | schema1 |
      | conn_0 | False    | insert into no_sharding values(1,'d'),(2,'c'),(13,'b'),(24,'a')                                                                | success                                        | schema1 |
      | conn_0 | False    | select name from no_sharding group by name                                                                                        | has{(('d',),('c',),('b',),('a',))}                          | schema1 |

      | conn_0 | False     | drop table if exists test                                                                                                           | success                                         | schema1 |
      | conn_0 | False     | create table test(id int, name varchar(50))                                                                                      |  success                                        | schema1 |
      | conn_0 | False     | insert into test values(1,'d'),(2,'c'),(13,'b'),(24,'a')                                                                       | success                                          | schema1  |
      | conn_0 | False     | select name from test group by name                                                                                               | length{(4)}                                     | schema1  |

      | conn_0 | False     | drop table if exists sharding_4_t1                                                                                                 | success                                         | schema1 |
      | conn_0 | False     | create table sharding_4_t1(id int, name varchar(50))                                                                             |  success                                        | schema1 |
      | conn_0 | False     | insert into sharding_4_t1 values(1,'d'),(2,'c'),(13,'b'),(24,'a'),(5,'z'),(9,'w'),(10,'r'),(6,'l')                        | success                                          | schema1  |
      | conn_0 | False     | /*!dble:sql=select id from sharding_4_t1 where id=1*/select name from sharding_4_t1 group by name                         | has{(('b',),('d',),('w',),('z',))}            | schema1  |
      | conn_0 | False     | /*!dble:sql=select id from sharding_4_t1 where id=2*/select name from sharding_4_t1 group by name                         | has{(('c',),('r',),('l',))}                   | schema1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                                  |
      | conn_0 | False   | explain select name from no_sharding group by name            |
    Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn5 | BASE SQL    | SELECT name FROM no_sharding GROUP BY name LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                                  |
      | conn_0 | False   | explain select name from test group by name                     |
    Then check resultset "rs_E" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                    |
      | /*AllowDiff*/dn3  | BASE SQL | SELECT name FROM test GROUP BY name LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                                                                                    |
      | conn_0 | True    | explain /*!dble:sql=select id from sharding_4_t1 where id=1*/select name from sharding_4_t1 group by name|
    Then check resultset "rs_F" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                    |
      | dn2 | BASE SQL | select name from sharding_4_t1 group by name |