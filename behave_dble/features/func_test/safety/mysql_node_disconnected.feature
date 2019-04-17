# Created by maofei at 2019/4/16
Feature: #mysql node disconnected,check the change of dble
  # Enter feature description here

  Scenario: # only one mysql noed and it was disconnected    #1
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose  | sql                                     | expect  | db     |
      | test | 111111 | conn_0 | True    | create database if not exists da1   | success |        |
      | test | 111111 | conn_0 | True    | create database if not exists da2   | success |        |
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
    """
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.5" database="da1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.5" database="da2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />
    """
    Then execute admin cmd "Reload @@config_all"
    Given stop mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd    | conn   | toClose | sql      | expect  | db       |
      | root  | 111111    | conn_0 | True    | dryrun   | hasStr{Get Vars from backend failed,Maybe all backend MySQL can't connected} |  |
      | root  | 111111    | conn_0 | True    | dryrun   | hasStr{Get Vars from backend failed,Maybe all backend MySQL can't connected} |  |
      | root  | 111111    | conn_0 | True    | reload @@config_all   | Reload config failure.The reason is Can't get variables from any data host, because all of data host can't connect to MySQL correctly |  |
    Then restart dble in "dble-1" failed for
    """
    Can't get variables from data node
    """
    Given start mysql in host "mysql-master1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd    | conn   | toClose | sql                     | expect                                                                                    | db |
      | root  | 111111    | conn_0 | True    | dryrun                  | hasNoStr{Get Vars from backend failed,Maybe all backend MySQL can't connected} |     |
      | root  | 111111    | conn_0 | True    | reload @@config_all   | success                                                                                   |     |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                             | expect   | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test    | success  | schema1 |
      | test | 111111 | conn_0 | True    | create table test(id int)    | success  | schema1 |

  Scenario: # some of the backend nodes was disconnected   #2
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
    """
    Then execute admin cmd "Reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                             | expect   | db      |
      | test | 111111 | conn_0 | True    | drop table if exists test_table             | success  | schema1 |
      | test | 111111 | conn_0 | True    | create table test_table(id int,pad int)    | success  | schema1 |
    Given stop mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd    | conn   | toClose | sql                     | expect                                                                                                  | db  |
      | root  | 111111    | conn_0 | True    | dryrun                  | hasStr{dataNode[dn3] has no available writeHost,The table in this dataNode has not checked} |     |
      | root  | 111111    | conn_0 | True    | reload @@config_all   | there are some datasource connection failed                                                        |     |
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                       | expect                 | db      |
      | test | 111111 | conn_0 | True    | insert into test_table values(1,3)    | success                | schema1 |
      | test | 111111 | conn_0 | True    | insert into test_table values(2,4)    | error totally whack  | schema1 |
    Given start mysql in host "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                       | expect   | db      |
      | test | 111111 | conn_0 | True    | insert into test_table values(1,3)    | success  | schema1 |
      | test | 111111 | conn_0 | True    | insert into test_table values(2,4)    | success  | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd    | conn   | toClose | sql                     | expect                                                                                                     | db |
      | root  | 111111    | conn_0 | True    | dryrun                  | hasNoStr{dataNode[dn3] has no available writeHost,The table in this dataNode has not checked} |     |
      | root  | 111111    | conn_0 | True    | reload @@config_all   | success                                                                                                    |     |