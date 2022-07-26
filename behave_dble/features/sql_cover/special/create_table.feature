# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/5/7


Feature: test mysql 8.0/mysql 5.7 create table about druid 1.2.x

  @NORMAL
  Scenario:  Mysql8.0/Mysql5.7 primary key if using descending index #1

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="tb_enum_sharding" shardingNode="dn1,dn2" function="hash-two" shardingColumn="code" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_0 | False   | drop table if exists tb_enum_sharding                                                                                                                                                            | success | schema1 |
      | conn_0 | False   | CREATE TABLE tb_enum_sharding ( id int(11) NOT NULL, code int(11) NOT NULL COMMENT 'code', content varchar(250) NOT NULL, PRIMARY KEY (id DESC) USING BTREE ) ENGINE=InnoDB DEFAULT CHARSET=utf8 | success | schema1 |
      | conn_0 | true    | drop table if exists tb_enum_sharding                                                                                                                                                            | success | schema1 |
