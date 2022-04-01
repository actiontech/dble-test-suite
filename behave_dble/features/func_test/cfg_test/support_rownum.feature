# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/1/13
# http://10.186.18.11/jira/browse/DBLE0REQ-1374
Feature: support rownum sql

  Scenario: check enableRoutePenetration and routePenetrationRules in bootstrap.cnf #1
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs1"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs1" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1 | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 0             | Whether enable route penetration |
      | routePenetrationRules    |               | The config of route penetration  |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=0
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs2"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs2" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1 | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 0             | Whether enable route penetration |
      | routePenetrationRules    |               | The config of route penetration  |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DroutePenetrationRules=abc
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs3"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs3" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1 | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 0             | Whether enable route penetration |
      | routePenetrationRules    | abc           | The config of route penetration  |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    $a -DenableRoutePenetration=1
    /-DroutePenetrationRules/d
    """
    Then restart dble in "dble-1" failed for
    """
    The system property routePenetrationRules in bootstrap.cnf is illegal or unset, for more detail, please check dble.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    # can't parse the route-penetration rule, please check the 'routePenetrationRules', detail exception is :java.lang.IllegalStateException: property routePenetrationRules can't be null
    """
    parse the route-penetration rule, please check the
    routePenetrationRules
    detail exception is :java.lang.IllegalStateException: property routePenetrationRules
    be null
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules/d
    $a -DroutePenetrationRules=123abc
    """
    Then restart dble in "dble-1" failed for
    """
    The system property routePenetrationRules in bootstrap.cnf is illegal or unset, for more detail, please check dble.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    # can't parse the route-penetration rule, please check the 'routePenetrationRules', detail exception is :com.google.gson.JsonSyntaxException: java.lang.IllegalStateException: Expected BEGIN_OBJECT but was STRING at line 1 column 1 path $
    """
    parse the route-penetration rule, please check the
    routePenetrationRules
    detail exception is :com.google.gson.JsonSyntaxException: java.lang.IllegalStateException: Expected BEGIN_OBJECT but was STRING at line 1 column 1 path \$
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules=123abc/c -DroutePenetrationRules={"abc":"123"}
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs4"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs4" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1 | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 1             | Whether enable route penetration |
      | routePenetrationRules    | {"abc":"123"} | The config of route penetration  |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules={"abc":"123"}/c -DroutePenetrationRules={"rules":"123"}
    """
    Then restart dble in "dble-1" failed for
    """
    The system property routePenetrationRules in bootstrap.cnf is illegal or unset, for more detail, please check dble.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    # can't parse the route-penetration rule, please check the 'routePenetrationRules', detail exception is :com.google.gson.JsonSyntaxException: java.lang.IllegalStateException: Expected BEGIN_ARRAY but was STRING at line 1 column 11 path $.rules
    """
    parse the route-penetration rule, please check the
    routePenetrationRules
    detail exception is :com.google.gson.JsonSyntaxException: java.lang.IllegalStateException: Expected BEGIN_ARRAY but was STRING at line 1 column 11 path \$.rules
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules={"rules":"123"}/c -DroutePenetrationRules={"rules":[{"abc":123}]}
    """
    Then restart dble in "dble-1" failed for
    """
    The system property routePenetrationRules in bootstrap.cnf is illegal or unset, for more detail, please check dble.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    # can't parse the route-penetration rule, please check the 'routePenetrationRules', detail exception is :java.lang.IllegalStateException: regex can't be null or empty.
    """
    parse the route-penetration rule, please check the
    routePenetrationRules
    detail exception is :java.lang.IllegalStateException: regex
    t be null or empty.
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DroutePenetrationRules={"rules":[{"abc":123,"regex":"1"}]}
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs5"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs5" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1                       | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 1                                   | Whether enable route penetration |
      | routePenetrationRules    | {"rules":[{"abc":123,"regex":"1"}]} | The config of route penetration  |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DroutePenetrationRules={"rules":[{"partMatch":123,"regex":"1","caseSensitive":"abc"}]}
    """
    Then restart dble in "dble-1" failed for
    """
    The system property routePenetrationRules in bootstrap.cnf is illegal or unset, for more detail, please check dble.log
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    # can't parse the route-penetration rule, please check the 'routePenetrationRules', detail exception is :com.google.gson.JsonParseException: Cannot parse json '123' to boolean value
    """
    parse the route-penetration rule, please check the
    routePenetrationRules
    detail exception is :com.google.gson.JsonParseException: Cannot parse json
    to boolean value
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules/d
    $a -DenableRoutePenetration=1
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DroutePenetrationRules={"rules":[{"regex":"select\\\\sid\\\\sfrom\\\\ssharding_2_t1"}]}
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs6"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs6" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1                                              | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 1                                                          | Whether enable route penetration |
      | routePenetrationRules    | {"rules":[{"regex":"select\\sid\\sfrom\\ssharding_2_t1"}]} | The config of route penetration  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name varchar(10))                              | success | schema1 |
      | conn_1 | False   | select id from sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id FROM sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id from sharding_2_t1 where id>6                                           | success | schema1 |
      | conn_1 | true    | select * from sharding_2_t1 where id in (select id from sharding_2_t1)            | success | schema1 |
    # partMatch default value : true, caseSensitive default value : true
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id from sharding_2_t1 match the route penetration regex
    the query select id from sharding_2_t1 match the route penetration rule, will direct route
    the query select id from sharding_2_t1 where id>6 match the route penetration regex
    the query select id from sharding_2_t1 where id>6 match the route penetration rule, will direct route
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration regex
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration rule, will direct route
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id FROM sharding_2_t1 match the route penetration regex
    the query select id FROM sharding_2_t1 match the route penetration rule, will direct route
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DroutePenetrationRules={"rules":[{"regex":"select\\\\sid\\\\sfrom\\\\ssharding_2_t1","partMatch":false,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs7"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs7" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1                                                                                      | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 1                                                                                                  | Whether enable route penetration |
      | routePenetrationRules    | {"rules":[{"regex":"select\\sid\\sfrom\\ssharding_2_t1","partMatch":false,"caseSensitive":true}]}  | The config of route penetration  |
        Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                               | expect  | db      |
      | conn_1 | False   | select id from sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id FROM sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id from sharding_2_t1 where id>6                                           | success | schema1 |
      | conn_1 | true    | select * from sharding_2_t1 where id in (select id from sharding_2_t1)            | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id from sharding_2_t1 match the route penetration regex
    the query select id from sharding_2_t1 match the route penetration rule, will direct route
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id FROM sharding_2_t1 match the route penetration regex
    the query select id FROM sharding_2_t1 match the route penetration rule, will direct route
    the query select id from sharding_2_t1 where id>6 match the route penetration regex
    the query select id from sharding_2_t1 where id>6 match the route penetration rule, will direct route
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration regex
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration rule, will direct route
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DroutePenetrationRules={"rules":[{"regex":"select\\\\sid\\\\sfrom\\\\ssharding_2_t1","partMatch":false,"caseSensitive":false}]}
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs8"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs8" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1                                                                                      | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 1                                                                                                  | Whether enable route penetration |
      | routePenetrationRules    | {"rules":[{"regex":"select\\sid\\sfrom\\ssharding_2_t1","partMatch":false,"caseSensitive":false}]} | The config of route penetration  |
        Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                               | expect  | db      |
      | conn_1 | False   | select id from sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id FROM sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id from sharding_2_t1 where id>6                                           | success | schema1 |
      | conn_1 | true    | select * from sharding_2_t1 where id in (select id from sharding_2_t1)            | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id from sharding_2_t1 match the route penetration regex
    the query select id from sharding_2_t1 match the route penetration rule, will direct route
    the query select id FROM sharding_2_t1 match the route penetration regex
    the query select id FROM sharding_2_t1 match the route penetration rule, will direct route
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id from sharding_2_t1 where id>6 match the route penetration regex
    the query select id from sharding_2_t1 where id>6 match the route penetration rule, will direct route
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration regex
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration rule, will direct route
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DroutePenetrationRules={"rules":[{"regex":"select\\\\sid\\\\sfrom\\\\ssharding_2_t1","partMatch":true,"caseSensitive":false}]}
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs8"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs8" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1                                                                                     | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 1                                                                                                 | Whether enable route penetration |
      | routePenetrationRules    | {"rules":[{"regex":"select\\sid\\sfrom\\ssharding_2_t1","partMatch":true,"caseSensitive":false}]} | The config of route penetration  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                               | expect  | db      |
      | conn_1 | False   | select id from sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id FROM sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id from sharding_2_t1 where id>6                                           | success | schema1 |
      | conn_1 | true    | select * from sharding_2_t1 where id in (select id from sharding_2_t1)            | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id from sharding_2_t1 match the route penetration regex
    the query select id from sharding_2_t1 match the route penetration rule, will direct route
    the query select id FROM sharding_2_t1 match the route penetration regex
    the query select id FROM sharding_2_t1 match the route penetration rule, will direct route
    the query select id from sharding_2_t1 where id>6 match the route penetration regex
    the query select id from sharding_2_t1 where id>6 match the route penetration rule, will direct route
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration regex
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration rule, will direct route
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DroutePenetrationRules={"rules":[{"regex":"select\\\\sid\\\\sfrom\\\\ssharding_2_t1","partMatch":true,"caseSensitive":false},{"regex":"rownum","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs8"
      | sql             |
      | show @@sysparam |
    Then check resultset "rs8" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1                                                                                      | PARAM_DESCR-2                    |
      | enableRoutePenetration   | 1                                                                                                  | Whether enable route penetration |
      | routePenetrationRules    | {"rules":[{"regex":"select\\sid\\sfrom\\ssharding_2_t1","partMatch":true,"caseSensitive":false},{"regex":"rownum","partMatch":true,"caseSensitive":true}]} | The config of route penetration  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                               | expect  | db      |
      | conn_1 | False   | select id from sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id FROM sharding_2_t1                                                      | success | schema1 |
      | conn_1 | False   | select id from sharding_2_t1 where id>6                                           | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 where id in (select id from sharding_2_t1)            | success | schema1 |
      | conn_1 | False   | select id as rownum from sharding_2_t1                                            | success | schema1 |
      | conn_1 | False   | select id as Rownum FROM sharding_2_t1                                            | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 as rownum                                             | success | schema1 |
      | conn_1 | False   | select id as rownum123 from sharding_2_t1                                         | success | schema1 |
      | conn_1 | False   | select id as row123num FROM sharding_2_t1                                         | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 as rownumabc                                          | success | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id from sharding_2_t1 match the route penetration regex
    the query select id from sharding_2_t1 match the route penetration rule, will direct route
    the query select id FROM sharding_2_t1 match the route penetration regex
    the query select id FROM sharding_2_t1 match the route penetration rule, will direct route
    the query select id from sharding_2_t1 where id>6 match the route penetration regex
    the query select id from sharding_2_t1 where id>6 match the route penetration rule, will direct route
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration regex
    the query select \* from sharding_2_t1 where id in (select id from sharding_2_t1) match the route penetration rule, will direct route
    the query select id as rownum from sharding_2_t1 match the route penetration regex
    the query select id as rownum from sharding_2_t1 match the route penetration rule, will direct route
    the query select \* from sharding_2_t1 as rownum match the route penetration regex
    the query select \* from sharding_2_t1 as rownum match the route penetration rule, will direct route
    the query select id as rownum123 from sharding_2_t1 match the route penetration regex
    the query select id as rownum123 from sharding_2_t1 match the route penetration rule, will direct route
    the query select \* from sharding_2_t1 as rownumabc match the route penetration regex
    the query select \* from sharding_2_t1 as rownumabc match the route penetration rule, will direct route
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select id as Rownum FROM sharding_2_t1 match the route penetration regex
    the query select id as Rownum FROM sharding_2_t1 match the route penetration rule, will direct route
    the query select id as row123num FROM sharding_2_t1 match the route penetration regex
    the query select id as row123num FROM sharding_2_t1 match the route penetration rule, will direct route
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect  | db      |
      | conn_1 | True    | drop table if exists sharding_2_t1  | success | schema1 |

  Scenario: check rownum sql - one table #2
    Given delete the following xml segment
      | file          | parent           | child               |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
          <singleTable name="single_t1" shardingNode="dn1" />
          <globalTable name="global_2_t1" shardingNode="dn1,dn2" />
          <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      </schema>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists global_2_t1;drop table if exists single_t1               | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))         | success | schema1 |
      | conn_1 | False   | create table global_2_t1 (id int, global_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table single_t1 (id int, single_name varchar(20), parent_id int, status int, code varchar(10))            | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | False   | insert into global_2_t1 values (1, 'global_2_t1_1', 1, 1, 'a'),(2, 'global_2_t1_2', 1, 1, 'b'),(3, 'global_2_t1_3', 1, 2, 'c'),(4, 'global_2_t1_4', 2, 2, 'd'),(5, 'global_2_t1_5', 2, 1, 'e'),(6, 'global_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | False   | insert into single_t1 values (1, 'single_t1_1', 1, 1, 'a'),(2, 'single_t1_2', 1, 1, 'b'),(3, 'single_t1_3', 1, 2, 'c'),(4, 'single_t1_4', 2, 2, 'd'),(5, 'single_t1_5', 2, 1, 'e'),(6, 'single_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | False   | select a.*, @rownum:=1 from sharding_2_t1 a                                                                      | not support assignment | schema1 |
      | conn_1 | False   | select *, @rownum:=1 from sharding_2_t1                                                                          | not support assignment | schema1 |
      | conn_1 | False   | select *, @rownum:=1 from sharding_2_t1 where status=1 order by code desc                                        | not support assignment | schema1 |
      | conn_1 | False   | select a.parent_id, count(0), @rownum:=1 from sharding_2_t1 a group by a.parent_id having a.parent_id > 1        | not support assignment | schema1 |
      | conn_1 | False   | select parent_id, code, count(0), @rownum:=1 from sharding_2_t1 group by parent_id, code having parent_id > 1    | not support assignment | schema1 |
      | conn_1 | False   | select a.*, @rownum:=1 from global_2_t1 a                                                                        | success | schema1 |
      | conn_1 | False   | select *, @rownum:=1 from global_2_t1                                                                            | success | schema1 |
      | conn_1 | False   | select *, @rownum:=1 from global_2_t1 where status=1 order by code desc                                          | success | schema1 |
      | conn_1 | False   | select a.parent_id, count(0), @rownum:=1 from global_2_t1 a group by a.parent_id having a.parent_id > 1          | success | schema1 |
      | conn_1 | False   | select parent_id, code, count(0), @rownum:=1 from global_2_t1 group by parent_id, code having parent_id > 1      | success | schema1 |
      | conn_1 | False   | select a.*, @rownum:=1 from single_t1 a                                                                          | success | schema1 |
      | conn_1 | False   | select *, @rownum:=1 from single_t1                                                                              | success | schema1 |
      | conn_1 | False   | select *, @rownum:=1 from single_t1 where status=1 order by code desc                                            | success | schema1 |
      | conn_1 | False   | select a.parent_id, count(0), @rownum:=1 from single_t1 a group by a.parent_id having a.parent_id > 1            | success | schema1 |
      | conn_1 | False   | select parent_id, code, count(0), @rownum:=1 from single_t1 group by parent_id, code having parent_id > 1        | success | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs1"
      | conn   | toClose | sql                                               | expect  | db      |
      | conn_1 | False   | explain select a.*, @rownum:=1 from global_2_t1 a | success | schema1 |
    Then check resultset "rownum_rs1" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2 |
      | dn1//dn2         | BASE SQL        | SELECT a.*, @rownum := 1 FROM global_2_t1 a LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs2"
      | conn   | toClose | sql                                                                                                     | expect  | db      |
      | conn_1 | False   | explain select parent_id, count(0), @rownum:=1 from global_2_t1 group by parent_id having parent_id > 1 | success | schema1 |
    Then check resultset "rownum_rs2" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2 |
      | dn1//dn2         | BASE SQL        | SELECT parent_id, count(0), @rownum := 1 FROM global_2_t1 GROUP BY parent_id HAVING parent_id > 1 LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs3"
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_1 | False   | explain select a.*, @rownum:=1 from single_t1 a | success | schema1 |
    Then check resultset "rownum_rs3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2 |
      | dn1              | BASE SQL        | SELECT a.*, @rownum := 1 FROM single_t1 a LIMIT 100 |
        Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs4"
      | conn   | toClose | sql                                                                                                   | expect  | db      |
      | conn_1 | True    | explain select parent_id, count(0), @rownum:=1 from single_t1 group by parent_id having parent_id > 1 | success | schema1 |
    Then check resultset "rownum_rs4" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2 |
      | dn1              | BASE SQL        | SELECT parent_id, count(0), @rownum := 1 FROM single_t1 GROUP BY parent_id HAVING parent_id > 1 LIMIT 100 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":"rownum","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      | conn_2 | False   | select a.*, @rownum:=1 from sharding_2_t1 a                                                                      | success | schema1 |
      | conn_2 | False   | select *, @rownum:=1 from sharding_2_t1                                                                          | success | schema1 |
      | conn_2 | False   | select *, @rownum:=1 from sharding_2_t1 where status=1 order by code desc                                        | success | schema1 |
      | conn_2 | False   | select a.parent_id, count(0), @rownum:=1 from sharding_2_t1 a group by a.parent_id having a.parent_id > 1        | has{(2, 2, 1), (2, 1, 1)} | schema1 |
      | conn_2 | False   | select parent_id, code, count(0), @rownum:=1 from sharding_2_t1 group by parent_id, code having parent_id > 1    | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs5"
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_2 | False   | explain select a.*, @rownum:=1 from sharding_2_t1 a | success | schema1 |
    Then check resultset "rownum_rs5" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | SELECT a.*, @rownum := 1 FROM sharding_2_t1 a LIMIT 100 |
      | dn2              | BASE SQL | SELECT a.*, @rownum := 1 FROM sharding_2_t1 a LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs6"
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_2 | False   | explain select *, @rownum:=1 from sharding_2_t1 | success | schema1 |
    Then check resultset "rownum_rs6" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | SELECT *, @rownum := 1 FROM sharding_2_t1 LIMIT 100 |
      | dn2              | BASE SQL | SELECT *, @rownum := 1 FROM sharding_2_t1 LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs7"
      | conn   | toClose | sql                                                                                                               | expect  | db      |
      | conn_2 | False   | explain select a.parent_id, count(0), @rownum:=1 from sharding_2_t1 a group by a.parent_id having a.parent_id > 1 | success | schema1 |
    Then check resultset "rownum_rs7" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | SELECT a.parent_id, count(0), @rownum := 1 FROM sharding_2_t1 a GROUP BY a.parent_id HAVING a.parent_id > 1 LIMIT 100 |
      | dn2              | BASE SQL | SELECT a.parent_id, count(0), @rownum := 1 FROM sharding_2_t1 a GROUP BY a.parent_id HAVING a.parent_id > 1 LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs8"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_2 | False    | explain select parent_id, code, count(0), @rownum:=1 from sharding_2_t1 group by parent_id, code having parent_id > 1 | success | schema1 |
    Then check resultset "rownum_rs8" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | SELECT parent_id, code, count(0)  , @rownum := 1 FROM sharding_2_t1 GROUP BY parent_id, code HAVING parent_id > 1 LIMIT 100 |
      | dn2              | BASE SQL | SELECT parent_id, code, count(0)  , @rownum := 1 FROM sharding_2_t1 GROUP BY parent_id, code HAVING parent_id > 1 LIMIT 100 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      | conn_2 | True    | drop table if exists sharding_2_t1;drop table if exists global_2_t1;drop table if exists single_t1               | success | schema1 |

  Scenario: check rownum sql - shardingTable + shardingTable - same shardingNode and same function #3
    Given delete the following xml segment
      | file          | parent           | child               |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
          <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
          <shardingTable name="sharding_2_t2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      </schema>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists sharding_2_t2                                             | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table sharding_2_t2 (id int, shard_value varchar(20), parent_id int, status int, code varchar(10))         | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into sharding_2_t2 values (1, 'sharding_2_t2_1', 1, 1, 'a'),(2, 'sharding_2_t2_2', 1, 1, 'b'),(3, 'sharding_2_t2_3', 1, 2, 'c'),(4, 'sharding_2_t2_4', 2, 2, 'd'),(5, 'sharding_2_t2_5', 2, 1, 'e'),(6, 'sharding_2_t2_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      # use table alias
      | conn_2 | False   | select a.id, a.parent_id, a.code, @rownum:=@rownum+1 from sharding_2_t1 a, (select @rownum:=0) r order by a.id   | has{(2, 1, 'b', 1.0),(4, 2, 'd', 2.0),(6, 2, 'f', 3.0),(1, 1, 'a', 1.0),(3, 1, 'c', 2.0),(5, 2, 'e', 3.0)} | schema1 |
      # no table alias
      | conn_2 | False   | select id, parent_id, code, @rownum:=@rownum+1 from sharding_2_t1, (select @rownum:=0) r order by id             | has{(2, 1, 'b', 1.0),(4, 2, 'd', 2.0),(6, 2, 'f', 3.0),(1, 1, 'a', 1.0),(3, 1, 'c', 2.0),(5, 2, 'e', 3.0)} | schema1 |
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc | has{(1, 'sharding_2_t2_3', 1.0),(1, 'sharding_2_t2_1', 1.0),(2, 'sharding_2_t2_6', 1.0),(2, 'sharding_2_t2_4', 1.0)} | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | has{(1, 'sharding_2_t2_1', 1.0),(1, 'sharding_2_t2_3', 2.0),(2, 'sharding_2_t2_4', 1.0),(2, 'sharding_2_t2_6', 2.0)} | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 | has{(2, 'sharding_2_t2_4', 1.0),(2, 'sharding_2_t2_6', 1.0)} | schema1 |
      # in sub query
      | conn_2 | False   | select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) | has{(4, 'sharding_2_t2_4', 1.0),(6, 'sharding_2_t2_6', 1.0)} | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | has{(2, 'sharding_2_t2_6', 1.0),(2, 'sharding_2_t2_4', 1.0)} | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | has{(1, 'a', 1, 1.0),(2, 'b', 1, 1.0)} | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | has{(4, 'sharding_2_t2_4', 1.0),(6, 'sharding_2_t2_6', 2.0)} | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 | has{(1, 1),(2, 1)} | schema1 |
      | conn_2 | False   | select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 | has{(1, 'sharding_2_t2_1', 'sharding_2_t1_1', 0),(3, 'sharding_2_t2_3', 'sharding_2_t1_1', 0)} | schema1 |
      | conn_2 | False   | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id | has{('sharding_2_t1_2', 2, 2),('sharding_2_t1_1', 1, 2)} | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs1"
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_2 | False   | explain select a.id, a.parent_id, a.code, @rownum:=@rownum-1 from sharding_2_t1 a, (select @rownum:=0) r order by a.id | success | schema1 |
    Then check resultset "rownum_rs1" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | SELECT a.id, a.parent_id, a.code  , @rownum := @rownum - 1 FROM sharding_2_t1 a, (   SELECT @rownum := 0  ) r ORDER BY a.id LIMIT 100 |
      | dn2              | BASE SQL | SELECT a.id, a.parent_id, a.code  , @rownum := @rownum - 1 FROM sharding_2_t1 a, (   SELECT @rownum := 0  ) r ORDER BY a.id LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs2"
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_2 | False   | explain select id, parent_id, code, @rownum:=@rownum-1 from sharding_2_t1, (select @rownum:=0) r order by id | success | schema1 |
    Then check resultset "rownum_rs2" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | SELECT id, parent_id, code  , @rownum := @rownum - 1 FROM sharding_2_t1, (   SELECT @rownum := 0  ) r ORDER BY id LIMIT 100 |
      | dn2              | BASE SQL | SELECT id, parent_id, code  , @rownum := @rownum - 1 FROM sharding_2_t1, (   SELECT @rownum := 0  ) r ORDER BY id LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs3"
      | conn   | toClose | sql                                                                                                                                | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc |
      | dn2              | BASE SQL | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs4"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs4" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
      Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs5"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 | success | schema1 |
    Then check resultset "rownum_rs5" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 |
    Then check resultset "rownum_rs5" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs6"
      | conn   | toClose | sql                                                                                                                      | expect  | db      |
      | conn_2 | False   | explain select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) | success | schema1 |
    Then check resultset "rownum_rs6" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) |
      | dn2              | BASE SQL | select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs7"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs7" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
      | dn2              | BASE SQL | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs8"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | success | schema1 |
    Then check resultset "rownum_rs8" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
      | dn2              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs9"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs9" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r |
    Then check resultset "rownum_rs9" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs10"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 | success | schema1 |
    Then check resultset "rownum_rs10" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 |
      | dn2              | BASE SQL | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs11"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 | success | schema1 |
    Then check resultset "rownum_rs11" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 |
    Then check resultset "rownum_rs11" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs12"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id | success | schema1 |
    Then check resultset "rownum_rs12" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1           | BASE SQL | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id |
      | dn2           | BASE SQL | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect  | db      |
      | conn_2 | True    | drop table if exists sharding_2_t1;drop table if exists sharding_2_t2   | success | schema1 |

  Scenario: check rownum sql - shardingTable + shardingTable - same shardingNode and different function #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_2_t2" shardingNode="dn1,dn2" function="hash-string-into-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists sharding_2_t2                                             | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table sharding_2_t2 (id int, shard_value varchar(20), parent_id int, status int, code varchar(10))         | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into sharding_2_t2 values (1, 'sharding_2_t2_1', 1, 1, 'a'),(2, 'sharding_2_t2_2', 1, 1, 'b'),(3, 'sharding_2_t2_3', 1, 2, 'c'),(4, 'sharding_2_t2_4', 2, 2, 'd'),(5, 'sharding_2_t2_5', 2, 1, 'e'),(6, 'sharding_2_t2_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect  | db      |
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc | not support assignment | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | not support assignment | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 | not support assignment | schema1 |
      # in sub query
      | conn_2 | False   | select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) | not support assignment | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | not support assignment | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | not support assignment | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | not support assignment | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 | has{(1, 1),(2, 1)} | schema1 |
      | conn_2 | False   | select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 | has{(1, 'sharding_2_t2_1', 'sharding_2_t1_1', 0),(2, 'sharding_2_t2_2', 'sharding_2_t1_1', 0),(3, 'sharding_2_t2_3', 'sharding_2_t1_1', 0)} | schema1 |
      | conn_2 | False   | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id | has{('sharding_2_t1_2', 2, 3),('sharding_2_t1_1', 1, 3)} | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration regex
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration regex
    the query select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) match the route penetration regex
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration regex
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r match the route penetration regex
    the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 match the route penetration regex
    the query select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration regex
    the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration regex
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration rule, will direct route
    the query select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) match the route penetration rule, will direct route
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration rule, will direct route
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 match the route penetration rule, will direct route
    the query select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration rule, will direct route
    the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration rule, will direct route
    """
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs0"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 | success | schema1 |
    Then check resultset "rownum_rs0" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2 |
      | dn1_0                      | BASE SQL                 | select `sharding_2_t1`.`id`,`sharding_2_t1`.`parent_id` from  `sharding_2_t1` where `sharding_2_t1`.`status` = 1 ORDER BY `sharding_2_t1`.`id` ASC |
      | dn2_0                      | BASE SQL                 | select `sharding_2_t1`.`id`,`sharding_2_t1`.`parent_id` from  `sharding_2_t1` where `sharding_2_t1`.`status` = 1 ORDER BY `sharding_2_t1`.`id` ASC |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn1_0; dn2_0                                                                                                                                                                                                                    |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                                                                                                                               |
      | dn1_1                      | BASE SQL                 | select DISTINCT `sharding_2_t2`.`parent_id` as `autoalias_scalar` from  `sharding_2_t2` ORDER BY `sharding_2_t2`.`parent_id` ASC                                                                                                |
      | dn2_1                      | BASE SQL                 | select DISTINCT `sharding_2_t2`.`parent_id` as `autoalias_scalar` from  `sharding_2_t2` ORDER BY `sharding_2_t2`.`parent_id` ASC                                                                                                |
      | merge_and_order_2          | MERGE_AND_ORDER          | dn1_1; dn2_1                                                                                                                                                                                                                    |
      | distinct_1                 | DISTINCT                 | merge_and_order_2                                                                                                                                                                                                               |
      | shuffle_field_3            | SHUFFLE_FIELD            | distinct_1                                                                                                                                                                                                                      |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_3                                                                                                                                                                                                                 |
      | shuffle_field_4            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                                                                                                                                      |
      | join_1                     | JOIN                     | shuffle_field_1; shuffle_field_4                                                                                                                                                                                                |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                                                                                                                          |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs1"
      | conn   | toClose | sql                                                                                                                                            | expect  | db      |
      | conn_2 | False   | explain select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 | success | schema1 |
    Then check resultset "rownum_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn2_0             | BASE SQL        | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` where `t1`.`id` = 1 ORDER BY `t1`.`id` ASC                                 |
      | merge_1           | MERGE           | dn2_0                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_1                                                                                                                                  |
      | dn1_0             | BASE SQL        | select `t2`.`id`,`t2`.`shard_value`,`t2`.`parent_id` from  `sharding_2_t2` `t2` where `t2`.`parent_id` = 1 ORDER BY `t2`.`parent_id` ASC |
      | dn2_1             | BASE SQL        | select `t2`.`id`,`t2`.`shard_value`,`t2`.`parent_id` from  `sharding_2_t2` `t2` where `t2`.`parent_id` = 1 ORDER BY `t2`.`parent_id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_1                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                        |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs2"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id | success | schema1 |
    Then check resultset "rownum_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` ORDER BY `t1`.`id` ASC |
      | dn2_0             | BASE SQL        | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` ORDER BY `t1`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                    |
      | dn1_1             | BASE SQL        | select `t2`.`parent_id` from  `sharding_2_t2` `t2` ORDER BY `t2`.`parent_id` ASC     |
      | dn2_1             | BASE SQL        | select `t2`.`parent_id` from  `sharding_2_t2` `t2` ORDER BY `t2`.`parent_id` ASC     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                    |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                     |
      | direct_group_1    | DIRECT_GROUP    | join_1                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | direct_group_1                                                                       |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect  | db      |
      | conn_2 | True    | drop table if exists sharding_2_t1;drop table if exists sharding_2_t2   | success | schema1 |

  Scenario: check rownum sql - shardingTable + shardingTable - different shardingNode and same function #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_2_t2" shardingNode="dn3,dn4" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists sharding_2_t2                                             | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table sharding_2_t2 (id int, shard_value varchar(20), parent_id int, status int, code varchar(10))         | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into sharding_2_t2 values (1, 'sharding_2_t2_1', 1, 1, 'a'),(2, 'sharding_2_t2_2', 1, 1, 'b'),(3, 'sharding_2_t2_3', 1, 2, 'c'),(4, 'sharding_2_t2_4', 2, 2, 'd'),(5, 'sharding_2_t2_5', 2, 1, 'e'),(6, 'sharding_2_t2_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect  | db      |
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc | not support assignment | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | not support assignment | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 | not support assignment | schema1 |
      # in sub query
      | conn_2 | False   | select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) | not support assignment | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | not support assignment | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | not support assignment | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | not support assignment | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 | has{(1, 1),(2, 1)} | schema1 |
      | conn_2 | False   | select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 | has{(1, 'sharding_2_t2_1', 'sharding_2_t1_1', 0),(2, 'sharding_2_t2_2', 'sharding_2_t1_1', 0),(3, 'sharding_2_t2_3', 'sharding_2_t1_1', 0)} | schema1 |
      | conn_2 | False   | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id | has{('sharding_2_t1_2', 2, 3),('sharding_2_t1_1', 1, 3)} | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration regex
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration regex
    the query select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) match the route penetration regex
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration regex
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r match the route penetration regex
    the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 match the route penetration regex
    the query select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration regex
    the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration regex
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration rule, will direct route
    the query select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) match the route penetration rule, will direct route
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration rule, will direct route
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 match the route penetration rule, will direct route
    the query select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration rule, will direct route
    the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration rule, will direct route
    """
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs0"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 | success | schema1 |
    Then check resultset "rownum_rs0" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2 |
      | dn1_0                      | BASE SQL                 | select `sharding_2_t1`.`id`,`sharding_2_t1`.`parent_id` from  `sharding_2_t1` where `sharding_2_t1`.`status` = 1 ORDER BY `sharding_2_t1`.`id` ASC |
      | dn2_0                      | BASE SQL                 | select `sharding_2_t1`.`id`,`sharding_2_t1`.`parent_id` from  `sharding_2_t1` where `sharding_2_t1`.`status` = 1 ORDER BY `sharding_2_t1`.`id` ASC |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn1_0; dn2_0                                                                                                                                       |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                                                  |
      | dn3_0                      | BASE SQL                 | select DISTINCT `sharding_2_t2`.`parent_id` as `autoalias_scalar` from  `sharding_2_t2` ORDER BY `sharding_2_t2`.`parent_id` ASC                   |
      | dn4_0                      | BASE SQL                 | select DISTINCT `sharding_2_t2`.`parent_id` as `autoalias_scalar` from  `sharding_2_t2` ORDER BY `sharding_2_t2`.`parent_id` ASC                   |
      | merge_and_order_2          | MERGE_AND_ORDER          | dn3_0; dn4_0                                                                                                                                       |
      | distinct_1                 | DISTINCT                 | merge_and_order_2                                                                                                                                  |
      | shuffle_field_3            | SHUFFLE_FIELD            | distinct_1                                                                                                                                         |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_3                                                                                                                                    |
      | shuffle_field_4            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                                                         |
      | join_1                     | JOIN                     | shuffle_field_1; shuffle_field_4                                                                                                                   |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                                             |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs1"
      | conn   | toClose | sql                                                                                                                                            | expect  | db      |
      | conn_2 | False   | explain select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 | success | schema1 |
    Then check resultset "rownum_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn2_0             | BASE SQL        | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` where `t1`.`id` = 1 ORDER BY `t1`.`id` ASC                                 |
      | merge_1           | MERGE           | dn2_0                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_1                                                                                                                                  |
      | dn3_0             | BASE SQL        | select `t2`.`id`,`t2`.`shard_value`,`t2`.`parent_id` from  `sharding_2_t2` `t2` where `t2`.`parent_id` = 1 ORDER BY `t2`.`parent_id` ASC |
      | dn4_0             | BASE SQL        | select `t2`.`id`,`t2`.`shard_value`,`t2`.`parent_id` from  `sharding_2_t2` `t2` where `t2`.`parent_id` = 1 ORDER BY `t2`.`parent_id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                        |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs2"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id | success | schema1 |
    Then check resultset "rownum_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` ORDER BY `t1`.`id` ASC |
      | dn2_0             | BASE SQL        | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` ORDER BY `t1`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                    |
      | dn3_0             | BASE SQL        | select `t2`.`parent_id` from  `sharding_2_t2` `t2` ORDER BY `t2`.`parent_id` ASC     |
      | dn4_0             | BASE SQL        | select `t2`.`parent_id` from  `sharding_2_t2` `t2` ORDER BY `t2`.`parent_id` ASC     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                    |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                     |
      | direct_group_1    | DIRECT_GROUP    | join_1                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | direct_group_1                                                                       |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect  | db      |
      | conn_2 | True   | drop table if exists sharding_2_t1;drop table if exists sharding_2_t2 | success | schema1 |

  Scenario: check rownum sql - shardingTable + shardingTable - different shardingNode and different function #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_2_t2" shardingNode="dn3,dn4" function="hash-string-into-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists sharding_2_t2                                             | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table sharding_2_t2 (id int, shard_value varchar(20), parent_id int, status int, code varchar(10))         | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into sharding_2_t2 values (1, 'sharding_2_t2_1', 1, 1, 'a'),(2, 'sharding_2_t2_2', 1, 1, 'b'),(3, 'sharding_2_t2_3', 1, 2, 'c'),(4, 'sharding_2_t2_4', 2, 2, 'd'),(5, 'sharding_2_t2_5', 2, 1, 'e'),(6, 'sharding_2_t2_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect  | db      |
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc | not support assignment | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | not support assignment | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 | not support assignment | schema1 |
      # in sub query
      | conn_2 | False   | select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) | not support assignment | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | not support assignment | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | not support assignment | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | not support assignment | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 | has{(1, 1),(2, 1)} | schema1 |
      | conn_2 | False   | select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 | has{(1, 'sharding_2_t2_1', 'sharding_2_t1_1', 0),(2, 'sharding_2_t2_2', 'sharding_2_t1_1', 0),(3, 'sharding_2_t2_3', 'sharding_2_t1_1', 0)} | schema1 |
      | conn_2 | False   | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id | has{('sharding_2_t1_2', 2, 3),('sharding_2_t1_1', 1, 3)} | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration regex
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration regex
    the query select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) match the route penetration regex
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration regex
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r match the route penetration regex
    the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 match the route penetration regex
    the query select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration regex
    the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration regex
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.shard_value from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1,sharding_2_t2 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration rule, will direct route
    the query select id,shard_value,@rownum:=1 from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id>1) match the route penetration rule, will direct route
    the query select t1.id,t2.shard_value,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration rule, will direct route
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select id,shard_value from sharding_2_t2 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from sharding_2_t2) and status=1 match the route penetration rule, will direct route
    the query select t2.id,t2.shard_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join sharding_2_t2 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration rule, will direct route
    the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, sharding_2_t2 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration rule, will direct route
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                    | expect  | db      |
      | conn_2 | True    | drop table if exists sharding_2_t1;drop table if exists sharding_2_t2  | success | schema1 |

  Scenario: check rownum sql - shardingTable + globalTable - same shardingNode #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <globalTable name="global_2_t1" shardingNode="dn1,dn2" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists global_2_t1                                               | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table global_2_t1 (id int, global_value varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into global_2_t1 values (1, 'global_2_t1_1', 1, 1, 'a'),(2, 'global_2_t1_2', 1, 1, 'b'),(3, 'global_2_t1_3', 1, 2, 'c'),(4, 'global_2_t1_4', 2, 2, 'd'),(5, 'global_2_t1_5', 2, 1, 'e'),(6, 'global_2_t1_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                           | expect  | db      |
      | conn_2 | False   | select a.id,a.code,@rownum:=@rownum+1 from global_2_t1 a, (select @rownum:=0) r order by a.id | has{(1, 'a', 1.0),(2, 'b', 2.0),(3, 'c', 3.0),(4, 'd', 4.0),(5, 'e', 5.0),(6, 'f', 6.0)} | schema1 |
      | conn_2 | False   | select id, code, @rownum:=@rownum+1 from global_2_t1, (select @rownum:=0) r order by id       | has{(1, 'a', 1.0),(2, 'b', 2.0),(3, 'c', 3.0),(4, 'd', 4.0),(5, 'e', 5.0),(6, 'f', 6.0)} | schema1 |
      | conn_2 | False   | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id order by t2.id desc | has{(1, 'global_2_t1_1', 1.0),(1, 'global_2_t1_2', 1.0),(1, 'global_2_t1_3', 1.0),(2, 'global_2_t1_4', 1.0),(2, 'global_2_t1_5', 1.0),(2, 'global_2_t1_6', 1.0)} | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.global_value from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | has{(1, 'global_2_t1_1', 1.0),(1, 'global_2_t1_2', 2.0),(1, 'global_2_t1_3', 3.0),(2, 'global_2_t1_4', 1.0),(2, 'global_2_t1_5', 2.0),(2, 'global_2_t1_6', 3.0)} | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id and t1.id=2 | has{(2, 'global_2_t1_4', 1.0),(2, 'global_2_t1_5', 1.0),(2, 'global_2_t1_6', 1.0)} | schema1 |
      # in sub query
      | conn_2 | False   | select id,global_value,@rownum:=1 from global_2_t1 where parent_id in (select id from sharding_2_t1 where id>1) | has{(4, 'global_2_t1_4', 1.0),(5, 'global_2_t1_5', 1.0),(6, 'global_2_t1_6', 1.0)} | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | has{(2, 'global_2_t1_4', 1.0),(2, 'global_2_t1_5', 1.0),(2, 'global_2_t1_6', 1.0)} | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | has{(1,'a',1,1),(2,'b',1,1)} | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,global_value from global_2_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | has{(4, 'global_2_t1_4', 1.0),(5, 'global_2_t1_5', 2.0),(6, 'global_2_t1_6', 3.0)} | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from global_2_t1) and status=1 | has{(1, 1),(2, 1)} | schema1 |
      | conn_2 | False   | select t2.id,t2.global_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id and t1.id=1 | has{(1, 'global_2_t1_1', 'sharding_2_t1_1', 0),(2, 'global_2_t1_2', 'sharding_2_t1_1', 0),(3, 'global_2_t1_3', 'sharding_2_t1_1', 0)} | schema1 |
      | conn_2 | False   | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | has{('sharding_2_t1_2', 2, 3),('sharding_2_t1_1', 1, 3)} | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs1"
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_2 | False   | explain select a.id,a.code,@rownum:=@rownum-1 from global_2_t1 a, (select @rownum:=0) r order by a.id | success | schema1 |
    Then check resultset "rownum_rs1" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1//dn2         | BASE SQL | SELECT a.id, a.code, @rownum := @rownum - 1 FROM global_2_t1 a, (   SELECT @rownum := 0  ) r ORDER BY a.id LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs2"
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_2 | False   | explain select id, code, @rownum:=@rownum-1 from global_2_t1, (select @rownum:=0) r order by id | success | schema1 |
    Then check resultset "rownum_rs2" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1//dn2         | BASE SQL | SELECT id, code, @rownum := @rownum - 1 FROM global_2_t1, (   SELECT @rownum := 0  ) r ORDER BY id LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs3"
      | conn   | toClose | sql                                                                                                                               | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id order by t2.id desc |
      | dn2              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs4"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select t1.id,t2.global_value from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs4" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.global_value from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.global_value from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
      Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs5"
      | conn   | toClose | sql                                                                                                                       | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id and t1.id=2 | success | schema1 |
    Then check resultset "rownum_rs5" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id and t1.id=2 |
    Then check resultset "rownum_rs5" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id and t1.id=2 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs6"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_2 | False   | explain select id,global_value,@rownum:=1 from global_2_t1 where parent_id in (select id from sharding_2_t1 where id>1) | success | schema1 |
    Then check resultset "rownum_rs6" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,global_value,@rownum:=1 from global_2_t1 where parent_id in (select id from sharding_2_t1 where id>1) |
      | dn2              | BASE SQL | select id,global_value,@rownum:=1 from global_2_t1 where parent_id in (select id from sharding_2_t1 where id>1) |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs7"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs7" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
      | dn2              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs8"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | success | schema1 |
    Then check resultset "rownum_rs8" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
      | dn2              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs9"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select id,global_value from global_2_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs9" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,global_value from global_2_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r |
    Then check resultset "rownum_rs9" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,global_value from global_2_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs10"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from global_2_t1) and status=1 | success | schema1 |
    Then check resultset "rownum_rs10" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from global_2_t1) and status=1 |
      | dn2              | BASE SQL | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from global_2_t1) and status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs11"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select t2.id,t2.global_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id and t1.id=1 | success | schema1 |
    Then check resultset "rownum_rs11" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t2.id,t2.global_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id and t1.id=1 |
    Then check resultset "rownum_rs11" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.id,t2.global_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id and t1.id=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs12"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | success | schema1 |
    Then check resultset "rownum_rs12" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1           | BASE SQL | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id group by t2.parent_id |
      | dn2           | BASE SQL | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id group by t2.parent_id |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect  | db      |
      | conn_2 | True    | drop table if exists sharding_2_t1;drop table if exists global_2_t1  | success | schema1 |

  Scenario: check rownum sql - shardingTable + globalTable - different shardingNode #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <globalTable name="global_2_t1" shardingNode="dn3,dn4" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists global_2_t1                                               | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table global_2_t1 (id int, global_value varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into global_2_t1 values (1, 'global_2_t1_1', 1, 1, 'a'),(2, 'global_2_t1_2', 1, 1, 'b'),(3, 'global_2_t1_3', 1, 2, 'c'),(4, 'global_2_t1_4', 2, 2, 'd'),(5, 'global_2_t1_5', 2, 1, 'e'),(6, 'global_2_t1_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                           | expect  | db      |
      | conn_2 | False   | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id order by t2.id desc | Table 'db1.global_2_t1' doesn't exist | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.global_value from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | Table 'db1.global_2_t1' doesn't exist | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id and t1.id=2 | Table 'db1.global_2_t1' doesn't exist | schema1 |
      # in sub query
      | conn_2 | False   | select id,global_value,@rownum:=1 from global_2_t1 where parent_id in (select id from sharding_2_t1 where id>1) | Table 'db1.global_2_t1' doesn't exist | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | Table 'db1.global_2_t1' doesn't exist | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | Table 'db1.global_2_t1' doesn't exist | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,global_value from global_2_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | Table 'db1.global_2_t1' doesn't exist | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from global_2_t1) and status=1 | Table 'db1.global_2_t1' doesn't exist | schema1 |
      | conn_2 | False   | select t2.id,t2.global_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id and t1.id=1 | Table 'db1.global_2_t1' doesn't exist | schema1 |
      | conn_2 | False   | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | Table 'db1.global_2_t1' doesn't exist | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs1"
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_2 | False   | explain select a.id,a.code,@rownum:=@rownum-1 from global_2_t1 a, (select @rownum:=0) r order by a.id | success | schema1 |
    Then check resultset "rownum_rs1" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn3//dn4         | BASE SQL | SELECT a.id, a.code, @rownum := @rownum - 1 FROM global_2_t1 a, (   SELECT @rownum := 0  ) r ORDER BY a.id LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs2"
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_2 | False   | explain select id, code, @rownum:=@rownum-1 from global_2_t1, (select @rownum:=0) r order by id | success | schema1 |
    Then check resultset "rownum_rs2" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn3//dn4         | BASE SQL | SELECT id, code, @rownum := @rownum - 1 FROM global_2_t1, (   SELECT @rownum := 0  ) r ORDER BY id LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs3"
      | conn   | toClose | sql                                                                                                                               | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id order by t2.id desc |
      | dn2              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1,global_2_t1 t2 where t1.id=t2.parent_id order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs4"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select t1.id,t2.global_value from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs4" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.global_value from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.global_value from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
      Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs5"
      | conn   | toClose | sql                                                                                                                       | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id and t1.id=2 | success | schema1 |
    Then check resultset "rownum_rs5" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id and t1.id=2 |
    Then check resultset "rownum_rs5" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id and t1.id=2 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs6"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_2 | False   | explain select id,global_value,@rownum:=1 from global_2_t1 where parent_id in (select id from sharding_2_t1 where id>1) | success | schema1 |
    Then check resultset "rownum_rs6" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,global_value,@rownum:=1 from global_2_t1 where parent_id in (select id from sharding_2_t1 where id>1) |
      | dn2              | BASE SQL | select id,global_value,@rownum:=1 from global_2_t1 where parent_id in (select id from sharding_2_t1 where id>1) |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs7"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs7" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
      | dn2              | BASE SQL | select t1.id,t2.global_value,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs8"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | success | schema1 |
    Then check resultset "rownum_rs8" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
      | dn2              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs9"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select id,global_value from global_2_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs9" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,global_value from global_2_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r |
    Then check resultset "rownum_rs9" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,global_value from global_2_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs10"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from global_2_t1) and status=1 | success | schema1 |
    Then check resultset "rownum_rs10" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from global_2_t1) and status=1 |
      | dn2              | BASE SQL | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from global_2_t1) and status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs11"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select t2.id,t2.global_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id and t1.id=1 | success | schema1 |
    Then check resultset "rownum_rs11" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t2.id,t2.global_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id and t1.id=1 |
    Then check resultset "rownum_rs11" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.id,t2.global_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join global_2_t1 t2 on t1.id=t2.parent_id and t1.id=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs12"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | success | schema1 |
    Then check resultset "rownum_rs12" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id group by t2.parent_id |
      | dn2              | BASE SQL | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, global_2_t1 t2 where t1.id=t2.parent_id group by t2.parent_id |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect  | db      |
      | conn_2 | True    | drop table if exists sharding_2_t1;drop table if exists global_2_t1  | success | schema1 |

  Scenario: check rownum sql - shardingTable + singleTable - same shardingNode #9
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <singleTable name="single_t1" shardingNode="dn1" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists single_t1                                               | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table single_t1 (id int, single_value varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into single_t1 values (1, 'single_t1_1', 1, 1, 'a'),(2, 'single_t1_2', 1, 1, 'b'),(3, 'single_t1_3', 1, 2, 'c'),(4, 'single_t1_4', 2, 2, 'd'),(5, 'single_t1_5', 2, 1, 'e'),(6, 'single_t1_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                         | expect  | db      |
      | conn_2 | False   | select a.id,a.code,@rownum:=@rownum+1 from single_t1 a, (select @rownum:=0) r order by a.id | has{(1, 'a', 1.0),(2, 'b', 2.0),(3, 'c', 3.0),(4, 'd', 4.0),(5, 'e', 5.0),(6, 'f', 6.0)} | schema1 |
      | conn_2 | False   | select id, code, @rownum:=@rownum+1 from single_t1, (select @rownum:=0) r order by id       | has{(1, 'a', 1.0),(2, 'b', 2.0),(3, 'c', 3.0),(4, 'd', 4.0),(5, 'e', 5.0),(6, 'f', 6.0)} | schema1 |
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc | has{(2, 'single_t1_4', 1.0),(2, 'single_t1_5', 1.0),(2, 'single_t1_6', 1.0)} | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.single_value from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | has{(2, 'single_t1_4', 1.0),(2, 'single_t1_5', 2.0),(2, 'single_t1_6', 3.0)} | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id and t1.id=2 | has{(2, 'single_t1_4', 1.0),(2, 'single_t1_5', 1.0),(2, 'single_t1_6', 1.0)} | schema1 |
      # in sub query
      | conn_2 | False   | select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from sharding_2_t1 where id>1) | has{(4, 'single_t1_4', 1.0),(5, 'single_t1_5', 1.0),(6, 'single_t1_6', 1.0)} | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | has{(2, 'single_t1_4', 1.0),(2, 'single_t1_5', 1.0),(2, 'single_t1_6', 1.0)} | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | has{(2,'b',1,1)} | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,single_value from single_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | has{(4, 'single_t1_4', 1.0),(5, 'single_t1_5', 2.0),(6, 'single_t1_6', 3.0)} | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 | has{(2, 1)} | schema1 |
      | conn_2 | False   | select t2.id,t2.single_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 | has{(1, 'single_t1_1', 'sharding_2_t1_1', 0),(2, 'single_t1_2', 'sharding_2_t1_1', 0),(3, 'single_t1_3', 'sharding_2_t1_1', 0)} | schema1 |
      | conn_2 | False   | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | has{('sharding_2_t1_2', 2, 3)} | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
     """
     the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 match the route penetration regex
     the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 match the route penetration rule, will direct route
     the query select t2.id,t2.single_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration regex
     the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration regex
     the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration rule, will direct route
     """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
     """
     the query select a.id,a.code,@rownum:=@rownum+1 from single_t1 a, (select @rownum:=0) r order by a.id match the route penetration regex
     the query select a.id,a.code,@rownum:=@rownum+1 from single_t1 a, (select @rownum:=0) r order by a.id match the route penetration rule, will direct route
     the query select id, code, @rownum:=@rownum+1 from single_t1, (select @rownum:=0) r order by id match the route penetration regex
     the query select id, code, @rownum:=@rownum+1 from single_t1, (select @rownum:=0) r order by id match the route penetration rule, will direct route
     the query select t2.id,t2.single_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration rule, will direct route
     """
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs1"
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_2 | False   | explain select a.id,a.code,@rownum:=@rownum-1 from single_t1 a, (select @rownum:=0) r order by a.id | success | schema1 |
    Then check resultset "rownum_rs1" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | SELECT a.id, a.code, @rownum := @rownum - 1 FROM single_t1 a, (   SELECT @rownum := 0  ) r ORDER BY a.id LIMIT 100 |
    Then check resultset "rownum_rs1" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | SELECT a.id, a.code, @rownum := @rownum - 1 FROM single_t1 a, (   SELECT @rownum := 0  ) r ORDER BY a.id LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs2"
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_2 | False   | explain select id, code, @rownum:=@rownum-1 from single_t1, (select @rownum:=0) r order by id | success | schema1 |
    Then check resultset "rownum_rs2" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | SELECT id, code, @rownum := @rownum - 1 FROM single_t1, (   SELECT @rownum := 0  ) r ORDER BY id LIMIT 100 |
    Then check resultset "rownum_rs2" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | SELECT id, code, @rownum := @rownum - 1 FROM single_t1, (   SELECT @rownum := 0  ) r ORDER BY id LIMIT 100 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs3"
      | conn   | toClose | sql                                                                                                                             | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc |
    Then check resultset "rownum_rs3" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs4"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select t1.id,t2.single_value from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs4" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.single_value from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
    Then check resultset "rownum_rs4" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.single_value from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
      Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs5"
      | conn   | toClose | sql                                                                                                                       | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id and t1.id=2 | success | schema1 |
    Then check resultset "rownum_rs5" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id and t1.id=2 |
    Then check resultset "rownum_rs5" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id and t1.id=2 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs6"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_2 | False   | explain select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from sharding_2_t1 where id>1) | success | schema1 |
    Then check resultset "rownum_rs6" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from sharding_2_t1 where id>1) |
    Then check resultset "rownum_rs6" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from sharding_2_t1 where id>1) |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs7"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs7" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
    Then check resultset "rownum_rs7" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs8"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | success | schema1 |
    Then check resultset "rownum_rs8" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
    Then check resultset "rownum_rs8" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs9"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select id,single_value from single_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs9" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,single_value from single_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r |
    Then check resultset "rownum_rs9" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,single_value from single_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs10"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 | success | schema1 |
    Then check resultset "rownum_rs10" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 |
    Then check resultset "rownum_rs10" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs11"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select t2.id,t2.single_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 | success | schema1 |
    Then check resultset "rownum_rs11" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2_0           | BASE SQL      | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` where `t1`.`id` = 1 ORDER BY `t1`.`id` ASC                              |
      | merge_1         | MERGE         | dn2_0                                                                                                                                 |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                               |
      | dn1_0           | BASE SQL      | select `t2`.`id`,`t2`.`single_value`,`t2`.`parent_id` from  `single_t1` `t2` where `t2`.`parent_id` = 1 order by `t2`.`parent_id` ASC |
      | merge_2         | MERGE         | dn1_0                                                                                                                                 |
      | join_1          | JOIN          | shuffle_field_1; merge_2                                                                                                              |
      | shuffle_field_2 | SHUFFLE_FIELD | join_1                                                                                                                                |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs12"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | success | schema1 |
    Then check resultset "rownum_rs12" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id |
    Then check resultset "rownum_rs12" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                | expect  | db      |
      | conn_2 | True    | drop table if exists sharding_2_t1;drop table if exists single_t1  | success | schema1 |

  Scenario: check rownum sql - shardingTable + singleTable - different shardingNode #10
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <singleTable name="single_t1" shardingNode="dn3" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                             | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1;drop table if exists single_t1                                               | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int, shard_name varchar(20), parent_id int, status int, code varchar(10))        | success | schema1 |
      | conn_1 | False   | create table single_t1 (id int, single_value varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1, 'sharding_2_t1_1', 1, 1, 'a'),(2, 'sharding_2_t1_2', 1, 1, 'b'),(3, 'sharding_2_t1_3', 1, 2, 'c'),(4, 'sharding_2_t1_4', 2, 2, 'd'),(5, 'sharding_2_t1_5', 2, 1, 'e'),(6, 'sharding_2_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into single_t1 values (1, 'single_t1_1', 1, 1, 'a'),(2, 'single_t1_2', 1, 1, 'b'),(3, 'single_t1_3', 1, 2, 'c'),(4, 'single_t1_4', 2, 2, 'd'),(5, 'single_t1_5', 2, 1, 'e'),(6, 'single_t1_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                           | expect  | db      |
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc | not support assignment | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.single_value from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | not support assignment | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id and t1.id=2 | not support assignment | schema1 |
      # in sub query
      | conn_2 | False   | select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from sharding_2_t1 where id>1) | not support assignment | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | not support assignment | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | not support assignment | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,single_value from single_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r | not support assignment | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 | has{(1,1),(2,1)} | schema1 |
      | conn_2 | False   | select t2.id,t2.single_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 | has{(1,'single_t1_1','sharding_2_t1_1',0),(2,'single_t1_2','sharding_2_t1_1',0),(3,'single_t1_3','sharding_2_t1_1',0)} | schema1 |
      | conn_2 | False   | select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | has{('sharding_2_t1_1',1,3),('sharding_2_t1_2',2,3)} | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.single_value from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration regex
    the query select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration regex
    the query select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from sharding_2_t1 where id>1) match the route penetration regex
    the query select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration regex
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select id,single_value from single_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r match the route penetration regex
    the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 match the route penetration regex
    the query select t2.id,t2.single_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration regex
    the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration regex
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.single_value from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1,single_t1 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration rule, will direct route
    the query select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from sharding_2_t1 where id>1) match the route penetration rule, will direct route
    the query select t1.id,t2.single_value,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration rule, will direct route
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select id,single_value from single_t1 where parent_id in (select id from sharding_2_t1 where id=2)) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 match the route penetration rule, will direct route
    the query select t2.id,t2.single_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration rule, will direct route
    the query select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration rule, will direct route
    """
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs10"
      | conn   | toClose | sql                                                                                                                 | expect  | db      |
      | conn_2 | False   | explain select id,parent_id as rownum from sharding_2_t1 where id in (select parent_id from single_t1) and status=1 | success | schema1 |
    Then check resultset "rownum_rs10" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `sharding_2_t1`.`id`,`sharding_2_t1`.`parent_id` from  `sharding_2_t1` where `sharding_2_t1`.`status` = 1 ORDER BY `sharding_2_t1`.`id` ASC                                                                                                     |
      | dn2_0             | BASE SQL        | select `sharding_2_t1`.`id`,`sharding_2_t1`.`parent_id` from  `sharding_2_t1` where `sharding_2_t1`.`status` = 1 ORDER BY `sharding_2_t1`.`id` ASC                                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                      |
      | dn3_0             | BASE SQL        | select `autoalias_single_t1`.`autoalias_scalar` from (select  distinct `single_t1`.`parent_id` as `autoalias_scalar` from  `single_t1` order by `single_t1`.`parent_id` ASC) autoalias_single_t1 order by `autoalias_single_t1`.`autoalias_scalar` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                                                                                                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                                                 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs11"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select t2.id,t2.single_value,t1.shard_name,0 as rownumabc from sharding_2_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 | success | schema1 |
    Then check resultset "rownum_rs11" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2 |
      | dn2_0           | BASE SQL      | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` where `t1`.`id` = 1 ORDER BY `t1`.`id` ASC                              |
      | merge_1         | MERGE         | dn2_0                                                                                                                                 |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                               |
      | dn3_0           | BASE SQL      | select `t2`.`id`,`t2`.`single_value`,`t2`.`parent_id` from  `single_t1` `t2` where `t2`.`parent_id` = 1 order by `t2`.`parent_id` ASC |
      | merge_2         | MERGE         | dn3_0                                                                                                                                 |
      | join_1          | JOIN          | shuffle_field_1; merge_2                                                                                                              |
      | shuffle_field_2 | SHUFFLE_FIELD | join_1                                                                                                                                |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs12"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select t1.shard_name,t2.parent_id,count(0) as abcrownum from sharding_2_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | success | schema1 |
    Then check resultset "rownum_rs12" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` ORDER BY `t1`.`id` ASC |
      | dn2_0             | BASE SQL        | select `t1`.`shard_name`,`t1`.`id` from  `sharding_2_t1` `t1` ORDER BY `t1`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                    |
      | dn3_0             | BASE SQL        | select `t2`.`parent_id` from  `single_t1` `t2` order by `t2`.`parent_id` ASC         |
      | merge_1           | MERGE           | dn3_0                                                                                |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                             |
      | direct_group_1    | DIRECT_GROUP    | join_1                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | direct_group_1                                                                       |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                | expect  | db      |
      | conn_2 | True    | drop table if exists sharding_2_t1;drop table if exists single_t1  | success | schema1 |

  Scenario: check rownum sql - shardingTable + singleTable - same shardingNode #11
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="global_t1" shardingNode="dn1,dn2" />
        <singleTable name="single_t1" shardingNode="dn1" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                            | expect  | db      |
      | conn_1 | False   | drop table if exists global_t1;drop table if exists single_t1                                                  | success | schema1 |
      | conn_1 | False   | create table global_t1 (id int, global_name varchar(20), parent_id int, status int, code varchar(10))          | success | schema1 |
      | conn_1 | False   | create table single_t1 (id int, single_value varchar(20), parent_id int, status int, code varchar(10))         | success | schema1 |
      | conn_1 | False   | insert into global_t1 values (1, 'global_t1_1', 1, 1, 'a'),(2, 'global_t1_2', 1, 1, 'b'),(3, 'global_t1_3', 1, 2, 'c'),(4, 'global_t1_4', 2, 2, 'd'),(5, 'global_t1_5', 2, 1, 'e'),(6, 'global_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into single_t1 values (1, 'single_t1_1', 1, 1, 'a'),(2, 'single_t1_2', 1, 1, 'b'),(3, 'single_t1_3', 1, 2, 'c'),(4, 'single_t1_4', 2, 2, 'd'),(5, 'single_t1_5', 2, 1, 'e'),(6, 'single_t1_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                         | expect  | db      |
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc | has{(1, 'single_t1_1', 1.0),(1, 'single_t1_2', 1.0),(1, 'single_t1_3', 1.0),(2, 'single_t1_4', 1.0),(2, 'single_t1_5', 1.0),(2, 'single_t1_6', 1.0)} | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.single_value from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | has{(1, 'single_t1_1', 1.0),(1, 'single_t1_2', 2.0),(1, 'single_t1_3', 3.0),(2, 'single_t1_4', 4.0),(2, 'single_t1_5', 5.0),(2, 'single_t1_6', 6.0)} | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id and t1.id=2 | has{(2, 'single_t1_4', 1.0),(2, 'single_t1_5', 1.0),(2, 'single_t1_6', 1.0)} | schema1 |
      # in sub query
      | conn_2 | False   | select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from global_t1 where id>1) | has{(4, 'single_t1_4', 1.0),(5, 'single_t1_5', 1.0),(6, 'single_t1_6', 1.0)} | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | has{(2, 'single_t1_4', 1.0),(2, 'single_t1_5', 1.0),(2, 'single_t1_6', 1.0)} | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | has{(2,'b',1,1)} | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,single_value from single_t1 where parent_id in (select id from global_t1 where id=2)) a,(select @rownum:=0) r | has{(4, 'single_t1_4', 1.0),(5, 'single_t1_5', 2.0),(6, 'single_t1_6', 3.0)} | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from global_t1 where id in (select parent_id from single_t1) and status=1 | has{(2, 1)} | schema1 |
      | conn_2 | False   | select t2.id,t2.single_value,t1.global_name,0 as rownumabc from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 | has{(1, 'single_t1_1', 'global_t1_1', 0),(2, 'single_t1_2', 'global_t1_1', 0),(3, 'single_t1_3', 'global_t1_1', 0)} | schema1 |
      | conn_2 | False   | select t1.global_name,t2.parent_id,count(0) as abcrownum from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | has{('global_t1_2', 2, 3)} | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs3"
      | conn   | toClose | sql                                                                                                                               | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc |
   Then check resultset "rownum_rs3" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs4"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select t1.id,t2.single_value from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs4" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.single_value from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
   Then check resultset "rownum_rs4" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select t1.id,t2.single_value from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r |
      Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs5"
      | conn   | toClose | sql                                                                                                                       | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.single_value,@rownum:=1 from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id and t1.id=2 | success | schema1 |
    Then check resultset "rownum_rs5" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id and t1.id=2 |
    Then check resultset "rownum_rs5" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id and t1.id=2 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs6"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_2 | False   | explain select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from global_t1 where id>1) | success | schema1 |
    Then check resultset "rownum_rs6" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from global_t1 where id>1) |
   Then check resultset "rownum_rs6" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from global_t1 where id>1) |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs7"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t1.id,t2.single_value,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | success | schema1 |
    Then check resultset "rownum_rs7" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
   Then check resultset "rownum_rs7" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs8"
      | conn   | toClose | sql                                                                                                                   | expect  | db      |
      | conn_2 | False   | explain select t2.parent_id,t1.code,t1.status,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | success | schema1 |
    Then check resultset "rownum_rs8" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
   Then check resultset "rownum_rs8" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t2.parent_id,t1.code,t1.status,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs9"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select a.*,@rownum:=@rownum-1 from (select id,single_value from single_t1 where parent_id in (select id from global_t1 where id=2)) a,(select @rownum:=0) r | success | schema1 |
    Then check resultset "rownum_rs9" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,single_value from single_t1 where parent_id in (select id from global_t1 where id=2)) a,(select @rownum:=0) r |
    Then check resultset "rownum_rs9" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select a.*,@rownum:=@rownum-1 from (select id,single_value from single_t1 where parent_id in (select id from global_t1 where id=2)) a,(select @rownum:=0) r |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs10"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select id,parent_id as rownum from global_t1 where id in (select parent_id from single_t1) and status=1 | success | schema1 |
    Then check resultset "rownum_rs10" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select id,parent_id as rownum from global_t1 where id in (select parent_id from single_t1) and status=1 |
   Then check resultset "rownum_rs10" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select id,parent_id as rownum from global_t1 where id in (select parent_id from single_t1) and status=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs11"
      | conn   | toClose | sql                                                                                                                         | expect  | db      |
      | conn_2 | False   | explain select t2.id,t2.single_value,t1.global_name,0 as rownumabc from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 | success | schema1 |
    Then check resultset "rownum_rs11" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t2.id,t2.single_value,t1.global_name,0 as rownumabc from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 |
    Then check resultset "rownum_rs11" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t2.id,t2.single_value,t1.global_name,0 as rownumabc from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rownum_rs12"
      | conn   | toClose | sql                                                                                                                     | expect  | db      |
      | conn_2 | False   | explain select t1.global_name,t2.parent_id,count(0) as abcrownum from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | success | schema1 |
    Then check resultset "rownum_rs12" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn1              | BASE SQL | select t1.global_name,t2.parent_id,count(0) as abcrownum from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id |
   Then check resultset "rownum_rs12" has not lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2 |
      | dn2              | BASE SQL | select t1.global_name,t2.parent_id,count(0) as abcrownum from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect  | db      |
      | conn_2 | True    | drop table if exists global_t1;drop table if exists single_t1  | success | schema1 |

  Scenario: check rownum sql - shardingTable + singleTable - different shardingNode #12
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="global_t1" shardingNode="dn1,dn2" />
        <singleTable name="single_t1" shardingNode="dn3" />
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                         | expect  | db      |
      | conn_1 | False   | drop table if exists global_t1;drop table if exists single_t1                                               | success | schema1 |
      | conn_1 | False   | create table global_t1 (id int, global_name varchar(20), parent_id int, status int, code varchar(10))       | success | schema1 |
      | conn_1 | False   | create table single_t1 (id int, single_value varchar(20), parent_id int, status int, code varchar(10))      | success | schema1 |
      | conn_1 | False   | insert into global_t1 values (1, 'global_t1_1', 1, 1, 'a'),(2, 'global_t1_2', 1, 1, 'b'),(3, 'global_t1_3', 1, 2, 'c'),(4, 'global_t1_4', 2, 2, 'd'),(5, 'global_t1_5', 2, 1, 'e'),(6, 'global_t1_6', 2, 1, 'f') | success | schema1 |
      | conn_1 | True    | insert into single_t1 values (1, 'single_t1_1', 1, 1, 'a'),(2, 'single_t1_2', 1, 1, 'b'),(3, 'single_t1_3', 1, 2, 'c'),(4, 'single_t1_4', 2, 2, 'd'),(5, 'single_t1_5', 2, 1, 'e'),(6, 'single_t1_6', 2, 1, 'f') | success | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableRoutePenetration/d
    /-DroutePenetrationRules/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableRoutePenetration=1
    $a -DroutePenetrationRules={"rules":[{"regex":".*rownum.*","partMatch":true,"caseSensitive":true}]}
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                           | expect  | db      |
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc | Table 'db2.global_t1' doesn't exist | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select t1.id,t2.single_value from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r | Table 'db2.global_t1' doesn't exist | schema1 |
      # sharding column
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id and t1.id=2 | Table 'db2.global_t1' doesn't exist | schema1 |
      # in sub query
      | conn_2 | False   | select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from global_t1 where id>1) | Table 'db2.global_t1' doesn't exist | schema1 |
      # join, order by
      | conn_2 | False   | select t1.id,t2.single_value,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc | Table 'db2.global_t1' doesn't exist | schema1 |
      # join, group by, having
      | conn_2 | False   | select t2.parent_id,t1.code,t1.status,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 | Table 'db2.global_t1' doesn't exist | schema1 |
      | conn_2 | False   | select a.*,@rownum:=@rownum+1 from (select id,single_value from single_t1 where parent_id in (select id from global_t1 where id=2)) a,(select @rownum:=0) r | Table 'db2.global_t1' doesn't exist | schema1 |
      | conn_2 | False   | select id,parent_id as rownum from global_t1 where id in (select parent_id from single_t1) and status=1 | Table 'db2.global_t1' doesn't exist | schema1 |
      | conn_2 | False   | select t2.id,t2.single_value,t1.global_name,0 as rownumabc from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 | Table 'db2.global_t1' doesn't exist | schema1 |
      | conn_2 | False   | select t1.global_name,t2.parent_id,count(0) as abcrownum from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id | Table 'db2.global_t1' doesn't exist | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    the query select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration regex
    the query select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id order by t2.id desc match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.single_value from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select t1.id,t2.single_value from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id order by t2.id) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration regex
    the query select t1.id,t2.single_value,@rownum:=1 from global_t1 t1,single_t1 t2 where t1.id=t2.parent_id and t1.id=2 match the route penetration rule, will direct route
    the query select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from global_t1 where id>1) match the route penetration regex
    the query select id,single_value,@rownum:=1 from single_t1 where parent_id in (select id from global_t1 where id>1) match the route penetration rule, will direct route
    the query select t1.id,t2.single_value,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration regex
    the query select t1.id,t2.single_value,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id where t2.parent_id>1 order by t2.id desc match the route penetration rule, will direct route
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration regex
    the query select t2.parent_id,t1.code,t1.status,@rownum:=1 from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id group by t2.parent_id,t1.code,t1.status having t1.status=1 match the route penetration rule, will direct route
    the query select a.*,@rownum:=@rownum+1 from (select id,single_value from single_t1 where parent_id in (select id from global_t1 where id=2)) a,(select @rownum:=0) r match the route penetration regex
    the query select a.*,@rownum:=@rownum+1 from (select id,single_value from single_t1 where parent_id in (select id from global_t1 where id=2)) a,(select @rownum:=0) r match the route penetration rule, will direct route
    the query select id,parent_id as rownum from global_t1 where id in (select parent_id from single_t1) and status=1 match the route penetration regex
    the query select id,parent_id as rownum from global_t1 where id in (select parent_id from single_t1) and status=1 match the route penetration rule, will direct route
    the query select t2.id,t2.single_value,t1.global_name,0 as rownumabc from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration regex
    the query select t2.id,t2.single_value,t1.global_name,0 as rownumabc from global_t1 t1 join single_t1 t2 on t1.id=t2.parent_id and t1.id=1 match the route penetration rule, will direct route
    the query select t1.global_name,t2.parent_id,count(0) as abcrownum from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration regex
    the query select t1.global_name,t2.parent_id,count(0) as abcrownum from global_t1 t1, single_t1 t2 where t1.id=t2.parent_id group by t2.parent_id match the route penetration rule, will direct route
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect  | db      |
      | conn_2 | True    | drop table if exists global_t1;drop table if exists single_t1  | success | schema1 |