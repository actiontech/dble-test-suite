# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/4/27

Feature: check user hint


  Scenario: check shardingUser hint when log level is info #1
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect           | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                      | success          | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(10))                     | success          | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,'11'),(2,'22'),(3,'33'),(4,'44')     | success          | schema1 |
      | conn_1 | False   | /*!dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1        | length{(0)}      | schema1 |
      | conn_1 | False   | /*!dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1        | has{((1,'11'),)} | schema1 |
      | conn_1 | False   | /*#dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1        | length{(0)}      | schema1 |
      | conn_1 | True    | /*#dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1        | has{((1,'11'),)} | schema1 |
    Given set log4j2 log level to "info" in "dble-1"
    Given sleep "35" seconds
    Given execute oscmd in "dble-1"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -c -e "/*#dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1;/*#dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1;" && \
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "/*!dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1;/*!dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1;"
    """
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect           | db      |
      | conn_2 | False   | /*!dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1        | length{(0)}      | schema1 |
      | conn_2 | False   | /*!dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1        | has{((1,'11'),)} | schema1 |
      | conn_2 | False   | /*#dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1        | length{(0)}      | schema1 |
      | conn_2 | False   | /*#dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1        | has{((1,'11'),)} | schema1 |
      | conn_2 | True    | drop table if exists sharding_4_t1                                      | success          | schema1 |