# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2022/11/18

Feature: sqldump log test  3.22.11


  Scenario: check invalid sqldump log parameters in bootstrap.cnf #1
    #### sqlDumpLogCompressFilePattern  would automatic error correction to default value
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       /-DsqlDumpLogBasePath/d
       /-DsqlDumpLogFileName/d
       /-DsqlDumpLogCompressFilePattern/d
       /-DsqlDumpLogSizeBasedRotate/d
       /-DsqlDumpLogCompressFilePath/d

       $a\-DsqlDumpLogBasePath=abc
       $a\-DsqlDumpLogFileName=abc
       $a\-DsqlDumpLogCompressFilePattern=abc
       $a\-DsqlDumpLogSizeBasedRotate=abc
       $a\-DsqlDumpLogCompressFilePath=abc
       """
    Then Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sqldump_log_rs1"
      | conn   | toClose | sql                                                                                              | db               |
      | conn_0 | true    | select variable_name, variable_value from dble_variables where variable_name like '%sqlDumpLog%' | dble_information |
    Then check resultset "sqldump_log_rs1" has lines with following column values
      | variable_name-0               | variable_value-1             |
      | enableSqlDumpLog              | 0                            |
      | sqlDumpLogBasePath            | abc                          |
      | sqlDumpLogFileName            | abc                          |
      | sqlDumpLogCompressFilePattern | abc                          |
      | sqlDumpLogOnStartupRotate     | 1                            |
      | sqlDumpLogSizeBasedRotate     | 52428800                     |
      | sqlDumpLogTimeBasedRotate     | 1                            |
      | sqlDumpLogDeleteFileAge       | 90d                          |
      | sqlDumpLogCompressFilePath    | abc                          |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       /-DenableSqlDumpLog/d
       /-DsqlDumpLogOnStartupRotate/d
       /-DsqlDumpLogTimeBasedRotate/d
       /-DsqlDumpLogDeleteFileAge/d

       $a\-DenableSqlDumpLog=abc
       $a\-DsqlDumpLogOnStartupRotate=abc
       $a\-DsqlDumpLogTimeBasedRotate=abc
       $a\-DsqlDumpLogDeleteFileAge=abc
       """
    Then restart dble in "dble-1" failed for
       """
       Property \[ enableSqlDumpLog \] 'abc' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
       Property \[ sqlDumpLogOnStartupRotate \] 'abc' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
       Property \[ sqlDumpLogTimeBasedRotate \] 'abc' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
       Property \[ sqlDumpLogDeleteFileAge \] 'abc' in bootstrap.cnf is illegal, you may need use the default value 90d replaced
       """



  Scenario: check default value sqldump log parameters in bootstrap.cnf #2
    # check default value
    Then check following text exist "N" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
      """
      -DenableSqlDumpLog=0
      -DsqlDumpLogBasePath=sqldump
      -DsqlDumpLogFileName=sqldump.log
      -DsqlDumpLogCompressFilePattern=${date:yyyy-MM}/sqldump-%d{MM-dd}-%i.log.gz
      -DsqlDumpLogOnStartupRotate=1
      -DsqlDumpLogSizeBasedRotate=52428800
      -DsqlDumpLogTimeBasedRotate=1
      -DsqlDumpLogDeleteFileAge=90d
      -DsqlDumpLogCompressFilePath=*/sqldump-*.log.gz
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sqldump_log_rs1"
      | conn   | toClose | sql                                                                                              | db               |
      | conn_0 | true    | select variable_name, variable_value from dble_variables where variable_name like '%sqlDumpLog%' | dble_information |
    Then check resultset "sqldump_log_rs1" has lines with following column values
      | variable_name-0               | variable_value-1                            |
      | enableSqlDumpLog              | 0                                           |
      | sqlDumpLogBasePath            | sqldump                                     |
      | sqlDumpLogFileName            | sqldump.log                                 |
      | sqlDumpLogCompressFilePattern | ${date:yyyy-MM}/sqldump-%d{MM-dd}-%i.log.gz |
      | sqlDumpLogOnStartupRotate     | 1                                           |
      | sqlDumpLogSizeBasedRotate     | 52428800                                    |
      | sqlDumpLogTimeBasedRotate     | 1                                           |
      | sqlDumpLogDeleteFileAge       | 90d                                         |
      | sqlDumpLogCompressFilePath    | */sqldump-*.log.gz                          |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       $a\-DenableSqlDumpLog=
       $a\-DsqlDumpLogBasePath=
       $a\-DsqlDumpLogFileName=
       $a\-DsqlDumpLogCompressFilePattern=
       $a\-DsqlDumpLogOnStartupRotate=
       $a\-DsqlDumpLogSizeBasedRotate=
       $a\-DsqlDumpLogTimeBasedRotate=
       $a\-DsqlDumpLogDeleteFileAge=
       $a\-DsqlDumpLogCompressFilePath=
       """
    Then Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sqldump_log_rs2"
      | sql             |
      | show @@sysparam |
    Then check resultset "sqldump_log_rs2" has lines with following column values
      | PARAM_NAME-0                  | PARAM_VALUE-1                               | PARAM_DESCR-2                                                                                           |
      | enableSqlDumpLog              | 0                                           | Whether enable sqlDumpLog, the default value is 0(off)                                                  |
      | sqlDumpLogBasePath            | sqldump                                     | The base path of sqldump log, the default value is 'sqldump'                                            |
      | sqlDumpLogFileName            | sqldump.log                                 | The sqldump log file name, the default value is 'sqldump.log'                                           |
      | sqlDumpLogCompressFilePattern | ${date:yyyy-MM}/sqldump-%d{MM-dd}-%i.log.gz | The compression of sqldump log file, the default value is '${date:yyyy-MM}/sqldump-%d{MM-dd}-%i.log.gz' |
      | sqlDumpLogOnStartupRotate     | 1                                           | The onStartup of rotate policy, the default value is 1; -1 said not to participate in the strategy      |
      | sqlDumpLogSizeBasedRotate     | 52428800                                    | The sizeBased of rotate policy, the default value is '50 MB'; default unit is byte                      |
      | sqlDumpLogTimeBasedRotate     | 1                                           | The timeBased of rotate policy, the default value is 1; -1 said not to participate in the strategy      |
      | sqlDumpLogDeleteFileAge       | 90d                                         | The expiration time deletion strategy, the default value is '90d'                                       |
      | sqlDumpLogCompressFilePath    | */sqldump-*.log.gz                          | The compression of sqldump log file path, the default value is '*/sqldump-*.log.gz'                     |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       /-DenableSqlDumpLog/d
       /-DsqlDumpLogOnStartupRotate/d
       /-DsqlDumpLogTimeBasedRotate/d
       /-DsqlDumpLogDeleteFileAge/d
       /-DsqlDumpLogBasePath/d
       /-DsqlDumpLogFileName/d
       /-DsqlDumpLogCompressFilePattern/d
       /-DsqlDumpLogSizeBasedRotate/d
       /-DsqlDumpLogCompressFilePath/d

       $a\-DenableSqlDumpLog=-1
       $a\-DsqlDumpLogBasePath=-1
       $a\-DsqlDumpLogFileName=-1
       $a\-DsqlDumpLogCompressFilePattern=-1
       $a\-DsqlDumpLogOnStartupRotate=-1
       $a\-DsqlDumpLogSizeBasedRotate=-1
       $a\-DsqlDumpLogTimeBasedRotate=-1
       $a\-DsqlDumpLogDeleteFileAge=-1
       $a\-DsqlDumpLogCompressFilePath=-1
       """
    Then Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sqldump_log_rs3"
      | conn   | toClose | sql                                                                  | db               |
      | conn_0 | true    | select * from dble_variables where variable_name like '%sqlDumpLog%' | dble_information |
    Then check resultset "sqldump_log_rs3" has lines with following column values
      | variable_name-0               | variable_value-1                            | comment-2                                                                                               | read_only-3 |
      | enableSqlDumpLog              | 0                                           | Whether enable sqlDumpLog, the default value is 0(off)                                                  | false       |
      | sqlDumpLogBasePath            | sqldump                                     | The base path of sqldump log, the default value is 'sqldump'                                            | true        |
      | sqlDumpLogFileName            | sqldump.log                                 | The sqldump log file name, the default value is 'sqldump.log'                                           | true        |
      | sqlDumpLogCompressFilePattern | ${date:yyyy-MM}/sqldump-%d{MM-dd}-%i.log.gz | The compression of sqldump log file, the default value is '${date:yyyy-MM}/sqldump-%d{MM-dd}-%i.log.gz' | true        |
      | sqlDumpLogOnStartupRotate     | 1                                           | The onStartup of rotate policy, the default value is 1; -1 said not to participate in the strategy      | true        |
      | sqlDumpLogSizeBasedRotate     | 52428800                                    | The sizeBased of rotate policy, the default value is '50 MB'; default unit is byte                      | true        |
      | sqlDumpLogTimeBasedRotate     | 1                                           | The timeBased of rotate policy, the default value is 1; -1 said not to participate in the strategy      | true        |
      | sqlDumpLogDeleteFileAge       | 90d                                         | The expiration time deletion strategy, the default value is '90d'                                       | true        |
      | sqlDumpLogCompressFilePath    | */sqldump-*.log.gz                          | The compression of sqldump log file path, the default value is '*/sqldump-*.log.gz'                     | true        |



  Scenario: check manager command: enable @@sqldump_sql, disable @@sqldump_sql        #3

     ####  check manager command: enable @@sqldump_sql and configuration save file on bootstrap.dynamic.cnf
    Then execute admin cmd "enable @@sqldump_sql"
    Then check path "/opt/dble/sqldump/sqldump.log" in "dble-1" should exist
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
       """
       enableSqlDumpLog=1
       """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                   | expect                                                                                               | db               |
      | conn_0 | false   | select * from dble_variables where  variable_name ="enablesqldumpLog" | has{(('enableSqlDumpLog', '1', 'Whether enable sqlDumpLog, the default value is 0(off)', 'false'),)} | dble_information |

     ####  check manager command: enable @@sqldump_sql and configuration save file on bootstrap.dynamic.cnf
    Then execute admin cmd "disable @@sqldump_sql"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                                                                               | db               |
      | conn_0 | true    | select * from dble_variables where  variable_name ="enablesqldumpLog"  | has{(('enableSqlDumpLog', '0', 'Whether enable sqlDumpLog, the default value is 0(off)', 'false'),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
       """
       enableSqlDumpLog=0
       """

    Then execute admin cmd "enable @@sqldump_sql"
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                                                                               | db               |
      | conn_0 | true    | select * from dble_variables where  variable_name ="enablesqldumpLog"  | has{(('enableSqlDumpLog', '1', 'Whether enable sqlDumpLog, the default value is 0(off)', 'false'),)} | dble_information |
    Then check path "/opt/dble/sqldump/sqldump.log" in "dble-1" should exist
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableSqlDumpLog/d
    $a\-DenableSqlDumpLog=0
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                                                                               | db               |
      | conn_0 | true    | select * from dble_variables where  variable_name ="enablesqldumpLog"  | has{(('enableSqlDumpLog', '1', 'Whether enable sqlDumpLog, the default value is 0(off)', 'false'),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
       """
       enableSqlDumpLog=1
       """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
       """
       DenableSqlDumpLog=0
       """

    Then execute admin cmd "disable @@sqldump_sql"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DenableSqlDumpLog/d
    $a\-DenableSqlDumpLog=1
    """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                                                                               | db               |
      | conn_0 | true    | select * from dble_variables where  variable_name ="enablesqldumpLog"  | has{(('enableSqlDumpLog', '0', 'Whether enable sqlDumpLog, the default value is 0(off)', 'false'),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
       """
       enableSqlDumpLog=0
       """
    Then check path "/opt/dble/sqldump/sqldump.log" in "dble-1" should exist
    Given delete file "/opt/dble/sqldump/sqldump.log" on "dble-1"



  Scenario: managerUser shardingUser would not recorded  but analysisUser would recorded      #4

     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
        """
        <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.10:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
        </dbGroup>
        """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
        """
        <analysisUser name="ana1" password="111111" dbGroup="ha_group3" tenant="tenant1" />
        """
    Then execute admin cmd "reload @@config"
    Then execute admin cmd "enable @@sqldump_sql"

    Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose | sql                                                                    | expect                                                                                               | db               |
       | conn_0 | true    | select * from dble_variables where  variable_name ="enablesqldumpLog"  | has{(('enableSqlDumpLog', '1', 'Whether enable sqlDumpLog, the default value is 0(off)', 'false'),)} | dble_information |
       | conn_0 | false   | enable @@general_log                                                   | success                                                                                              | dble_information |
    Then execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                       | expect             | db      |
       | conn_1 | true   | create table if not exists test (id int)   | success            | schema1 |
    Then execute sql in "dble-1" in "user" mode
       | user          | passwd | conn   | toClose | sql         | expect   |
       | ana1:tenant1  | 111111 | conn_2 | False   | select 1    | success  |
       | ana1:tenant1  | 111111 | conn_2 | true    | show tables | success  |
    Then check following text exist "N" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       select \* from dble_variables
       enable @@general_log
       create table if not exists test
       """
    Then check following text exist "Y" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       SELECT \?
       show tables
       """
    Then check following text exist "Y" in file "/opt/dble/general/general.log" in host "dble-1"
       """
       create table if not exists test
       select 1
       show tables
       """



  Scenario: check sqldump log records  dml ddl set hint loaddate complex query  - rwSplitser user   #5
    Given delete file "/opt/dble/sqldump/sqldump.log" on "dble-1"
    Given delete the following xml segment
      | file          | parent           | child                   |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser'}  |

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
       """
       <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="3" primary="true" readWeight="3"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="3" readWeight="3"/>
          <dbInstance name="hostM3" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="3" readWeight="3"/>
        </dbGroup>
       """

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group1" />
       <rwSplitUser name="rw2" password="111111" dbGroup="ha_group2" />
       """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DrwStickyTime=0
      """
    Then restart dble in "dble-1" success
    Then execute admin cmd "enable @@sqldump_sql"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                      | expect                                      | db  |
      | rw1  | 111111 | conn_1 | False   | select version()                                                                                                         | success                                     |     |
      | rw1  | 111111 | conn_1 | False   | show databases                                                                                                           | success                                     |     |
      | rw1  | 111111 | conn_1 | False   | show tables                                                                                                              | No database selected                        |     |
      | rw1  | 111111 | conn_1 | False   | use db1                                                                                                                  | success                                     |     |
      | rw1  | 111111 | conn_1 | False   | show tables                                                                                                              | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | drop table if exists test_table1                                                                                         | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | create table test_table1(id int, name varchar(20),age int)                                                               | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | desc test_table1                                                                                                         | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | explain select * from test_table1 limit 10                                                                               | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | insert into test_table1 values (1,"name1",1),(2,"name2",2),(3,"name3",3),(4,"name4",4)                                   | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | drop table if exists test_table2                                                                                         | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | create table test_table2(id int, name varchar(20),age int)                                                               | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | insert into test_table2(id,name,age) select id,name,age from db1.test_table1                                             | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | select * from test_table2                                                                                                | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | update test_table2 set name=age+1                                                                                        | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | delete from test_table2 where id=1                                                                                       | success                                     | db2 |
      ####  complex sql  recorded
      | rw1  | 111111 | conn_1 | False   | update test_table2 set name="test_name" where id in (select id from db1.test_table1)                                     | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | update test_table2 a,db1.test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2                                         | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | select n.id,s.name from test_table2 n join db1.test_table1 s on n.id=s.id                                                | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | select * from test_table2 where age <> (select age from db1.test_table1 where id !=1)                                    | Subquery returns more than 1 row            | db2 |
      | rw1  | 111111 | conn_1 | False   | select * from test_table2 where age in (select age from db1.test_table1 where id !=1)                                    | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | delete test_table2 from test_table2,db1.test_table1 where test_table2.id=1 and test_table1.id =1                         | success                                     | db2 |
      | rw1  | 111111 | conn_1 | False   | delete from db1.test_table1 where name in ((select age from (select name,age from test_table2 order by id desc) as tmp)) | success                                     | db2 |
      #### view  recorded
      | rw1  | 111111 | conn_1 | False   | drop view if exists test_view                                                                                            | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | create view test_view(id,name,age) AS select * from test_table1                                                          | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | select * from test_view union select * from test_table1                                                                  | success                                     | db1 |
      | rw1  | 111111 | conn_1 | False   | drop view test_view                                                                                                      | success                                     | db1 |
      ####  alias  recorded
      | rw1  | 111111 | conn_1 | False   | select * from (select s.sno from test_table1 s where s.id=1)                                                             | Every derived table must have its own alias | db1 |
      #### error SQL syntax  recorded
      | rw1  | 111111 | conn_1 | False   | abc                                                                                                                      | error in your SQL syntax                    | db1 |
      | rw1  | 111111 | conn_1 | False   | drop table if exists test_table1                                                                                         | success                                     | db2 |
      | rw1  | 111111 | conn_1 | true    | drop table if exists test_table2                                                                                         | success                                     | db1 |
      ####  error sql   not recorded
      | rw2  | 111111 | conn_2 | true    | set a=111                                                                                                                | Unknown system variable 'a'                 | db1 |
    Given sleep "1" seconds
    Then check following text exist "Y" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       \[d1fd99b5\]\[Select\]\[1\]\[1\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* select version\(\)
       \[5bd944f5\]\[Show\]\[2\].*\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* show databases
       \[1c28e4e8\]\[Show\]\[3\].*\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* show tables
       \[f715b95a\]\[Other\]\[4\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* use db1
       \[1c28e4e8\]\[Show\]\[5\].*\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* show tables
       \[3ae4b7ec\]\[DDL\]\[6\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* DROP TABLE IF EXISTS test_table1
       \[6c3b6c76\]\[DDL\]\[7\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* CREATE TABLE test_table1 \(  id int,  name varchar\(20\),  age int \)
       \[2c556761\]\[Other\]\[8\]\[3\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* desc test_table1
       \[4968cda5\]\[Other\]\[9\]\[1\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* EXPLAIN SELECT \* FROM test_table1 LIMIT ?
       \[e84f1b5d\]\[Insert\]\[10\]\[4\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* INSERT INTO test_table1 VALUES \(\?, \?, \?\)
       \[3ae4b7ed\]\[DDL\]\[11\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* DROP TABLE IF EXISTS test_table2
       \[73a0a195\]\[DDL\]\[12\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* CREATE TABLE test_table2 \(  id int,  name varchar\(20\),  age int \)
       \[2bfe9a5e\]\[Insert\]\[13\]\[4\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* insert into test_table2\(id,name,age\) select id,name,age from db1.test_table1
       \[563705d5\]\[Select\]\[14\]\[4\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* select \* from test_table2
       \[f89f1695\]\[Update\]\[15\]\[4\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* UPDATE test_table2 SET name = age \+ \?
       \[14cf9760\]\[Delete\]\[16\]\[1\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* DELETE FROM test_table2 WHERE id = \?
       \[58d6e18d\]\[Update\]\[17\]\[3\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* UPDATE test_table2 SET name = \? WHERE id IN \(   SELECT id   FROM db1.test_table1  \)
       \[9090bff1\]\[Update\]\[18\]\[1\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* UPDATE test_table2 a, db1.test_table1 b SET a.age = b.age \- \? WHERE a.id = \?  AND b.id = \?
       \[37c9233b\]\[Select\]\[19\]\[3\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* select n.id,s.name from test_table2 n join db1.test_table1 s on n.id=s.id
       \[2f655407\]\[Select\]\[20\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* SELECT \* FROM test_table2 WHERE age <> \(  SELECT age  FROM db1.test_table1  WHERE id != \? \)
       \[ea659244\]\[Select\]\[21\]\[2\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* SELECT \* FROM test_table2 WHERE age IN \(  SELECT age  FROM db1.test_table1  WHERE id != \? \)
       \[2950e7a9\]\[Delete\]\[22\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* DELETE test_table2 FROM test_table2, db1.test_table1 WHERE test_table2.id = \?  AND test_table1.id = \?
       \[92c7b07a\]\[Delete\]\[23\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* delete from db1.test_table1 where name in \(\(select age from \(select name,age from test_table2 order by id desc\) as tmp\)\)
       \[2b858627\]\[DDL\]\[24\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* DROP VIEW IF EXISTS test_view
       \[6c4122ef\]\[DDL\]\[25\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* CREATE VIEW test_view \(  id,   name,   age \) AS SELECT \* FROM test_table1
       \[a9322a39\]\[Select\]\[26\]\[4\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* select \* from test_view union select \* from test_table1
       \[8bb4bc8\]\[DDL\]\[27\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* DROP VIEW test_view
       \[275d0ea2\]\[Select\]\[28\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* SELECT \* FROM \(  SELECT s.sno  FROM test_table1 s  WHERE s.id = \? \)
       \[17862\]\[Other\]\[29\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* Other
       \[3ae4b7ec\]\[DDL\]\[30\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* DROP TABLE IF EXISTS test_table1
       \[3ae4b7ed\]\[DDL\]\[31\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* DROP TABLE IF EXISTS test_table2
       """
    Then check following text exist "N" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       \[OTHER\]\[32\]
       """

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rw2  | 111111 | conn_1 | False   | drop table if exists tb1                                  | success | db1 |
      | rw2  | 111111 | conn_1 | False   | create table tb1(id int, name varchar(20))                | success | db1 |
      ##### hint sql  recorded  DBLE0REQ-2083
      | rw2  | 111111 | conn_1 | False   | /*!dble:db_type=slave*/insert into tb1 values (1,1),(2,2) | success | db1 |
      | rw2  | 111111 | conn_1 | False   | /*!dble:db_type=master*/select * from tb1                 | success | db1 |
      #####  set values not recorded id=5
      | rw2  | 111111 | conn_1 | False   | SET @i =1, @j = 2                                         | success | db1 |

    Given sleep "1" seconds
    Then check following text exist "Y" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       rw2
       DROP TABLE IF EXISTS tb1
       CREATE TABLE tb1 \(  id int,  name varchar\(20\) \)
       INSERT INTO tb1 VALUES \(\?, \?\)
       select \* from tb1
       """
    Then check following text exist "N" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       \[OTHER\]\[5\].*SET.*1.*2
       """

   #######case : load data
    Given execute oscmd in "mysql-master2"
       """
       echo -e '1,abc\n2,\n3,qwe' > /root/sandboxes/sandbox/master/data/test.txt
       """
    Given execute sql "10" times in "dble-1" at concurrent
      | user | passwd | conn   | toClose | sql                                                                                                                                             | expect         | db  |
      | rw2  | 111111 | conn_1 | False   | load data infile '/root/sandboxes/sandbox/master/data/test.txt' into table db1.tb1 fields terminated by ',' lines terminated by '\n'            | success        | db1 |
    Given sleep "1" seconds
    Then check following text exist "Y" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       \[360b80bc\]\[Loaddata\].*\[3\]\[rw2\]\[172.100.9.8:.*\]\[172.100.9.6:3306\].* LOAD DATA INFILE \? INTO TABLE db1.tb1 COLUMNS TERMINATED BY \? LINES TERMINATED BY \?
       """
    Then check the occur times of following key in file "/opt/dble/sqldump/sqldump.log" in "dble-1"
      | key                                   | occur_times |
      | LOAD DATA INFILE                      | 10          |
      | 360b80bc                              | 10          |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rw2  | 111111 | conn_1 | true    | drop table if exists tb1                                  | success | db1 |
    Given execute oscmd in "mysql-master2"
       """
       rm -rf /root/sandboxes/sandbox/master/data/test.txt
       """
    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"



  Scenario: check sqldump log records muliti sql   - rwSplitser user   #6
    Given delete file "/opt/dble/sqldump/sqldump.log" on "dble-1"
    Given delete the following xml segment
      | file          | parent           | child                   |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser'}  |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group1" />
       """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "enable @@sqldump_sql"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                      | expect  | db  |
      | rw1  | 111111 | conn_1 | False   | select 5;show tables; show databases     | success | db1 |
      | rw1  | 111111 | conn_1 | False   | begin; begin; rollback                   | success | db1 |
      | rw1  | 111111 | conn_1 | False   | set autocommit=0; begin; begin; rollback | success | db1 |
      
    Given sleep "1" seconds
    Then check following text exist "Y" in file "/opt/dble/sqldump/sqldump.log" in host "dble-1"
       """
       \[75abde1b\]\[Select\]\[1\]\[1\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* SELECT \?
       \[1c28e4e8\]\[Show\]\[2\].*\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* show tables
       \[5bd944f5\]\[Show\]\[3\].*\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* show databases
       \[59478a9\]\[Begin\]\[3\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* begin
       \[59478a9\]\[Begin\]\[4\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* begin
       \[f084fee4\]\[Rollback\]\[5\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* rollback
       \[978c3540\]\[Set\]\[5\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* SET autocommit = \?
       \[59478a9\]\[Begin\]\[6\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* begin
       \[59478a9\]\[Begin\]\[7\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* begin
       \[f084fee4\]\[Rollback\]\[8\]\[0\]\[rw1\]\[172.100.9.8:.*\]\[172.100.9.5:3306\].* rollback
       """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      exception occurred when the statistics were recorded
      Exception processing
      """