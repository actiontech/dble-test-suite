# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/12/7
Feature: test "create databsae @@shardingnode='dn1,dn2,...'"

  @NORMAL
  Scenario: "create database @@..." for all used shardingnode #1
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
     """
        <shardingNode dbGroup="ha_group1" database="da1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="da1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="da2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="da2" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="da3" name="dn5" />
    """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists da1 | success  |
      | conn_0 | False    | drop database if exists da2 | success  |
      | conn_0 | True     | drop database if exists da3 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists da1 | success  |
      | conn_0 | True     | drop database if exists da2 | success  |
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                       | expect          |
      | conn_0 | False    | show databases like 'da1' | has{('da1',),}  |
      | conn_0 | False    | show databases like 'da2' | has{('da2',),}  |
      | conn_0 | True     | show databases like 'da3' | has{('da3',),}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                        | expect           |
      | conn_0 | False    | show databases like 'da1'  |  has{('da1',),}  |
      | conn_0 | True     | show databases like 'da2'  |  has{('da2',),}  |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists da1 | success  |
      | conn_0 | False    | drop database if exists da2 | success  |
      | conn_0 | True     | drop database if exists da3 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect   |
      | conn_0 | False    | drop database if exists da1 | success  |
      | conn_0 | True     | drop database if exists da2 | success  |

  @NORMAL
  Scenario: "create database @@..." for part of used shardingNode #2
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
    """
        <shardingNode dbGroup="ha_group1" database="da11" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="da11" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="da21" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="da21" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="da31" name="dn5" />
    """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da11 | success  |
      | conn_0 | False    | drop database if exists da21 | success  |
      | conn_0 | True     | drop database if exists da31 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da11 | success  |
      | conn_0 | True     | drop database if exists da21 | success  |
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2'"
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da11' | has{('da11',),} |
      | conn_0 | False    | show databases like 'da21' | length{(0)}     |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect           |
      | conn_0 | False    | show databases like 'da11'  |  has{('da11',),} |
      | conn_0 | True     | show databases like 'da21'  |  length{(0)}     |
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect           |
      | conn_0 | False    | show databases like 'da11' | has{('da11',),}  |
      | conn_0 | False    | show databases like 'da21' | has{('da21',),}  |
      | conn_0 | True     | show databases like 'da31' | has{('da31',),}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                         | expect           |
      | conn_0 | False    | show databases like 'da11'  |  has{('da11',),} |
      | conn_0 | True     | show databases like 'da21'  |  has{('da21',),} |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da11 | success  |
      | conn_0 | False    | drop database if exists da21 | success  |
      | conn_0 | True     | drop database if exists da31 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da11 | success  |
      | conn_0 | True     | drop database if exists da21 | success  |

  @NORMAL
  Scenario: "create database @@..." for shardingNode of style 'dn$x-y' #3
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <shardingTable shardingNode="dn10,dn11,dn20,dn21" name="test" function="hash-four" shardingColumn="id"/>
        </schema>

         <shardingNode dbGroup="ha_group1" database="da0$0-1" name="dn1$0-1" />
        <shardingNode dbGroup="ha_group2" database="da0$0-1" name="dn2$0-1" />
        <shardingNode dbGroup="ha_group1" database="da31" name="dn5" />
     """
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da00 | success  |
      | conn_0 | False    | drop database if exists da01 | success  |
      | conn_0 | True     | drop database if exists da31 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da00 | success  |
      | conn_0 | True     | drop database if exists da01 | success  |
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute admin cmd "create database @@shardingNode ='dn10,dn11,dn20,dn21'"
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                        | expect          |
      | conn_0 | False    | show databases like 'da00' | has{('da00',),} |
      | conn_0 | False    | show databases like 'da01' | has{('da01',),} |
      | conn_0 | True     | show databases like 'da31' | length{(0)}     |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                           | expect           |
      | conn_0 | False    | show databases like 'da00'    |  has{('da00',),} |
      | conn_0 | True     | show databases like 'da01'    |  has{('da01',),} |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da00 | success  |
      | conn_0 | False    | drop database if exists da01 | success  |
      | conn_0 | True     | drop database if exists da31 | success  |
    Then execute sql in "mysql-master2"
      | conn   | toClose  | sql                          | expect   |
      | conn_0 | False    | drop database if exists da00 | success  |
      | conn_0 | True     | drop database if exists da01 | success  |
