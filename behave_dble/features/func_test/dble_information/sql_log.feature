# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2021/3/22

Feature:test sql_log and sql_log_by_tx_by_entry_by_user
#DBLE0REQ-985
sql_log
sql_log_by_tx_by_entry_by_user
sql_log_by_digest_by_entry_by_user
sql_log_by_tx_digest_by_entry_by_user



  Scenario: desc table and unsupported dml  #1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                        | expect        | db               |
      | conn_0 | False   | desc sql_log                               | length{(13)}  | dble_information |
      | conn_0 | False   | desc sql_log_by_tx_by_entry_by_user        | length{(10)}  | dble_information |
      | conn_0 | False   | desc sql_log_by_digest_by_entry_by_user    | length{(8)}   | dble_information |
      | conn_0 | False   | desc sql_log_by_tx_digest_by_entry_by_user | length{(11)}  | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_1"
      | conn   | toClose | sql          | db               |
      | conn_0 | False   | desc sql_log | dble_information |
    Then check resultset "table_1" has lines with following column values
      | Field-0       | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | sql_id        | int(11)       | NO     | PRI   | None      |         |
      | sql_stmt      | varchar(1024) | NO     |       | None      |         |
      | sql_digest    | varchar(1024) | NO     |       | None      |         |
      | sql_type      | varchar(16)   | NO     |       | None      |         |
      | tx_id         | int(11)       | NO     | PRI   | None      |         |
      | entry         | int(11)       | NO     |       | None      |         |
      | user          | varchar(20)   | NO     |       | None      |         |
      | source_host   | varchar(20)   | NO     |       | None      |         |
      | source_port   | int(11)       | NO     |       | None      |         |
      | rows          | int(11)       | NO     |       | None      |         |
      | examined_rows | int(11)       | NO     |       | None      |         |
      | start_time    | int(11)       | NO     |       | None      |         |
      | duration      | int(11)       | NO     |       | None      |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_2"
      | conn   | toClose | sql                                 | db               |
      | conn_0 | False   | desc sql_log_by_tx_by_entry_by_user | dble_information |
    Then check resultset "table_2" has lines with following column values
      | Field-0       | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | tx_id         | int(11)       | NO     | PRI   | None      |         |
      | entry         | int(11)       | NO     |       | None      |         |
      | user          | varchar(20)   | NO     |       | None      |         |
      | source_host   | varchar(20)   | NO     |       | None      |         |
      | source_port   | int(11)       | NO     |       | None      |         |
#      | sql_ids       | varchar(1024) | NO     |       | None      |         |
      | sql_exec      | int(11)       | NO     |       | None      |         |
      | tx_duration   | int(11)       | NO     |       | None      |         |
      | busy_time     | int(11)       | NO     |       | None      |         |
      | examined_rows | int(11)       | NO     |       | None      |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_3"
      | conn   | toClose | sql                                     | db               |
      | conn_0 | False   | desc sql_log_by_digest_by_entry_by_user | dble_information |
    Then check resultset "table_3" has lines with following column values
      | Field-0       | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | sql_digest    | int(11)     | NO     |       | None      |         |
      | entry         | int(11)     | NO     |       | None      |         |
      | user          | varchar(20) | NO     |       | None      |         |
      | exec          | int(11)     | NO     |       | None      |         |
      | duration      | int(11)     | NO     |       | None      |         |
      | rows          | int(11)     | NO     |       | None      |         |
      | examined_rows | int(11)     | NO     |       | None      |         |
      | avg_duration  | int(11)     | NO     |       | None      |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_4"
      | conn   | toClose | sql                                        | db               |
      | conn_0 | False   | desc sql_log_by_tx_digest_by_entry_by_user | dble_information |
    Then check resultset "table_4" has lines with following column values
      | Field-0       | Type-1        | Null-2 | Key-3 | Default-4 | Extra-5 |
      | tx_digest     | varchar(1024) | NO     | PRI   | None      |         |
      | exec          | int(11)       | NO     | PRI   | None      |         |
      | entry         | int(11)       | NO     |       | None      |         |
      | user          | varchar(20)   | NO     |       | None      |         |
      | sql_exec      | int(11)       | NO     |       | None      |         |
      | source_host   | varchar(20)   | NO     |       | None      |         |
      | source_port   | int(11)       | NO     |       | None      |         |
#      | sql_ids       | VARCHAR(1024) | NO     |       | None      |         |
      | tx_duration   | int(11)       | NO     |       | None      |         |
      | busy_time     | int(11)       | NO     |       | None      |         |
      | examined_rows | int(11)       | NO     |       | None      |         |

    #case unsupported update/delete/insert
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                              | expect                                                   | db               |
      | conn_0 | False   | delete from sql_log where entry=1                                | Access denied for table 'sql_log'                        | dble_information |
      | conn_0 | False   | update sql_log set entry=22 where entry=1                        | Access denied for table 'sql_log'                        | dble_information |
      | conn_0 | True    | insert into sql_log (entry) values (22)                          | Access denied for table 'sql_log'                        | dble_information |
#      | conn_0 | False   | delete from sql_log_by_tx_by_entry_by_user where entry=1         | Access denied for table 'sql_log_by_tx_by_entry_by_user' | dble_information |
#      | conn_0 | False   | update sql_log_by_tx_by_entry_by_user set entry=22 where entry=1 | Access denied for table 'sql_log_by_tx_by_entry_by_user' | dble_information |
#      | conn_0 | True    | insert into sql_log_by_tx_by_entry_by_user (entry) values (22)   | Access denied for table 'sql_log_by_tx_by_entry_by_user' | dble_information |


  Scenario: samplingRate/sqlLogTableSize in bootstrap.cnf and reload @@samplingRate and reload @@sqlLogTableSize  #2

    #case check defalut values
    Then check following text exist "N" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
      """
      -DsamplingRate=0
      -DsqlLogTableSize=1024
      """
    #error values
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DsamplingRate=-1
    $a -DsqlLogTableSize=-1
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ samplingRate \] '-1' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
    Property \[ sqlLogTableSize \] '-1' in bootstrap.cnf is illegal, you may need use the default value 1024 replaced
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DsamplingRate=1000
    $a -DsqlLogTableSize=99.99
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ samplingRate \] '1000' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
    property \[ sqlLogTableSize \] '99.99' data type should be int
    """

   #case set correct values
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /DsqlLogTableSize/d
    /# processor/a -DsamplingRate=100
    /# processor/a -DsqlLogTableSize=100
    """
    Given Restart dble in "dble-1" success
   #case check dble_information.dble_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_1"
      | conn   | toClose | sql                                                                                                                                                         | db               |
      | conn_0 | true    | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('enableStatistic' ,'samplingRate','sqlLogTableSize')       | dble_information |
    Then check resultset "res_1" has lines with following column values
      | variable_name-0 | variable_value-1|
      | enableStatistic | false           |
      | samplingRate    | 100             |
      | sqlLogTableSize | 100             |

  #case : reload @@samplingRate and reload @@sqlLogTableSize
    Then execute admin cmd "reload @@samplingRate=0"
    Then execute admin cmd "reload @@statistic_table_size =1024 where table ='sql_log'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_2"
      | conn   | toClose | sql                                                                                                                                      | db               |
      | conn_0 | true    | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('samplingRate','sqlLogTableSize')       | dble_information |
    Then check resultset "res_2" has lines with following column values
      | variable_name-0 | variable_value-1|
      | samplingRate    | 0               |
      | sqlLogTableSize | 1024            |
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      sqlLogTableSize=1024
      """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_3"
      | conn   | toClose | sql                                                                                                                                      | db               |
      | conn_0 | true    | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('samplingRate','sqlLogTableSize')       | dble_information |
    Then check resultset "res_3" has lines with following column values
      | variable_name-0 | variable_value-1|
      | samplingRate    | 0               |
      | sqlLogTableSize | 1024            |

    Then execute admin cmd "reload @@samplingRate=100"
    Then execute admin cmd "reload @@statistic_table_size =2000"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "res_3"
      | conn   | toClose | sql                                                                                                                                      | db               |
      | conn_0 | true    | select variable_name,variable_value from dble_information.dble_variables where variable_name in ('samplingRate','sqlLogTableSize')       | dble_information |
    Then check resultset "res_3" has lines with following column values
      | variable_name-0 | variable_value-1|
      | samplingRate    | 100             |
      | sqlLogTableSize | 2000            |
   #case check bootstrap.dynamic.cnf
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      samplingRate=100
      sqlLogTableSize=2000
      """

   #samplingRate 100% but disable @@statistic
    Then execute admin cmd "disable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                | expect                                | db      |
      | conn_1 | False   | SELECT 1           | success                               | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(1)} | dble_information |

   # samplingRate 100% and enable @@statistic
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                    | expect                                | db      |
      | conn_1 | False   | SELECT 2               | success                               | schema1 |
    Then execute admin cmd "disable @@statistic"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(2)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(2)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(1)} | dble_information |

      | conn_0 | False   | reload @@samplingRate=10%                         | value of samplingRate is incorrect, the value is integer between 0 and 100 | dble_information |
      | conn_0 | False   | reload @@samplingRate=10.0                        | value of samplingRate is incorrect, the value is integer between 0 and 100 | dble_information |
      | conn_0 | False   | reload @@samplingRate=1000                        | value of samplingRate is incorrect, the value is integer between 0 and 100 | dble_information |

      | conn_0 | False   | reload @@statistic_table_size =1024 where table ='sql_log_by_tx_by_entry_by_user'     | Table `dble_information`.`sql_log_by_tx_by_entry_by_user` don't belong to statistic tables | dble_information |
      | conn_0 | False   | reload @@statistic_table_size =99999999999999 where table ='sql_log'                  | tableSize setting is not correct | dble_information |
      | conn_0 | False   | reload @@statistic_table_size =99.99 where table ='sql_log'                           | tableSize setting is not correct | dble_information |
      | conn_0 | False   | reload @@statistic_table_size =0 where table ='sql_log'                               | tableSize must be greater than 0 | dble_information |

      | conn_0 | False   | reload @@statistic_table_size =1                    | success     | dble_information |
      | conn_0 | False   | select * from sql_log                               | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(1)} | dble_information |

      | conn_0 | False   | reload @@statistic_table_size =100                  | success     | dble_information |
      | conn_0 | False   | select * from sql_log                               | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(1)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(1)} | dble_information |

    Given execute sql "100" times in "dble-1" at concurrent
      | sql             | db      |
      | select 1        | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect        | db               |
      | conn_0 | False   | select * from sql_log                               | length{(100)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(100)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(1)}   | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user | length{(1)}   | dble_information |

     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | reload @@samplingRate=100                           | success     | dble_information |
      | conn_0 | False   | reload @@statistic_table_size =10000                | success     | dble_information |
    Given execute sql "1024" times in "dble-1" at concurrent
      | sql             | db      |
      | select 2        | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect         | db               |
      | conn_0 | False   | select * from sql_log                               | length{(1124)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(1124)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(1)}    | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user | length{(1)}    | dble_information |



  Scenario: test samplingRate=0    #3

    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2">
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>

    <schema shardingNode="dn1" name="schema3" >
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /# processor/a -DsamplingRate=0
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_1 | False   | drop table if exists test1                | success | schema1 |
      | conn_1 | False   | create table test1 (id int,name char(20)) | success | schema1 |
      | conn_1 | False   | insert into test1 values (1,1),(2,2)      | success | schema1 |
      | conn_1 | False   | select * from test1                       | success | schema1 |
      | conn_1 | False   | update test1 set name= '3' where id=1     | success | schema1 |
      | conn_1 | False   | delete from test1 where id=6              | success | schema1 |
      | conn_1 | False   | select 5                                  | success | schema1 |
      | conn_1 | False   | show databases                            | success | schema1 |
      | conn_1 | False   | truncate test1                            | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

    Then execute admin cmd "disable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,2)           | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | select 2                                      | success | db1 |
      | rwS2 | 111111 | conn_4 | False   | drop table if exists test_table               | success | db2 |
      | rwS2 | 111111 | conn_4 | False   | create table test_table(id int,name char(20)) | success | db2 |
      | rwS2 | 111111 | conn_4 | False   | insert into test_table values (1,2)           | success | db2 |
      | rwS2 | 111111 | conn_4 | true    | select 2                                      | success | db2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_1 | true    | drop table if exists test1                | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | true    | drop table if exists test_table               | success | db1 |
      | rwS2 | 111111 | conn_4 | true    | drop table if exists test_table               | success | db2 |


  Scenario: test samplingRate=100 and simple sql   #4
    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /DsamplingRate/d
    /# processor/a -DsamplingRate=100
    """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_1 | False   | drop table if exists test1                | success | schema1 |
      | conn_1 | False   | create table test1 (id int,name char(20)) | success | schema1 |
      | conn_1 | False   | insert into test1 values (1,1),(2,2)      | success | schema1 |
      | conn_1 | False   | select * from test1                       | success | schema1 |
      | conn_1 | False   | update test1 set name= '3' where id=1     | success | schema1 |
      | conn_1 | False   | delete from test1 where id=6              | success | schema1 |
      | conn_1 | False   | select 5                                  | success | schema1 |
      | conn_1 | False   | show databases                            | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table               | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name char(20)) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,2)           | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | select 2                                      | success | db1 |
#DBLE0REQ-1112
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect       | db               |
      | conn_0 | False   | select * from sql_log                                               | length{(12)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user                        | length{(12)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user                    | length{(12)} | dble_information |
#      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user                 | length{(12)} | dble_information |


    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                    | sql_digest-2                                        | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | drop table if exists test1                    | DROP TABLE IF EXISTS test1                          | DDL        | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 2        | create table test1 (id int,name char(20))     | CREATE TABLE test1 (  id int,  name char(20) )      | DDL        | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 3        | insert into test1 values (1,1),(2,2)          | INSERT INTO test1 VALUES (?, ?)                     | Insert     | 3       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 4        | select * from test1                           | select * from test1                                 | Select     | 4       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 5        | update test1 set name= '3' where id=1         | UPDATE test1 SET name = ? WHERE id = ?              | Update     | 5       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 6        | delete from test1 where id=6                  | DELETE FROM test1 WHERE id = ?                      | Delete     | 6       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 7        | select 5                                      | SELECT ?                                            | Select     | 7       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 8        | show databases                                | show databases                                      | Show       | 8       | 2       | test   | 172.100.9.8   | 8066          | 1      | 0                |
      | 9        | drop table if exists test_table               | DROP TABLE IF EXISTS test_table                     | DDL        | 9       | 3       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 10       | create table test_table(id int,name char(20)) | CREATE TABLE test_table (  id int,  name char(20) ) | DDL        | 10      | 3       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 11       | insert into test_table values (1,2)           | INSERT INTO test_table VALUES (?, ?)                | Insert     | 11      | 3       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |
      | 12       | select 2                                      | SELECT ?                                            | Select     | 12      | 3       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6  | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1         | 1           | 0               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 2         | 1           | 0               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 3         | 1           | 2               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 4         | 1           | 2               |
      | 5       | 2       | test   | 172.100.9.8   | 8066          | 5         | 1           | 1               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 6         | 1           | 0               |
      | 7       | 2       | test   | 172.100.9.8   | 8066          | 7         | 1           | 1               |
      | 8       | 2       | test   | 172.100.9.8   | 8066          | 8         | 1           | 0               |
      | 9       | 3       | rwS1   | 172.100.9.8   | 8066          | 9         | 1           | 0               |
      | 10      | 3       | rwS1   | 172.100.9.8   | 8066          | 10        | 1           | 0               |
      | 11      | 3       | rwS1   | 172.100.9.8   | 8066          | 11        | 1           | 1               |
      | 12      | 3       | rwS1   | 172.100.9.8   | 8066          | 12        | 1           | 1               |

#DBLE0REQ-1112
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                        | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | CREATE TABLE test1 (  id int,  name char(20) )      | 2       | test   | 1      | 0      | 0               |
      | CREATE TABLE test_table (  id int,  name char(20) ) | 3       | rwS1   | 1      | 0      | 0               |
      | DELETE FROM test1 WHERE id = ?                      | 2       | test   | 1      | 0      | 0               |
      | DROP TABLE IF EXISTS test1                          | 2       | test   | 1      | 0      | 0               |
      | DROP TABLE IF EXISTS test_table                     | 3       | rwS1   | 1      | 0      | 0               |
      | INSERT INTO test1 VALUES (?, ?)                     | 2       | test   | 1      | 2      | 2               |
      | INSERT INTO test_table VALUES (?, ?)                | 3       | rwS1   | 1      | 1      | 1               |
      | select * from test1                                 | 2       | test   | 1      | 2      | 2               |
      | SELECT ?                                            | 3       | rwS1   | 1      | 1      | 1               |
      | SELECT ?                                            | 2       | test   | 1      | 1      | 1               |
      | show databases                                      | 2       | test   | 1      | 1      | 0               |
      | UPDATE test1 SET name = ? WHERE id = ?              | 2       | test   | 1      | 1      | 1               |


    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                         | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | CREATE TABLE test1 (  id int,  name char(20) )      | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 2         | 0                |
      | CREATE TABLE test_table (  id int,  name char(20) ) | 1      | rwS1   | 3       | 1          | 172.100.9.8   | 8066          | 10        | 0                |
      | DELETE FROM test1 WHERE id = ?                      | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 6         | 0                |
      | DROP TABLE IF EXISTS test1                          | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 1         | 0                |
      | DROP TABLE IF EXISTS test_table                     | 1      | rwS1   | 3       | 1          | 172.100.9.8   | 8066          | 9         | 0                |
      | INSERT INTO test1 VALUES (?, ?)                     | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 3         | 2                |
      | INSERT INTO test_table VALUES (?, ?)                | 1      | rwS1   | 3       | 1          | 172.100.9.8   | 8066          | 11        | 1                |
      | select * from test1                                 | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 4         | 2                |
#      | SELECT ?                                            | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 7         | 1                |
#      | SELECT ?                                            | 1      | rwS1   | 3       | 1          | 172.100.9.8   | 8066          | 12        | 1                |
      | show databases                                      | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 8         | 0                |
      | UPDATE test1 SET name = ? WHERE id = ?              | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 5         | 1                |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user      | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | length{(0)}  | dble_information |


    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_1 | False   | drop view if exists view_test                    | success | schema1 |
      | conn_1 | False   | create view view_test as select * from test1     | success | schema1 |
      | conn_1 | False   | select * from view_test                          | success | schema1 |
      | conn_1 | False   | drop view view_test                              | success | schema1 |
      | conn_1 | False   | truncate  test1                                  | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                   | sql_digest-2                                 | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 13       | drop view if exists view_test                | DROP VIEW IF EXISTS view_test                | Other      | 13      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 14       | create view view_test as select * from test1 | CREATE VIEW view_test AS SELECT * FROM test1 | Other      | 14      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 15       | select * from view_test                      | select * from view_test                      | Select     | 15      | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 16       | drop view view_test                          | DROP VIEW view_test                          | Other      | 16      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 17       | truncate  test1                              | truncate  test1                              | DDL        | 17      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6  | examined_rows-9 |
      | 13      | 2       | test   | 172.100.9.8   | 8066          | 13        | 1           | 0               |
      | 14      | 2       | test   | 172.100.9.8   | 8066          | 14        | 1           | 0               |
      | 15      | 2       | test   | 172.100.9.8   | 8066          | 15        | 1           | 2               |
      | 16      | 2       | test   | 172.100.9.8   | 8066          | 16        | 1           | 0               |
      | 17      | 2       | test   | 172.100.9.8   | 8066          | 17        | 1           | 0               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                 | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | CREATE VIEW view_test AS SELECT * FROM test1 | 2       | test   | 1      | 0      | 0               |
      | DROP VIEW IF EXISTS view_test                | 2       | test   | 1      | 0      | 0               |
      | DROP VIEW view_test                          | 2       | test   | 1      | 0      | 0               |
      | select * from view_test                      | 2       | test   | 1      | 2      | 2               |
      | truncate  test1                              | 2       | test   | 1      | 0      | 0               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                  | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | CREATE VIEW view_test AS SELECT * FROM test1 | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 14        | 0                |
      | DROP VIEW IF EXISTS view_test                | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 13        | 0                |
      | DROP VIEW view_test                          | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 16        | 0                |
      | select * from view_test                      | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 15        | 2                |
      | truncate  test1                              | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 17        | 0                |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_1 | true    | drop table if exists test1                | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                           | expect  | db  |
      | rwS1 | 111111 | conn_3 | true    | drop table if exists test_table               | success | db1 |


   Scenario: test samplingRate=100 and complex sql   #5
    #CASE PREPARE env
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema2">
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2,"/>
    <shardingUser name="test1" password="111111" schemas="schema1,schema2"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     $a -DinSubQueryTransformToJoin=true
    """
    Then restart dble in "dble-1" success

    #case for mysql 5.7 shrdinguser
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists test                                                            | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                   | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.global2                                                 | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sharding2                                               | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sing1                                                   | success | schema1 |
      | conn_1 | False   | create table test (id int,name char(20))                                             | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name char(20))                                    | success | schema1 |
      | conn_1 | False   | create table schema2.global2 (id int,name char(20))                                  | success | schema1 |
      | conn_1 | False   | create table schema2.sharding2 (id int,name char(20))                                | success | schema1 |
      | conn_1 | False   | create table schema2.sing1 (id int,name char(20))                                    | success | schema1 |
      | conn_1 | False   | insert into test values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')              | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')     | success | schema1 |
      | conn_1 | False   | insert into schema2.global2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')   | success | schema1 |
      | conn_1 | False   | insert into schema2.sharding2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_1 | true    | insert into schema2.sing1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')     | success | schema1 |

    Then execute admin cmd "enable @@statistic"
    Then execute admin cmd "reload @@samplingRate=100"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                              | success | schema1 |
      | conn_1 | False   | insert into test(id, name) select id,name from schema2.global2                                                         | success | schema1 |
      | conn_1 | False   | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                  | success | schema1 |
      | conn_1 | False   | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                          | success | schema1 |
      | conn_1 | False   | select * from test a inner join sharding_2_t1 b on a.name=b.name where a.id =1                                         | success | schema1 |
      | conn_1 | False   | select * from schema2.global2 a inner join sharding_2_t1 b on a.name=b.name where a.id =1                              | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1                                | success | schema1 |
      | conn_1 | False   | select * from sharding_2_t1 where name in (select name from schema2.sharding2 where id !=1)                            | success | schema1 |
      | conn_1 | False   | update test set name= '3' where name = (select name from schema2.global2 order by id desc limit 1)                     | success | schema1 |
      | conn_1 | False   | update test set name= '4' where name in (select name from schema2.global2 )                                            | success | schema1 |
      | conn_1 | False   | update sharding_2_t1 a,schema2.sharding2 b set a.name=b.name where a.id=2 and b.id=2                                   | success | schema1 |
      | conn_1 | False   | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1 | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                                                             | sql_digest-2                                                                                                                | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                              | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                                   | Insert     | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 2        | insert into test(id, name) select id,name from schema2.global2                                                         | insert into test(id, name) select id,name from schema2.global2                                                              | Insert     | 2       | 2       | test   | 172.100.9.8   | 8066          | 4      | 16               |
      | 3        | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                  | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                       | Insert     | 3       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 4        | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                          | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                               | Insert     | 4       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 5        | select * from test a inner join sharding_2_t1 b on a.name=b.name where a.id =1                                         | SELECT * FROM test a  INNER JOIN sharding_2_t1 b ON a.name = b.name WHERE a.id = ?                                          | Select     | 5       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 6        | select * from schema2.global2 a inner join sharding_2_t1 b on a.name=b.name where a.id =1                              | SELECT * FROM schema2.global2 a  INNER JOIN sharding_2_t1 b ON a.name = b.name WHERE a.id = ?                               | Select     | 6       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 7        | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1                                | SELECT * FROM sharding_2_t1 a  INNER JOIN schema2.sing1 b ON a.name = b.name WHERE a.id = ?                                 | Select     | 7       | 2       | test   | 172.100.9.8   | 8066          | 4      | 10               |
      | 8        | select * from sharding_2_t1 where name in (select name from schema2.sharding2 where id !=1)                            | SELECT * FROM sharding_2_t1 WHERE name IN (  SELECT name  FROM schema2.sharding2  WHERE id != ? )                           | Select     | 8       | 2       | test   | 172.100.9.8   | 8066          | 6      | 11               |
      | 9        | update test set name= '3' where name = (select name from schema2.global2 order by id desc limit 1)                     | UPDATE test SET name = ? WHERE name = (   SELECT name   FROM schema2.global2   ORDER BY id DESC   LIMIT ?  )                | Update     | 9       | 2       | test   | 172.100.9.8   | 8066          | 2      | 8                |
      | 10       | update test set name= '4' where name in (select name from schema2.global2 )                                            | UPDATE test SET name = ? WHERE name IN (   SELECT name   FROM schema2.global2  )                                            | Update     | 10      | 2       | test   | 172.100.9.8   | 8066          | 6      | 24               |
      | 11       | update sharding_2_t1 a,schema2.sharding2 b set a.name=b.name where a.id=2 and b.id=2                                   | UPDATE sharding_2_t1 a, schema2.sharding2 b SET a.name = b.name WHERE a.id = ?  AND b.id = ?                                | Update     | 11      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 12       | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1 | DELETE schema1.sharding_2_t1 FROM sharding_2_t1, schema2.sharding2 WHERE sharding_2_t1.id = ?  AND schema2.sharding2.id = ? | Delete     | 12      | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1         | 1           | 4               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 2         | 1           | 16              |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 3         | 1           | 4               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 4         | 1           | 4               |
      | 5       | 2       | test   | 172.100.9.8   | 8066          | 5         | 1           | 4               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 6         | 1           | 2               |
      | 7       | 2       | test   | 172.100.9.8   | 8066          | 7         | 1           | 10              |
      | 8       | 2       | test   | 172.100.9.8   | 8066          | 8         | 1           | 11              |
      | 9       | 2       | test   | 172.100.9.8   | 8066          | 9         | 1           | 8               |
      | 10      | 2       | test   | 172.100.9.8   | 8066          | 10        | 1           | 24              |
      | 11      | 2       | test   | 172.100.9.8   | 8066          | 11        | 1           | 0               |
      | 12      | 2       | test   | 172.100.9.8   | 8066          | 12        | 1           | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                                                                                                | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | DELETE schema1.sharding_2_t1 FROM sharding_2_t1, schema2.sharding2 WHERE sharding_2_t1.id = ?  AND schema2.sharding2.id = ? | 2       | test   | 1      | 2      | 2               |
      | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                               | 2       | test   | 1      | 4      | 4               |
      | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                       | 2       | test   | 1      | 4      | 4               |
      | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                                   | 2       | test   | 1      | 4      | 4               |
      | insert into test(id, name) select id,name from schema2.global2                                                              | 2       | test   | 1      | 4      | 16              |
      | SELECT * FROM schema2.global2 a  INNER JOIN sharding_2_t1 b ON a.name = b.name WHERE a.id = ?                               | 2       | test   | 1      | 2      | 2               |
      | SELECT * FROM sharding_2_t1 a  INNER JOIN schema2.sing1 b ON a.name = b.name WHERE a.id = ?                                 | 2       | test   | 1      | 4      | 10              |
      | SELECT * FROM sharding_2_t1 WHERE name IN (  SELECT name  FROM schema2.sharding2  WHERE id != ? )                           | 2       | test   | 1      | 6      | 11              |
      | SELECT * FROM test a  INNER JOIN sharding_2_t1 b ON a.name = b.name WHERE a.id = ?                                          | 2       | test   | 1      | 4      | 4               |
      | UPDATE sharding_2_t1 a, schema2.sharding2 b SET a.name = b.name WHERE a.id = ?  AND b.id = ?                                | 2       | test   | 1      | 0      | 0               |
      | UPDATE test SET name = ? WHERE name = (   SELECT name   FROM schema2.global2   ORDER BY id DESC   LIMIT ?  )                | 2       | test   | 1      | 2      | 8               |
      | UPDATE test SET name = ? WHERE name IN (   SELECT name   FROM schema2.global2  )                                            | 2       | test   | 1      | 6      | 24              |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                                 | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | DELETE schema1.sharding_2_t1 FROM sharding_2_t1, schema2.sharding2 WHERE sharding_2_t1.id = ?  AND schema2.sharding2.id = ? | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 12        | 2                |
      | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                               | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 4         | 4                |
      | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                       | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 3         | 4                |
      | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                                   | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 1         | 4                |
      | insert into test(id, name) select id,name from schema2.global2                                                              | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 2         | 16               |
      | SELECT * FROM schema2.global2 a  INNER JOIN sharding_2_t1 b ON a.name = b.name WHERE a.id = ?                               | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 6         | 2                |
      | SELECT * FROM sharding_2_t1 a  INNER JOIN schema2.sing1 b ON a.name = b.name WHERE a.id = ?                                 | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 7         | 10               |
      | SELECT * FROM sharding_2_t1 WHERE name IN (  SELECT name  FROM schema2.sharding2  WHERE id != ? )                           | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 8         | 11               |
      | SELECT * FROM test a  INNER JOIN sharding_2_t1 b ON a.name = b.name WHERE a.id = ?                                          | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 5         | 4                |
      | UPDATE sharding_2_t1 a, schema2.sharding2 b SET a.name = b.name WHERE a.id = ?  AND b.id = ?                                | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 11        | 0                |
      | UPDATE test SET name = ? WHERE name = (   SELECT name   FROM schema2.global2   ORDER BY id DESC   LIMIT ?  )                | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 9         | 8                |
      | UPDATE test SET name = ? WHERE name IN (   SELECT name   FROM schema2.global2  )                                            | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 10        | 24               |

    #case mysql 8.0 shrdinguser   sql_id:13-24
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                               | expect  | db      |
      | test1 | 111111 | conn_2 | False   | drop table if exists no_sharding_t1                               | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists schema2.no_shar                              | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists sharding_2_t1                                | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists schema2.sharding2                            | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table no_sharding_t1(id int, name varchar(20),age int)     | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table sharding_2_t1(id int, name varchar(20),age int)      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table schema2.no_shar(id int, name varchar(20),age int)    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table schema2.sharding2(id int, name varchar(20),age int)  | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into no_sharding_t1 values (1,'name1',1),(2,'name2',2)     | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into sharding_2_t1 values (1,'name1',1),(2,'name2',2)      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into schema2.no_shar values (1,'name1',1),(2,'name2',2)    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into schema2.sharding2 values (1,'name1',1),(2,'name2',2)  | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user      | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | length{(0)}  | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                                                                           | expect  | db      |
      | test1 | 111111 | conn_2 | False   | insert into no_sharding_t1(id,name,age) select id,name,age from schema2.no_shar                                               | success | schema1 |
      | test1 | 111111 | conn_2 | False   | update no_sharding_t1 set name='test_name' where id in (select id from schema2.no_shar)                                       | success | schema1 |
      | test1 | 111111 | conn_2 | False   | update no_sharding_t1 set age=age-1 where name != (select name from schema2.no_shar where name ='name1')                      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select n.id,s.name from no_sharding_t1 n join schema2.no_shar s on n.id=s.id                                                  | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select * from no_sharding_t1 where age <> (select age from schema2.no_shar where id !=1)                                      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | delete from schema2.no_shar where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp))   | success | schema1 |

      | test1 | 111111 | conn_2 | False   | insert into sharding_2_t1 (id) select id from schema2.sharding2                                                              | success | schema1 |
      | test1 | 111111 | conn_2 | False   | update sharding_2_t1 a,schema2.sharding2 b set a.age=b.age-1 where a.id=2 and b.id=2                                         | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select n.id,s.name from sharding_2_t1 n join schema2.sharding2 s on n.id=s.id                                                | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select * from sharding_2_t1 where age <> (select age from schema2.sharding2 where id !=1)                                    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1       | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                                                                  | sql_digest-2                                                                                                                | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 25       | insert into no_sharding_t1(id,name,age) select id,name,age from schema2.no_shar                                             | insert into no_sharding_t1(id,name,age) select id,name,age from schema2.no_shar                                             | Insert     | 25      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2                |
      | 26       | update no_sharding_t1 set name='test_name' where id in (select id from schema2.no_shar)                                     | UPDATE no_sharding_t1 SET name = ? WHERE id IN (   SELECT id   FROM schema2.no_shar  )                                      | Update     | 26      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4                |
      | 27       | update no_sharding_t1 set age=age-1 where name != (select name from schema2.no_shar where name ='name1')                    | UPDATE no_sharding_t1 SET age = age - ? WHERE name != (   SELECT name   FROM schema2.no_shar   WHERE name = ?  )            | Update     | 27      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4                |
      | 28       | select n.id,s.name from no_sharding_t1 n join schema2.no_shar s on n.id=s.id                                                | select n.id,s.name from no_sharding_t1 n join schema2.no_shar s on n.id=s.id                                                | Select     | 28      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4                |
      | 29       | select * from no_sharding_t1 where age <> (select age from schema2.no_shar where id !=1)                                    | SELECT * FROM no_sharding_t1 WHERE age <> (  SELECT age  FROM schema2.no_shar  WHERE id != ? )                              | Select     | 29      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4                |
      | 30       | delete from schema2.no_shar where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp)) | delete from schema2.no_shar where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp)) | Delete     | 30      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2                |
      | 31       | insert into sharding_2_t1 (id) select id from schema2.sharding2                                                             | insert into sharding_2_t1 (id) select id from schema2.sharding2                                                             | Insert     | 31      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2                |
      | 32       | update sharding_2_t1 a,schema2.sharding2 b set a.age=b.age-1 where a.id=2 and b.id=2                                        | UPDATE sharding_2_t1 a, schema2.sharding2 b SET a.age = b.age - ? WHERE a.id = ?  AND b.id = ?                              | Update     | 32      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2                |
      | 33       | select n.id,s.name from sharding_2_t1 n join schema2.sharding2 s on n.id=s.id                                               | select n.id,s.name from sharding_2_t1 n join schema2.sharding2 s on n.id=s.id                                               | Select     | 33      | 3       | test1  | 172.100.9.8   | 8066          | 4      | 4                |
      | 34       | select * from sharding_2_t1 where age <> (select age from schema2.sharding2 where id !=1)                                   | SELECT * FROM sharding_2_t1 WHERE age <> (  SELECT age  FROM schema2.sharding2  WHERE id != ? )                             | Select     | 34      | 3       | test1  | 172.100.9.8   | 8066          | 3      | 4                |
      | 35       | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1      | DELETE schema1.sharding_2_t1 FROM sharding_2_t1, schema2.sharding2 WHERE sharding_2_t1.id = ?  AND schema2.sharding2.id = ? | Delete     | 35      | 3       | test1  | 172.100.9.8   | 8066          | 2      | 2                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 25      | 3       | test1  | 172.100.9.8   | 8066          | 25        | 1           | 2               |
      | 26      | 3       | test1  | 172.100.9.8   | 8066          | 26        | 1           | 4               |
      | 27      | 3       | test1  | 172.100.9.8   | 8066          | 27        | 1           | 4               |
      | 28      | 3       | test1  | 172.100.9.8   | 8066          | 28        | 1           | 4               |
      | 29      | 3       | test1  | 172.100.9.8   | 8066          | 29        | 1           | 4               |
      | 30      | 3       | test1  | 172.100.9.8   | 8066          | 30        | 1           | 2               |
      | 31      | 3       | test1  | 172.100.9.8   | 8066          | 31        | 1           | 2               |
      | 32      | 3       | test1  | 172.100.9.8   | 8066          | 32        | 1           | 2               |
      | 33      | 3       | test1  | 172.100.9.8   | 8066          | 33        | 1           | 4               |
      | 34      | 3       | test1  | 172.100.9.8   | 8066          | 34        | 1           | 4               |
      | 35      | 3       | test1  | 172.100.9.8   | 8066          | 35        | 1           | 2               |

     Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                                                                                                | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | delete from schema2.no_shar where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp)) | 3       | test1  | 1      | 2      | 2               |
      | DELETE schema1.sharding_2_t1 FROM sharding_2_t1, schema2.sharding2 WHERE sharding_2_t1.id = ?  AND schema2.sharding2.id = ? | 3       | test1  | 1      | 2      | 2               |
      | insert into no_sharding_t1(id,name,age) select id,name,age from schema2.no_shar                                             | 3       | test1  | 1      | 2      | 2               |
      | insert into sharding_2_t1 (id) select id from schema2.sharding2                                                             | 3       | test1  | 1      | 2      | 2               |
      | SELECT * FROM no_sharding_t1 WHERE age <> (  SELECT age  FROM schema2.no_shar  WHERE id != ? )                              | 3       | test1  | 1      | 4      | 4               |
      | SELECT * FROM sharding_2_t1 WHERE age <> (  SELECT age  FROM schema2.sharding2  WHERE id != ? )                             | 3       | test1  | 1      | 3      | 4               |
      | select n.id,s.name from no_sharding_t1 n join schema2.no_shar s on n.id=s.id                                                | 3       | test1  | 1      | 4      | 4               |
      | select n.id,s.name from sharding_2_t1 n join schema2.sharding2 s on n.id=s.id                                               | 3       | test1  | 1      | 4      | 4               |
      | UPDATE no_sharding_t1 SET age = age - ? WHERE name != (   SELECT name   FROM schema2.no_shar   WHERE name = ?  )            | 3       | test1  | 1      | 4      | 4               |
      | UPDATE no_sharding_t1 SET name = ? WHERE id IN (   SELECT id   FROM schema2.no_shar  )                                      | 3       | test1  | 1      | 4      | 4               |
      | UPDATE sharding_2_t1 a, schema2.sharding2 b SET a.age = b.age - ? WHERE a.id = ?  AND b.id = ?                              | 3       | test1  | 1      | 2      | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                                 | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | delete from schema2.no_shar where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp)) | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 30        | 2                |
      | DELETE schema1.sharding_2_t1 FROM sharding_2_t1, schema2.sharding2 WHERE sharding_2_t1.id = ?  AND schema2.sharding2.id = ? | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 35        | 2                |
      | insert into no_sharding_t1(id,name,age) select id,name,age from schema2.no_shar                                             | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 25        | 2                |
      | insert into sharding_2_t1 (id) select id from schema2.sharding2                                                             | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 31        | 2                |
      | SELECT * FROM no_sharding_t1 WHERE age <> (  SELECT age  FROM schema2.no_shar  WHERE id != ? )                              | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 29        | 4                |
      | SELECT * FROM sharding_2_t1 WHERE age <> (  SELECT age  FROM schema2.sharding2  WHERE id != ? )                             | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 34        | 4                |
      | select n.id,s.name from no_sharding_t1 n join schema2.no_shar s on n.id=s.id                                                | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 28        | 4                |
      | select n.id,s.name from sharding_2_t1 n join schema2.sharding2 s on n.id=s.id                                               | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 33        | 4                |
      | UPDATE no_sharding_t1 SET age = age - ? WHERE name != (   SELECT name   FROM schema2.no_shar   WHERE name = ?  )            | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 27        | 4                |
      | UPDATE no_sharding_t1 SET name = ? WHERE id IN (   SELECT id   FROM schema2.no_shar  )                                      | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 26        | 4                |
      | UPDATE sharding_2_t1 a, schema2.sharding2 b SET a.age = b.age - ? WHERE a.id = ?  AND b.id = ?                              | 1      | test1  | 3       | 1          | 172.100.9.8   | 8066          | 32        | 2                |

      # rwSplitUser sql_id:36-41
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values (1,'1',1),(2, '2',2)        | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table1                          | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table1(id int,name varchar(20),age int) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table1 values (1,'1',1),(2, '2',2)       | success | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user      | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | length{(0)}  | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                 | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table(id,name,age) select id,name,age from test_table1                                             | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | update test_table set name='test_name' where id in (select id from test_table1 )                                    | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | update test_table a,test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2                                         | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select n.id,s.name from test_table n join test_table1 s on n.id=s.id                                                | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | delete test_table from test_table,test_table1 where test_table.id=1 and test_table1.id =1                           | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | delete from test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) | success | db1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                                                          | sql_digest-2                                                                                                        | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 42       | insert into test_table(id,name,age) select id,name,age from test_table1                                             | insert into test_table(id,name,age) select id,name,age from test_table1                                             | Insert     | 42      | 4       | rwS1   | 172.100.9.8   | 8066          | 2      | 2                |
      | 43       | update test_table set name='test_name' where id in (select id from test_table1 )                                    | UPDATE test_table SET name = ? WHERE id IN (   SELECT id   FROM test_table1  )                                      | Update     | 43      | 4       | rwS1   | 172.100.9.8   | 8066          | 4      | 4                |
      | 44       | update test_table a,test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2                                         | UPDATE test_table a, test_table1 b SET a.age = b.age - ? WHERE a.id = ?  AND b.id = ?                               | Update     | 44      | 4       | rwS1   | 172.100.9.8   | 8066          | 2      | 2                |
      | 45       | select n.id,s.name from test_table n join test_table1 s on n.id=s.id                                                | select n.id,s.name from test_table n join test_table1 s on n.id=s.id                                                | Select     | 45      | 4       | rwS1   | 172.100.9.8   | 8066          | 4      | 4                |
      | 46       | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | SELECT * FROM test_table WHERE age <> (  SELECT age  FROM test_table1  WHERE id != ? )                              | Select     | 46      | 4       | rwS1   | 172.100.9.8   | 8066          | 4      | 4                |
      | 47       | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | SELECT * FROM test_table WHERE age <> (  SELECT age  FROM test_table1  WHERE id != ? )                              | Select     | 47      | 4       | rwS1   | 172.100.9.8   | 8066          | 4      | 4                |
      | 48       | delete test_table from test_table,test_table1 where test_table.id=1 and test_table1.id =1                           | DELETE test_table FROM test_table, test_table1 WHERE test_table.id = ?  AND test_table1.id = ?                      | Delete     | 48      | 4       | rwS1   | 172.100.9.8   | 8066          | 2      | 2                |
      | 49       | delete from test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) | delete from test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) | Delete     | 49      | 4       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 42      | 4       | rwS1   | 172.100.9.8   | 8066          | 42        | 1           | 2               |
      | 43      | 4       | rwS1   | 172.100.9.8   | 8066          | 43        | 1           | 4               |
      | 44      | 4       | rwS1   | 172.100.9.8   | 8066          | 44        | 1           | 2               |
      | 45      | 4       | rwS1   | 172.100.9.8   | 8066          | 45        | 1           | 4               |
      | 46      | 4       | rwS1   | 172.100.9.8   | 8066          | 46        | 1           | 4               |
      | 47      | 4       | rwS1   | 172.100.9.8   | 8066          | 47        | 1           | 4               |
      | 48      | 4       | rwS1   | 172.100.9.8   | 8066          | 48        | 1           | 2               |
      | 49      | 4       | rwS1   | 172.100.9.8   | 8066          | 49        | 1           | 1               |

   Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                                                                                        | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | delete from test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) | 4       | rwS1   | 1      | 1      | 1               |
      | DELETE test_table FROM test_table, test_table1 WHERE test_table.id = ?  AND test_table1.id = ?                      | 4       | rwS1   | 1      | 2      | 2               |
      | insert into test_table(id,name,age) select id,name,age from test_table1                                             | 4       | rwS1   | 1      | 2      | 2               |
      | SELECT * FROM test_table WHERE age <> (  SELECT age  FROM test_table1  WHERE id != ? )                              | 4       | rwS1   | 2      | 8      | 8               |
      | select n.id,s.name from test_table n join test_table1 s on n.id=s.id                                                | 4       | rwS1   | 1      | 4      | 4               |
      | UPDATE test_table a, test_table1 b SET a.age = b.age - ? WHERE a.id = ?  AND b.id = ?                               | 4       | rwS1   | 1      | 2      | 2               |
      | UPDATE test_table SET name = ? WHERE id IN (   SELECT id   FROM test_table1  )                                      | 4       | rwS1   | 1      | 4      | 4               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                         | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | delete from test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) | 1      | rwS1   | 4       | 1          | 172.100.9.8   | 8066          | 49        | 1                |
      | DELETE test_table FROM test_table, test_table1 WHERE test_table.id = ?  AND test_table1.id = ?                      | 1      | rwS1   | 4       | 1          | 172.100.9.8   | 8066          | 48        | 2                |
      | insert into test_table(id,name,age) select id,name,age from test_table1                                             | 1      | rwS1   | 4       | 1          | 172.100.9.8   | 8066          | 42        | 2                |
      | SELECT * FROM test_table WHERE age <> (  SELECT age  FROM test_table1  WHERE id != ? )                              | 2      | rwS1   | 4       | 2          | 172.100.9.8   | 8066          | 46,47     | 8                |
      | select n.id,s.name from test_table n join test_table1 s on n.id=s.id                                                | 1      | rwS1   | 4       | 1          | 172.100.9.8   | 8066          | 45        | 4                |
      | UPDATE test_table a, test_table1 b SET a.age = b.age - ? WHERE a.id = ?  AND b.id = ?                               | 1      | rwS1   | 4       | 1          | 172.100.9.8   | 8066          | 44        | 2                |
      | UPDATE test_table SET name = ? WHERE id IN (   SELECT id   FROM test_table1  )                                      | 1      | rwS1   | 4       | 1          | 172.100.9.8   | 8066          | 43        | 4                |


    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
    # add case for mysql 5.7 shrdinguser
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                      | expect  | db      |
      | conn_1 | False   | replace into sharding_2_t1(id) select a.id from schema2.sharding2 a                      | success | schema1 |
      | conn_1 | False   | drop view if exists test_view                                                            | success | schema1 |
      | conn_1 | False   | create view test_view(id,name) AS select * from test union select * from schema2.global2 | success | schema1 |
      | conn_1 | False   | select * from test union select * from schema2.global2                                   | success | schema1 |
      | conn_1 | False   | drop view test_view                                                                      | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                               | sql_digest-2                                                                                    | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 50       | replace into sharding_2_t1(id) select a.id from schema2.sharding2 a                      | replace into sharding_2_t1(id) select a.id from schema2.sharding2 a                             | Other      | 50      | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 51       | drop view if exists test_view                                                            | DROP VIEW IF EXISTS test_view                                                                   | Other      | 51      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 52       | create view test_view(id,name) AS select * from test union select * from schema2.global2 | CREATE VIEW test_view (  id,   name ) AS SELECT * FROM test UNION SELECT * FROM schema2.global2 | Other      | 52      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 53       | select * from test union select * from schema2.global2                                   | select * from test union select * from schema2.global2                                          | Select     | 53      | 2       | test   | 172.100.9.8   | 8066          | 8      | 8                |
      | 54       | drop view test_view                                                                      | DROP VIEW test_view                                                                             | Other      | 54      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 50      | 2       | test   | 172.100.9.8   | 8066          | 50        | 1           | 2               |
      | 51      | 2       | test   | 172.100.9.8   | 8066          | 51        | 1           | 0               |
      | 52      | 2       | test   | 172.100.9.8   | 8066          | 52        | 1           | 0               |
      | 53      | 2       | test   | 172.100.9.8   | 8066          | 53        | 1           | 8               |
      | 54      | 2       | test   | 172.100.9.8   | 8066          | 54        | 1           | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                                                                    | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | CREATE VIEW test_view (  id,   name ) AS SELECT * FROM test UNION SELECT * FROM schema2.global2 | 2       | test   | 1      | 0      | 0               |
      | DROP VIEW IF EXISTS test_view                                                                   | 2       | test   | 1      | 0      | 0               |
      | DROP VIEW test_view                                                                             | 2       | test   | 1      | 0      | 0               |
      | replace into sharding_2_t1(id) select a.id from schema2.sharding2 a                             | 2       | test   | 1      | 2      | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                     | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | CREATE VIEW test_view (  id,   name ) AS SELECT * FROM test UNION SELECT * FROM schema2.global2 | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 52        | 0                |
      | DROP VIEW IF EXISTS test_view                                                                   | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 51        | 0                |
      | DROP VIEW test_view                                                                             | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 54        | 0                |
      | replace into sharding_2_t1(id) select a.id from schema2.sharding2 a                             | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 50        | 2                |
      | select * from test union select * from schema2.global2                                          | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 53        | 8                |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists test                                                            | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                                   | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.global2                                                 | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sharding2                                               | success | schema1 |
      | conn_1 | true    | drop table if exists schema2.sing1                                                   | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                               | expect  | db      |
      | test1 | 111111 | conn_2 | False   | drop table if exists no_sharding_t1                               | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists schema2.no_shar                              | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists sharding_2_t1                                | success | schema1 |
      | test1 | 111111 | conn_2 | true    | drop table if exists schema2.sharding2                            | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rwS1 | 111111 | conn_3 | true    | drop table if exists test_table                           | success | db1 |



  Scenario: test samplingRate=100 and sharding user hint sql  #6
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | True     | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
    Then execute admin cmd "reload @@samplingRate=100"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                       | expect  | db      |
      | conn_1 | False    | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                                    | success | schema1 |
      | conn_1 | False    | /*!dble:shardingNode=dn2*/ insert into sharding_4_t1 values(666, 'name666')               | success | schema1 |
      | conn_1 | False    | /*!dble:shardingNode=dn3*/ update sharding_4_t1 set name = 'dn1' where id=666             | success | schema1 |
      | conn_1 | True     | /*!dble:shardingNode=dn4*/ delete from sharding_4_t1 where id=666                         | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                    | sql_digest-2                                   | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                        | SELECT * FROM sharding_4_t1                    | Select     | 1       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 2        | /*!dble:shardingNode=dn2*/ insert into sharding_4_t1 values(666, 'name666')   | INSERT INTO sharding_4_t1 VALUES (?, ?)        | Insert     | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 3        | /*!dble:shardingNode=dn3*/ update sharding_4_t1 set name = 'dn1' where id=666 | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | Update     | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 4        | /*!dble:shardingNode=dn4*/ delete from sharding_4_t1 where id=666             | DELETE FROM sharding_4_t1 WHERE id = ?         | Delete     | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1         | 1           | 1               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 2         | 1           | 1               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 3         | 1           | 0               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 4         | 1           | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                   | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | DELETE FROM sharding_4_t1 WHERE id = ?         | 2       | test   | 1      | 0      | 0               |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)        | 2       | test   | 1      | 1      | 1               |
      | SELECT * FROM sharding_4_t1                    | 2       | test   | 1      | 1      | 1               |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | 2       | test   | 1      | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                    | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | DELETE FROM sharding_4_t1 WHERE id = ?         | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 4         | 0                |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)        | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 2         | 1                |
      | SELECT * FROM sharding_4_t1                    | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 1         | 1                |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 3         | 0                |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                            | expect  | db      |
      | conn_1 | False    | SELECT * FROM sharding_4_t1                                    | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(666, 'name666')               | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name = 'dn1' where id=666             | success | schema1 |
      | conn_1 | True     | delete from sharding_4_t1 where id=666                         | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                    | sql_digest-2                                   | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                        | SELECT * FROM sharding_4_t1                    | Select     | 1       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 2        | /*!dble:shardingNode=dn2*/ insert into sharding_4_t1 values(666, 'name666')   | INSERT INTO sharding_4_t1 VALUES (?, ?)        | Insert     | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 3        | /*!dble:shardingNode=dn3*/ update sharding_4_t1 set name = 'dn1' where id=666 | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | Update     | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 4        | /*!dble:shardingNode=dn4*/ delete from sharding_4_t1 where id=666             | DELETE FROM sharding_4_t1 WHERE id = ?         | Delete     | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 5        | SELECT * FROM sharding_4_t1                                                   | SELECT * FROM sharding_4_t1                    | Select     | 5       | 2       | test   | 172.100.9.8   | 8066          | 5      | 5                |
      | 6        | insert into sharding_4_t1 values(666, 'name666')                              | INSERT INTO sharding_4_t1 VALUES (?, ?)        | Insert     | 6       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 7        | update sharding_4_t1 set name = 'dn1' where id=666                            | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | Update     | 7       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 8        | delete from sharding_4_t1 where id=666                                        | DELETE FROM sharding_4_t1 WHERE id = ?         | Delete     | 8       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_count-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1         | 1           | 1               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 2         | 1           | 1               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 3         | 1           | 0               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 4         | 1           | 0               |
      | 5       | 2       | test   | 172.100.9.8   | 8066          | 5         | 1           | 5               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 6         | 1           | 1               |
      | 7       | 2       | test   | 172.100.9.8   | 8066          | 7         | 1           | 1               |
      | 8       | 2       | test   | 172.100.9.8   | 8066          | 8         | 1           | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                   | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | DELETE FROM sharding_4_t1 WHERE id = ?         | 2       | test   | 2      | 1      | 1               |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)        | 2       | test   | 2      | 2      | 2               |
      | SELECT * FROM sharding_4_t1                    | 2       | test   | 2      | 6      | 6               |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | 2       | test   | 2      | 1      | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                    | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | DELETE FROM sharding_4_t1 WHERE id = ?         | 2      | test   | 2       | 2          | 172.100.9.8   | 8066          | 4,8       | 1                |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)        | 2      | test   | 2       | 2          | 172.100.9.8   | 8066          | 2,6       | 2                |
      | SELECT * FROM sharding_4_t1                    | 2      | test   | 2       | 2          | 172.100.9.8   | 8066          | 1,5       | 6                |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | 2      | test   | 2       | 2          | 172.100.9.8   | 8066          | 3,7       | 1                |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | true     | drop table if exists sharding_4_t1                                              | success | schema1 |



  Scenario: test samplingRate=100 and transaction sql  ---- shardinguser  #7
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_1 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_1 | true     | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |

    Then execute admin cmd "reload @@samplingRate=100"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

   #case  begin ... commit
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |
      | conn_1 | False    | commit                                                                          | success | schema1 |

      | conn_1 | False    | start transaction                                                               | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn2' where id=1                                  | success | schema1 |
      | conn_1 | False    | delete from sharding_4_t1 where id=5                                            | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn1' where id=100                                | success | schema1 |
      | conn_1 | False    | commit                                                                          | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                       | sql_digest-2                                   | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | begin                                            | begin                                          | Begin      | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 2        | select * from sharding_4_t1                      | select * from sharding_4_t1                    | Select     | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 3        | insert into sharding_4_t1 values(5,'name5')      | INSERT INTO sharding_4_t1 VALUES (?, ?)        | Insert     | 1       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 4        | commit                                           | commit                                         | Commit     | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 5        | start transaction                                | start transaction                              | Other      | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 6        | update sharding_4_t1 set name='dn2' where id=1   | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | Update     | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 7        | delete from sharding_4_t1 where id=5             | DELETE FROM sharding_4_t1 WHERE id = ?         | Delete     | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 8        | update sharding_4_t1 set name='dn1' where id=100 | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | Update     | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 9        | commit                                           | commit                                         | Commit     | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6  | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1,2,3,4   | 4           | 5               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 5,6,7,8,9 | 5           | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                   | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | begin                                          | 2       | test   | 1      | 0      | 0               |
      | commit                                         | 2       | test   | 2      | 0      | 0               |
      | DELETE FROM sharding_4_t1 WHERE id = ?         | 2       | test   | 1      | 1      | 1               |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)        | 2       | test   | 1      | 1      | 1               |
      | select * from sharding_4_t1                    | 2       | test   | 1      | 4      | 4               |
      | start transaction                              | 2       | test   | 1      | 0      | 0               |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | 2       | test   | 2      | 1      | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                                                                   | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | begin,select * from sharding_4_t1,INSERT INTO sharding_4_t1 VALUES (?, ?),commit                                                                              | 1      | test   | 2       | 4          | 172.100.9.8   | 8066          | 1,2,3,4   | 5                |
      | start transaction,UPDATE sharding_4_t1 SET name = ? WHERE id = ?,DELETE FROM sharding_4_t1 WHERE id = ?,UPDATE sharding_4_t1 SET name = ? WHERE id = ?,commit | 1      | test   | 2       | 5          | 172.100.9.8   | 8066          | 5,6,7,8,9 | 2                |


    #case  begin ... rollback
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_2 | False    | begin                                                                           | success | schema1 |
      | conn_2 | False    | insert into sharding_4_t1 values(5,'name5'),(6,'name6')                         | success | schema1 |
      | conn_2 | False    | delete from sharding_4_t1 where id=6                                            | success | schema1 |
      | conn_2 | False    | rollback                                                                        | success | schema1 |

      | conn_2 | False    | start transaction                                                               | success | schema1 |
      | conn_2 | False    | select * from sharding_4_t1 where id=2                                          | success | schema1 |
      | conn_2 | False    | update sharding_4_t1 set name='dn4' where id=3                                  | success | schema1 |
      | conn_2 | False    | update sharding_4_t1 set name='dn1' where id=100                                | success | schema1 |
      | conn_2 | False    | rollback                                                                        | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                              | sql_digest-2                                   | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 10       | begin                                                   | begin                                          | Begin      | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 11       | insert into sharding_4_t1 values(5,'name5'),(6,'name6') | INSERT INTO sharding_4_t1 VALUES (?, ?)        | Insert     | 3       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 12       | delete from sharding_4_t1 where id=6                    | DELETE FROM sharding_4_t1 WHERE id = ?         | Delete     | 3       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 13       | rollback                                                | rollback                                       | Rollback   | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 14       | start transaction                                       | start transaction                              | Other      | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 15       | select * from sharding_4_t1 where id=2                  | SELECT * FROM sharding_4_t1 WHERE id = ?       | Select     | 4       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 16       | update sharding_4_t1 set name='dn4' where id=3          | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | Update     | 4       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 17       | update sharding_4_t1 set name='dn1' where id=100        | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | Update     | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 18       | rollback                                                | rollback                                       | Rollback   | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5      | sql_exec-6  | examined_rows-9 |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 10,11,12,13    | 4           | 3               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 14,15,16,17,18 | 5           | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                   | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | begin                                          | 2       | test   | 2      | 0      | 0               |
      | commit                                         | 2       | test   | 2      | 0      | 0               |
      | DELETE FROM sharding_4_t1 WHERE id = ?         | 2       | test   | 2      | 2      | 2               |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)        | 2       | test   | 2      | 3      | 3               |
      | rollback                                       | 2       | test   | 2      | 0      | 0               |
      | select * from sharding_4_t1                    | 2       | test   | 1      | 4      | 4               |
      | SELECT * FROM sharding_4_t1 WHERE id = ?       | 2       | test   | 1      | 1      | 1               |
      | start transaction                              | 2       | test   | 2      | 0      | 0               |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | 2       | test   | 4      | 2      | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                                                                       | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7      | examined_rows-10 |
      | begin,INSERT INTO sharding_4_t1 VALUES (?, ?),DELETE FROM sharding_4_t1 WHERE id = ?,rollback                                                                     | 1      | test   | 2       | 4          | 172.100.9.8   | 8066          | 10,11,12,13    | 3                |
      | begin,select * from sharding_4_t1,INSERT INTO sharding_4_t1 VALUES (?, ?),commit                                                                                  | 1      | test   | 2       | 4          | 172.100.9.8   | 8066          | 1,2,3,4        | 5                |
      | start transaction,SELECT * FROM sharding_4_t1 WHERE id = ?,UPDATE sharding_4_t1 SET name = ? WHERE id = ?,UPDATE sharding_4_t1 SET name = ? WHERE id = ?,rollback | 1      | test   | 2       | 5          | 172.100.9.8   | 8066          | 14,15,16,17,18 | 2                |
      | start transaction,UPDATE sharding_4_t1 SET name = ? WHERE id = ?,DELETE FROM sharding_4_t1 WHERE id = ?,UPDATE sharding_4_t1 SET name = ? WHERE id = ?,commit     | 1      | test   | 2       | 5          | 172.100.9.8   | 8066          | 5,6,7,8,9      | 2                |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user      | length{(0)}  | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user   | length{(0)}  | dble_information |

    #case  begin ... start transaction
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_2 | False    | start transaction                                                               | success | schema1 |
      | conn_2 | False    | delete from sharding_2_t1                                                       | success | schema1 |

      | conn_2 | False    | begin                                                                           | success | schema1 |
      | conn_2 | true     | delete from sharding_4_t1                                                       | success | schema1 |
    Given sleep "2" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                | sql_digest-2              | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 19       | start transaction         | start transaction         | Other      | 5       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 20       | delete from sharding_2_t1 | delete from sharding_2_t1 | Delete     | 5       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 21       | begin                     | begin                     | Begin      | 5       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 22       | delete from sharding_4_t1 | delete from sharding_4_t1 | Delete     | 6       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 23       | exit                      |                           | Other      | 6       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6  | examined_rows-9 |
      | 5       | 2       | test   | 172.100.9.8   | 8066          | 19,20,21  | 3           | 2               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 22,23     | 2           | 4               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0              | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      |                           | 2       | test   | 1      | 0      | 0               |
      | begin                     | 2       | test   | 1      | 0      | 0               |
      | delete from sharding_2_t1 | 2       | test   | 1      | 2      | 2               |
      | delete from sharding_4_t1 | 2       | test   | 1      | 4      | 4               |
      | start transaction         | 2       | test   | 1      | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                       | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | delete from sharding_4_t1,                        | 1      | test   | 2       | 2          | 172.100.9.8   | 8066          | 22,23     | 4                |
      | start transaction,delete from sharding_2_t1,begin | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 19,20,21  | 2                |


    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_3 | False    | set autocommit=0                                                                | success | schema1 |
      | conn_3 | False    | update sharding_4_t1 set name='test_name'                                       | success | schema1 |
      | conn_3 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_3 | False    | commit                                                                          | success | schema1 |

      | conn_3 | False    | delete from sharding_4_t1 where id in (3, 4)                                    | success | schema1 |
      | conn_3 | False    | insert into sharding_4_t1 values(3,'name3'),(4,'name4')                         | success | schema1 |
      | conn_3 | False    | rollback                                                                        | success | schema1 |

      | conn_3 | True     | delete from sharding_4_t1                                                       | success | schema1 |
    Given sleep "2" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                              | sql_digest-2                              | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | set autocommit=0                                        | SET autocommit = ?                        | Set        | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 2        | update sharding_4_t1 set name='test_name'               | UPDATE sharding_4_t1 SET name = ?         | Update     | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 3        | select * from sharding_4_t1                             | select * from sharding_4_t1               | Select     | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 4        | commit                                                  | commit                                    | Commit     | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 5        | delete from sharding_4_t1 where id in (3, 4)            | DELETE FROM sharding_4_t1 WHERE id IN (?) | Delete     | 2       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 6        | insert into sharding_4_t1 values(3,'name3'),(4,'name4') | INSERT INTO sharding_4_t1 VALUES (?, ?)   | Insert     | 2       | 2       | test   | 172.100.9.8   | 8066          | 2      | 2                |
      | 7        | rollback                                                | rollback                                  | Rollback   | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 8        | delete from sharding_4_t1                               | delete from sharding_4_t1                 | Delete     | 3       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 9        | exit                                                    |                                           | Other      | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6  | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1,2,3,4   | 4           | 8               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 5,6,7     | 3           | 4               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 8,9       | 2           | 4               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                              | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      |                                           | 2       | test   | 1      | 0      | 0               |
      | commit                                    | 2       | test   | 1      | 0      | 0               |
      | delete from sharding_4_t1                 | 2       | test   | 1      | 4      | 4               |
      | DELETE FROM sharding_4_t1 WHERE id IN (?) | 2       | test   | 1      | 2      | 2               |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)   | 2       | test   | 1      | 2      | 2               |
      | rollback                                  | 2       | test   | 1      | 0      | 0               |
      | select * from sharding_4_t1               | 2       | test   | 1      | 4      | 4               |
      | SET autocommit = ?                        | 2       | test   | 1      | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | DELETE FROM sharding_4_t1 WHERE id IN (?),INSERT INTO sharding_4_t1 VALUES (?, ?),rollback | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 5,6,7     | 4                |
      | delete from sharding_4_t1,                                                                 | 1      | test   | 2       | 2          | 172.100.9.8   | 8066          | 8,9       | 4                |
      | SET autocommit = ?,UPDATE sharding_4_t1 SET name = ?,select * from sharding_4_t1,commit    | 1      | test   | 2       | 4          | 172.100.9.8   | 8066          | 1,2,3,4   | 8                |


    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                             | expect  | db      |
      | conn_11 | False    | begin                                                                           | success | schema1 |
      | conn_11 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_11 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                             | expect  | db      |
      | conn_12 | False    | start transaction                                                               | success | schema1 |
      | conn_12 | False    | select * from sharding_2_t1                                                     | success | schema1 |
      | conn_12 | False    | insert into sharding_2_t1 values(5,'name5')                                     | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn     | toClose  | sql                                            | expect  | db      |
      | conn_11  | false    | commit                                         | success | schema1 |
      | conn_11  | true     | drop table if exists sharding_4_t1             | success | schema1 |
      | conn_12  | false    | commit                                         | success | schema1 |
      | conn_12  | true     | drop table if exists sharding_2_t1             | success | schema1 |



  Scenario: test samplingRate=100 and transaction sql  ---- rwSplitUser  #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,'1',1),(2, '2',2)        | success | db1 |
      | rwS1 | 111111 | conn_4 | False   | drop table if exists test_table1                          | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | create table test_table1(id int,name varchar(20),age int) | success | db2 |
      | rwS1 | 111111 | conn_4 | true    | insert into test_table1 values (1,'1',1),(2, '2',2)       | success | db2 |

    Then execute admin cmd "reload @@samplingRate=100"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

    #case  begin ... commit
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | begin                                            | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table                         | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values(5,'name5',5)       | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | commit                                           | success | db1 |

      | rwS1 | 111111 | conn_4 | False   | start transaction                                  | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age =33 where id=1          | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | delete from test_table1 where id=5                 | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age =44 where id=100        | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | commit                                             | success | db2 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                  | sql_digest-2                                | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | begin                                       | begin                                       | Begin      | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 2        | select * from test_table                    | select * from test_table                    | Select     | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 2      | 2                |
      | 3        | insert into test_table values(5,'name5',5)  | INSERT INTO test_table VALUES (?, ?, ?)     | Insert     | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |
      | 4        | commit                                      | commit                                      | Commit     | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 5        | start transaction                           | start transaction                           | Other      | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 6        | update test_table1 set age =33 where id=1   | UPDATE test_table1 SET age = ? WHERE id = ? | Update     | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |
      | 7        | delete from test_table1 where id=5          | DELETE FROM test_table1 WHERE id = ?        | Delete     | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 8        | update test_table1 set age =44 where id=100 | UPDATE test_table1 SET age = ? WHERE id = ? | Update     | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 9        | commit                                      | commit                                      | Commit     | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6  | examined_rows-9 |
      | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 1,2,3,4   | 4           | 3               |
      | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 5,6,7,8,9 | 5           | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | begin                                       | 1       | rwS1   | 1      | 0      | 0               |
      | commit                                      | 1       | rwS1   | 2      | 0      | 0               |
      | DELETE FROM test_table1 WHERE id = ?        | 1       | rwS1   | 1      | 0      | 0               |
      | INSERT INTO test_table VALUES (?, ?, ?)     | 1       | rwS1   | 1      | 1      | 1               |
      | select * from test_table                    | 1       | rwS1   | 1      | 2      | 2               |
      | start transaction                           | 1       | rwS1   | 1      | 0      | 0               |
      | UPDATE test_table1 SET age = ? WHERE id = ? | 1       | rwS1   | 2      | 1      | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                                                           | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | begin,select * from test_table,INSERT INTO test_table VALUES (?, ?, ?),commit                                                                         | 1      | rwS1   | 1       | 4          | 172.100.9.8   | 8066          | 1,2,3,4   | 3                |
      | start transaction,UPDATE test_table1 SET age = ? WHERE id = ?,DELETE FROM test_table1 WHERE id = ?,UPDATE test_table1 SET age = ? WHERE id = ?,commit | 1      | rwS1   | 1       | 5          | 172.100.9.8   | 8066          | 5,6,7,8,9 | 1                |


    #case  begin ... rollback
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                      | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | begin                                                    | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values(5,'name5',5),(6,'name6',6) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | delete from test_table where id=6                        | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | rollback                                                 | success | db1 |

      | rwS1 | 111111 | conn_4 | False   | start transaction                                        | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | select * from test_table1 where id=2                     | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age=age-1 where id=1              | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age=age*3 where id=2              | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | rollback                                                 | success | db2 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                               | sql_digest-2                                      | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 10       | begin                                                    | begin                                             | Begin      | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 11       | insert into test_table values(5,'name5',5),(6,'name6',6) | INSERT INTO test_table VALUES (?, ?, ?)           | Insert     | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 2      | 2                |
      | 12       | delete from test_table where id=6                        | DELETE FROM test_table WHERE id = ?               | Delete     | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |
      | 13       | rollback                                                 | rollback                                          | Rollback   | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 14       | start transaction                                        | start transaction                                 | Other      | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 15       | select * from test_table1 where id=2                     | SELECT * FROM test_table1 WHERE id = ?            | Select     | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |
      | 16       | update test_table1 set age=age-1 where id=1              | UPDATE test_table1 SET age = age - ? WHERE id = ? | Update     | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |
      | 17       | update test_table1 set age=age*3 where id=2              | UPDATE test_table1 SET age = age * ? WHERE id = ? | Update     | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |
      | 18       | rollback                                                 | rollback                                          | Rollback   | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5      | sql_exec-6 | examined_rows-9 |
      | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 1,2,3,4        | 4          | 3               |
      | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 5,6,7,8,9      | 5          | 1               |
      | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 10,11,12,13    | 4          | 3               |
      | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 14,15,16,17,18 | 5          | 3               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                      | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | begin                                             | 1       | rwS1   | 2      | 0      | 0               |
      | commit                                            | 1       | rwS1   | 2      | 0      | 0               |
      | DELETE FROM test_table WHERE id = ?               | 1       | rwS1   | 1      | 1      | 1               |
      | DELETE FROM test_table1 WHERE id = ?              | 1       | rwS1   | 1      | 0      | 0               |
      | INSERT INTO test_table VALUES (?, ?, ?)           | 1       | rwS1   | 2      | 3      | 3               |
      | rollback                                          | 1       | rwS1   | 2      | 0      | 0               |
      | select * from test_table                          | 1       | rwS1   | 1      | 2      | 2               |
      | SELECT * FROM test_table1 WHERE id = ?            | 1       | rwS1   | 1      | 1      | 1               |
      | start transaction                                 | 1       | rwS1   | 2      | 0      | 0               |
      | UPDATE test_table1 SET age = ? WHERE id = ?       | 1       | rwS1   | 2      | 1      | 1               |
      | UPDATE test_table1 SET age = age * ? WHERE id = ? | 1       | rwS1   | 1      | 1      | 1               |
      | UPDATE test_table1 SET age = age - ? WHERE id = ? | 1       | rwS1   | 1      | 1      | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                                                                           | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7      | examined_rows-10 |
      | begin,INSERT INTO test_table VALUES (?, ?, ?),DELETE FROM test_table WHERE id = ?,rollback                                                                            | 1      | rwS1   | 1       | 4          | 172.100.9.8   | 8066          | 10,11,12,13    | 3                |
      | begin,select * from test_table,INSERT INTO test_table VALUES (?, ?, ?),commit                                                                                         | 1      | rwS1   | 1       | 4          | 172.100.9.8   | 8066          | 1,2,3,4        | 3                |
      | start transaction,SELECT * FROM test_table1 WHERE id = ?,UPDATE test_table1 SET age = age - ? WHERE id = ?,UPDATE test_table1 SET age = age * ? WHERE id = ?,rollback | 1      | rwS1   | 1       | 5          | 172.100.9.8   | 8066          | 14,15,16,17,18 | 3                |
      | start transaction,UPDATE test_table1 SET age = ? WHERE id = ?,DELETE FROM test_table1 WHERE id = ?,UPDATE test_table1 SET age = ? WHERE id = ?,commit                 | 1      | rwS1   | 1       | 5          | 172.100.9.8   | 8066          | 5,6,7,8,9      | 1                |


    #case  begin ... start transaction
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                          | expect  | db  |
      | rwS1 | 111111 | conn_31 | False   | start transaction            | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | delete from test_table       | success | db1 |

      | rwS1 | 111111 | conn_31 | False   | begin                        | success | db1 |
      | rwS1 | 111111 | conn_31 | true    | delete from db2.test_table1  | success | db1 |
    Given sleep "2" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                  | sql_digest-2                | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 19       | start transaction           | start transaction           | Other      | 5       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 20       | delete from test_table      | delete from test_table      | Delete     | 5       | 1       | rwS1   | 172.100.9.8   | 8066          | 3      | 3                |
      | 21       | begin                       | begin                       | Begin      | 5       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 22       | delete from db2.test_table1 | delete from db2.test_table1 | Delete     | 6       | 1       | rwS1   | 172.100.9.8   | 8066          | 2      | 2                |
      | 23       | exit                        |                             | Other      | 6       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5      | sql_exec-6 | examined_rows-9 |
      | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 1,2,3,4        | 4          | 3               |
      | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 5,6,7,8,9      | 5          | 1               |
      | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 10,11,12,13    | 4          | 3               |
      | 4       | 1       | rwS1   | 172.100.9.8   | 8066          | 14,15,16,17,18 | 5          | 3               |
      | 5       | 1       | rwS1   | 172.100.9.8   | 8066          | 19,20,21       | 3          | 3               |
      | 6       | 1       | rwS1   | 172.100.9.8   | 8066          | 22,23          | 2          | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                      | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      |                                                   | 1       | rwS1   | 1      | 0      | 0               |
      | begin                                             | 1       | rwS1   | 3      | 0      | 0               |
      | commit                                            | 1       | rwS1   | 2      | 0      | 0               |
      | delete from db2.test_table1                       | 1       | rwS1   | 1      | 2      | 2               |
      | delete from test_table                            | 1       | rwS1   | 1      | 3      | 3               |
      | DELETE FROM test_table WHERE id = ?               | 1       | rwS1   | 1      | 1      | 1               |
      | DELETE FROM test_table1 WHERE id = ?              | 1       | rwS1   | 1      | 0      | 0               |
      | INSERT INTO test_table VALUES (?, ?, ?)           | 1       | rwS1   | 2      | 3      | 3               |
      | rollback                                          | 1       | rwS1   | 2      | 0      | 0               |
      | select * from test_table                          | 1       | rwS1   | 1      | 2      | 2               |
      | SELECT * FROM test_table1 WHERE id = ?            | 1       | rwS1   | 1      | 1      | 1               |
      | start transaction                                 | 1       | rwS1   | 3      | 0      | 0               |
      | UPDATE test_table1 SET age = ? WHERE id = ?       | 1       | rwS1   | 2      | 1      | 1               |
      | UPDATE test_table1 SET age = age * ? WHERE id = ? | 1       | rwS1   | 1      | 1      | 1               |
      | UPDATE test_table1 SET age = age - ? WHERE id = ? | 1       | rwS1   | 1      | 1      | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                                                                           | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7      | examined_rows-10 |
      | begin,INSERT INTO test_table VALUES (?, ?, ?),DELETE FROM test_table WHERE id = ?,rollback                                                                            | 1      | rwS1   | 1       | 4          | 172.100.9.8   | 8066          | 10,11,12,13    | 3                |
      | begin,select * from test_table,INSERT INTO test_table VALUES (?, ?, ?),commit                                                                                         | 1      | rwS1   | 1       | 4          | 172.100.9.8   | 8066          | 1,2,3,4        | 3                |
      | delete from db2.test_table1,                                                                                                                                          | 1      | rwS1   | 1       | 2          | 172.100.9.8   | 8066          | 22,23          | 2                |
      | start transaction,delete from test_table,begin                                                                                                                        | 1      | rwS1   | 1       | 3          | 172.100.9.8   | 8066          | 19,20,21       | 3                |
      | start transaction,SELECT * FROM test_table1 WHERE id = ?,UPDATE test_table1 SET age = age - ? WHERE id = ?,UPDATE test_table1 SET age = age * ? WHERE id = ?,rollback | 1      | rwS1   | 1       | 5          | 172.100.9.8   | 8066          | 14,15,16,17,18 | 3                |
      | start transaction,UPDATE test_table1 SET age = ? WHERE id = ?,DELETE FROM test_table1 WHERE id = ?,UPDATE test_table1 SET age = ? WHERE id = ?,commit                 | 1      | rwS1   | 1       | 5          | 172.100.9.8   | 8066          | 5,6,7,8,9      | 1                |

    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                                                           | expect  | db  |
      | rwS1 | 111111 | conn_31 | False   | set autocommit=0                                              | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | update test_table set name='test_name'                        | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | select * from test_table                                      | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | commit                                                        | success | db1 |

      | rwS1 | 111111 | conn_31 | False   | delete from db2.test_table1 where id in (1, 4)                | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | insert into db2.test_table1 values(3,'name3',3),(4,'name4',4) | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | rollback                                                      | success | db1 |

      | rwS1 | 111111 | conn_31 | true    | delete from db2.test_table1                                   | success | db1 |
    Given sleep "2" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                    | sql_digest-2                                 | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | set autocommit=0                                              | SET autocommit = ?                           | Set        | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 2        | update test_table set name='test_name'                        | UPDATE test_table SET name = ?               | Update     | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 3        | select * from test_table                                      | select * from test_table                     | Select     | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 4        | commit                                                        | commit                                       | Commit     | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 5        | delete from db2.test_table1 where id in (1, 4)                | DELETE FROM db2.test_table1 WHERE id IN (?)  | Delete     | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 1      | 1                |
      | 6        | insert into db2.test_table1 values(3,'name3',3),(4,'name4',4) | INSERT INTO db2.test_table1 VALUES (?, ?, ?) | Insert     | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 2      | 2                |
      | 7        | rollback                                                      | rollback                                     | Rollback   | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
      | 8        | delete from db2.test_table1                                   | delete from db2.test_table1                  | Delete     | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 2      | 2                |
      | 9        | exit                                                          |                                              | Other      | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                          | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6 | examined_rows-9 |
      | 1       | 1       | rwS1   | 172.100.9.8   | 8066          | 1,2,3,4   | 4           | 0               |
      | 2       | 1       | rwS1   | 172.100.9.8   | 8066          | 5,6,7     | 3           | 3               |
      | 3       | 1       | rwS1   | 172.100.9.8   | 8066          | 8,9       | 2           | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                 | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      |                                              | 1       | rwS1   | 1      | 0      | 0               |
      | commit                                       | 1       | rwS1   | 1      | 0      | 0               |
      | delete from db2.test_table1                  | 1       | rwS1   | 1      | 2      | 2               |
      | DELETE FROM db2.test_table1 WHERE id IN (?)  | 1       | rwS1   | 1      | 1      | 1               |
      | INSERT INTO db2.test_table1 VALUES (?, ?, ?) | 1       | rwS1   | 1      | 2      | 2               |
      | rollback                                     | 1       | rwS1   | 1      | 0      | 0               |
      | select * from test_table                     | 1       | rwS1   | 1      | 0      | 0               |
      | SET autocommit = ?                           | 1       | rwS1   | 1      | 0      | 0               |
      | UPDATE test_table SET name = ?               | 1       | rwS1   | 1      | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                       | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | DELETE FROM db2.test_table1 WHERE id IN (?),INSERT INTO db2.test_table1 VALUES (?, ?, ?),rollback | 1      | rwS1   | 1       | 3          | 172.100.9.8   | 8066          | 5,6,7     | 3                |
      | delete from db2.test_table1,                                                                      | 1      | rwS1   | 1       | 2          | 172.100.9.8   | 8066          | 8,9       | 2                |
      | SET autocommit = ?,UPDATE test_table SET name = ?,select * from test_table,commit                 | 1      | rwS1   | 1       | 4          | 172.100.9.8   | 8066          | 1,2,3,4   | 0                |


    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                                              | expect  | db  |
      | rwS1 | 111111 | conn_31 | False   | begin                                            | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | select * from test_table                         | success | db1 |

      | rwS1 | 111111 | conn_41 | False   | start transaction                                  | success | db2 |
      | rwS1 | 111111 | conn_41 | False   | update test_table1 set age =33 where id=1          | success | db2 |
      | rwS1 | 111111 | conn_41 | False   | delete from test_table1 where id=5                 | success | db2 |
      | rwS1 | 111111 | conn_41 | False   | update test_table1 set age =44 where id=100        | success | db2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | select * from sql_log                                 | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user          | length{(0)}  | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

     Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                                 | expect  | db  |
      | rwS1 | 111111 | conn_31 | False   | commit                              | success | db1 |
      | rwS1 | 111111 | conn_31 | true    | drop table if exists test_table     | success | db1 |
      | rwS1 | 111111 | conn_41 | False   | commit                              | success | db2 |
      | rwS1 | 111111 | conn_41 | true    | drop table if exists test_table1    | success | db2 |



  Scenario: test samplingRate=100 and xa transaction sql  ---- shardinguser  #9
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | true     | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |

    Then execute admin cmd "reload @@samplingRate=100"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                   | expect                                                       | db               |
      | conn_0 | False   | select variable_name,variable_value from dble_variables where variable_name in ('sqlLogTableSize','samplingRate')     | has{(('sqlLogTableSize', '1024'), ('samplingRate', '100'))}  | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | set autocommit=0                                                                | success | schema1 |
      | conn_1 | False    | set xa=on                                                                       | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn2' where id=1                                  | success | schema1 |
      | conn_1 | False    | select * from sharding_4_t1                                                     | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | commit                                                                          | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |
      | conn_1 | False    | delete from sharding_4_t1 where id=4                                            | success | schema1 |
      | conn_1 | False    | rollback                                                                        | success | schema1 |
      | conn_1 | True     | delete from sharding_4_t1                                                       | success | schema1 |
    Given sleep "2" seconds

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                     | sql_digest-2                                   | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | set autocommit=0                               | SET autocommit = ?                             | Set        | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 2        | set xa=on                                      | set xa=on                                      | Set        | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 3        | update sharding_4_t1 set name='dn2' where id=1 | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | Update     | 1       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 4        | select * from sharding_4_t1                    | select * from sharding_4_t1                    | Select     | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 5        | commit                                         | commit                                         | Commit     | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 6        | insert into sharding_4_t1 values(5,'name5')    | INSERT INTO sharding_4_t1 VALUES (?, ?)        | Insert     | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 7        | delete from sharding_4_t1 where id=4           | DELETE FROM sharding_4_t1 WHERE id = ?         | Delete     | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 8        | rollback                                       | rollback                                       | Rollback   | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 9        | delete from sharding_4_t1                      | delete from sharding_4_t1                      | Delete     | 3       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 10       | exit                                           |                                                | Other      | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1,2,3,4,5 | 5           | 5               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 6,7,8     | 3           | 2               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 9,10      | 2           | 4               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                   | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      |                                                | 2       | test   | 1      | 0      | 0               |
      | commit                                         | 2       | test   | 1      | 0      | 0               |
      | delete from sharding_4_t1                      | 2       | test   | 1      | 4      | 4               |
      | DELETE FROM sharding_4_t1 WHERE id = ?         | 2       | test   | 1      | 1      | 1               |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)        | 2       | test   | 1      | 1      | 1               |
      | rollback                                       | 2       | test   | 1      | 0      | 0               |
      | select * from sharding_4_t1                    | 2       | test   | 1      | 4      | 4               |
      | SET autocommit = ?                             | 2       | test   | 1      | 0      | 0               |
      | set xa=on                                      | 2       | test   | 1      | 0      | 0               |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ? | 2       | test   | 1      | 1      | 1               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                                    | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | delete from sharding_4_t1,                                                                                     | 1      | test   | 2       | 2          | 172.100.9.8   | 8066          | 9,10      | 4                |
      | INSERT INTO sharding_4_t1 VALUES (?, ?),DELETE FROM sharding_4_t1 WHERE id = ?,rollback                        | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 6,7,8     | 2                |
      | SET autocommit = ?,set xa=on,UPDATE sharding_4_t1 SET name = ? WHERE id = ?,select * from sharding_4_t1,commit | 1      | test   | 2       | 5          | 172.100.9.8   | 8066          | 1,2,3,4,5 | 5                |


    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                         | expect  | db      |
      | conn_1 | False    | drop table if exists sharding_4_t1          | success | schema1 |



  Scenario: test samplingRate=100 and implict commit   #10
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False    | drop table if exists sharding_4_t2                                              | success | schema1 |
      | conn_1 | true     | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |

    Then execute admin cmd "reload @@samplingRate=100"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |


    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_1 | False    | create table sharding_4_t2(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t2 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_1 | False    | create index index_name1 on sharding_4_t1 (name)                                | success | schema1 |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn1' where id=4                                  | success | schema1 |
      | conn_1 | False    | drop index index_name1 on sharding_4_t1                                         | success | schema1 |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn4' where id=3                                  | success | schema1 |
      | conn_1 | False    | start transaction                                                               | success | schema1 |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | set autocommit=0                                                                | success | schema1 |
      | conn_1 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_1 | False    | set autocommit=1                                                                | success | schema1 |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | delete from sharding_4_t1 where id=1                                            | success | schema1 |
      | conn_1 | False    | truncate table sharding_4_t2                                                    | success | schema1 |
      | conn_1 | False    | begin                                                                           | success | schema1 |
      | conn_1 | False    | delete from sharding_4_t1 where id=2                                            | success | schema1 |
      | conn_1 | False    | drop table if exists sharding_4_t2                                              | success | schema1 |
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                                      | sql_digest-2                                              | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | begin                                                                           | begin                                                     | Begin      | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 2        | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | INSERT INTO sharding_4_t1 VALUES (?, ?)                   | Insert     | 1       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 3        | create table sharding_4_t2(id int, name varchar(20))                            | CREATE TABLE sharding_4_t2 (  id int,  name varchar(20) ) | DDL        | 1       | 2       | test   | 172.100.9.8   | 8066          | 0      | 4                |
      | 4        | begin                                                                           | begin                                                     | Begin      | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 5        | insert into sharding_4_t2 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | INSERT INTO sharding_4_t2 VALUES (?, ?)                   | Insert     | 2       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 6        | create index index_name1 on sharding_4_t1 (name)                                | CREATE INDEX index_name1 ON sharding_4_t1 (name)          | DDL        | 2       | 2       | test   | 172.100.9.8   | 8066          | 0      | 4                |
      | 7        | begin                                                                           | begin                                                     | Begin      | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 8        | update sharding_4_t1 set name='dn1' where id=4                                  | UPDATE sharding_4_t1 SET name = ? WHERE id = ?            | Update     | 3       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 9        | drop index index_name1 on sharding_4_t1                                         | DROP INDEX index_name1 ON sharding_4_t1                   | DDL        | 3       | 2       | test   | 172.100.9.8   | 8066          | 0      | 4                |
      | 10       | begin                                                                           | begin                                                     | Begin      | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 11       | select * from sharding_4_t1                                                     | select * from sharding_4_t1                               | Select     | 4       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 12       | begin                                                                           | begin                                                     | Begin      | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 13       | begin                                                                           | begin                                                     | Begin      | 5       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 14       | update sharding_4_t1 set name='dn4' where id=3                                  | UPDATE sharding_4_t1 SET name = ? WHERE id = ?            | Update     | 6       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 15       | start transaction                                                               | start transaction                                         | Other      | 6       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 16       | begin                                                                           | begin                                                     | Begin      | 7       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 17       | set autocommit=0                                                                | SET autocommit = ?                                        | Set        | 8       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 18       | select * from sharding_4_t1                                                     | select * from sharding_4_t1                               | Select     | 8       | 2       | test   | 172.100.9.8   | 8066          | 4      | 4                |
      | 19       | set autocommit=1                                                                | SET autocommit = ?                                        | Set        | 8       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 20       | begin                                                                           | begin                                                     | Begin      | 9       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 21       | delete from sharding_4_t1 where id=1                                            | DELETE FROM sharding_4_t1 WHERE id = ?                    | Delete     | 9       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 22       | truncate table sharding_4_t2                                                    | truncate table sharding_4_t2                              | DDL        | 9       | 2       | test   | 172.100.9.8   | 8066          | 0      | 4                |
      | 23       | begin                                                                           | begin                                                     | Begin      | 10      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 24       | delete from sharding_4_t1 where id=2                                            | DELETE FROM sharding_4_t1 WHERE id = ?                    | Delete     | 10      | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
      | 25       | drop table if exists sharding_4_t2                                              | DROP TABLE IF EXISTS sharding_4_t2                        | DDL        | 10      | 2       | test   | 172.100.9.8   | 8066          | 0      | 4                |
      | 26       | drop table if exists sharding_4_t1                                              | DROP TABLE IF EXISTS sharding_4_t1                        | DDL        | 11      | 2       | test   | 172.100.9.8   | 8066          | 0      | 4                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                          | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1,2,3     | 3           | 8               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 4,5,6     | 3           | 8               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 7,8,9     | 3           | 5               |
      | 4       | 2       | test   | 172.100.9.8   | 8066          | 10,11,12  | 3           | 4               |
      | 5       | 2       | test   | 172.100.9.8   | 8066          | 13        | 1           | 0               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 14,15     | 2           | 1               |
      | 7       | 2       | test   | 172.100.9.8   | 8066          | 16        | 1           | 0               |
      | 8       | 2       | test   | 172.100.9.8   | 8066          | 17,18,19  | 3           | 4               |
      | 9       | 2       | test   | 172.100.9.8   | 8066          | 20,21,22  | 3           | 5               |
      | 10      | 2       | test   | 172.100.9.8   | 8066          | 23,24,25  | 3           | 5               |
      | 11      | 2       | test   | 172.100.9.8   | 8066          | 26        | 1           | 4               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                              | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | begin                                                     | 2       | test   | 9      | 0      | 0               |
      | CREATE INDEX index_name1 ON sharding_4_t1 (name)          | 2       | test   | 1      | 0      | 4               |
      | CREATE TABLE sharding_4_t2 (  id int,  name varchar(20) ) | 2       | test   | 1      | 0      | 4               |
      | DELETE FROM sharding_4_t1 WHERE id = ?                    | 2       | test   | 2      | 2      | 2               |
      | DROP INDEX index_name1 ON sharding_4_t1                   | 2       | test   | 1      | 0      | 4               |
      | DROP TABLE IF EXISTS sharding_4_t1                        | 2       | test   | 1      | 0      | 4               |
      | DROP TABLE IF EXISTS sharding_4_t2                        | 2       | test   | 1      | 0      | 4               |
      | INSERT INTO sharding_4_t1 VALUES (?, ?)                   | 2       | test   | 1      | 4      | 4               |
      | INSERT INTO sharding_4_t2 VALUES (?, ?)                   | 2       | test   | 1      | 4      | 4               |
      | select * from sharding_4_t1                               | 2       | test   | 2      | 8      | 8               |
      | SET autocommit = ?                                        | 2       | test   | 2      | 0      | 0               |
      | start transaction                                         | 2       | test   | 1      | 0      | 0               |
      | truncate table sharding_4_t2                              | 2       | test   | 1      | 0      | 4               |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ?            | 2       | test   | 2      | 2      | 2               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                                                             | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | begin                                                                                                   | 2      | test   | 2       | 2          | 172.100.9.8   | 8066          | 13,16     | 0                |
      | begin,DELETE FROM sharding_4_t1 WHERE id = ?,DROP TABLE IF EXISTS sharding_4_t2                         | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 23,24,25  | 5                |
      | begin,DELETE FROM sharding_4_t1 WHERE id = ?,truncate table sharding_4_t2                               | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 20,21,22  | 5                |
      | begin,INSERT INTO sharding_4_t1 VALUES (?, ?),CREATE TABLE sharding_4_t2 (  id int,  name varchar(20) ) | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 1,2,3     | 8                |
      | begin,INSERT INTO sharding_4_t2 VALUES (?, ?),CREATE INDEX index_name1 ON sharding_4_t1 (name)          | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 4,5,6     | 8                |
      | begin,select * from sharding_4_t1,begin                                                                 | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 10,11,12  | 4                |
      | begin,UPDATE sharding_4_t1 SET name = ? WHERE id = ?,DROP INDEX index_name1 ON sharding_4_t1            | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 7,8,9     | 5                |
      | DROP TABLE IF EXISTS sharding_4_t1                                                                      | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 26        | 4                |
      | SET autocommit = ?,select * from sharding_4_t1,SET autocommit = ?                                       | 1      | test   | 2       | 3          | 172.100.9.8   | 8066          | 17,18,19  | 4                |
      | UPDATE sharding_4_t1 SET name = ? WHERE id = ?,start transaction                                        | 1      | test   | 2       | 2          | 172.100.9.8   | 8066          | 14,15     | 1                |



  Scenario: test samplingRate=100 and error sql   #11
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2" sqlMaxLimit="100">
        <globalTable name="test1" shardingNode="dn1,dn2" />
        <shardingTable name="sharding_2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.10:3306" user="test" maxCon="100" minCon="10" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.11:3306" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    <shardingUser name="test1" password="111111" schemas="schema1,schema2" readOnly="false"/>
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    Given execute oscmd in "dble-1"
      """
      mysql -uroot -p111111 -P9066 -h172.100.9.1 -Ddble_information -e "select concat('drop table if exists ',name,';') as 'select 1;' from dble_table" >/opt/dble/test.sql && \
      mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "source /opt/dble/test.sql"
      """

    Then execute admin cmd "reload @@samplingRate=100"

   #case Syntax error sql will not be counted --shardinguser
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                | db      |
      # not send shardingnode,select +0 tx_count+1
      | conn_1 | False   | SELECT DATABASE()                    | success                               | schema1 |
      | conn_1 | False   | SELECT USER()                        | success                               | schema1 |
      #  send shardingnode dn5  select +1 tx_count+1
      | conn_1 | False   | SELECT 2                             | success                               | schema1 |
      # to general.log check has none
      | conn_1 | False   | show tables                          | success                               | schema1 |
      # "use schema" implicitly sent "SELECT DATABASE() ",but not send shardingnode
      | conn_1 | False   | use schema66                         | Unknown database 'schema66'           | schema1 |
      # to general.log check has "select user",tx +1,select +1
      | conn_1 | False   | select user                          | Unknown column 'user' in 'field list' | schema1 |
      #case "explain"/"explain2"  select +0 tx_count+0
      | conn_1 | False   | explain select * from test           | success                               | schema1 |
      | conn_1 | False   | explain2 select * from test          | success                               | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
   #has implict tx_id 5,because :DBLE0REQ-1004
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1        | sql_digest-2      | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | SELECT DATABASE() | SELECT DATABASE() | Select     | 1       | 2       | test   | 172.100.9.8   | 8066          | 1      | 0                |
      | 2        | SELECT USER()     | SELECT USER()     | Select     | 2       | 2       | test   | 172.100.9.8   | 8066          | 1      | 0                |
      | 3        | SELECT 2          | SELECT ?          | Select     | 3       | 2       | test   | 172.100.9.8   | 8066          | 1      | 1                |
#      | 4        | show tables       | show tables       | Show       | 4       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 5        | select user       | select user       | Select     | 6       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6 | examined_rows-9 |
      | 1       | 2       | test   | 172.100.9.8   | 8066          | 1         | 1           | 0               |
      | 2       | 2       | test   | 172.100.9.8   | 8066          | 2         | 1           | 0               |
      | 3       | 2       | test   | 172.100.9.8   | 8066          | 3         | 1           | 1               |
#      | 4       | 2       | test   | 172.100.9.8   | 8066          | 4         | 1           | 0               |
      | 6       | 2       | test   | 172.100.9.8   | 8066          | 5         | 1           | 0               |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0      | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | SELECT ?          | 2       | test   | 1      | 1      | 1               |
      | SELECT DATABASE() | 2       | test   | 1      | 1      | 0               |
      | select user       | 2       | test   | 1      | 0      | 0               |
      | SELECT USER()     | 2       | test   | 1      | 1      | 0               |
#      | show tables       | 2       | test   | 1      | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0       | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | SELECT ?          | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 3         | 1                |
      | SELECT DATABASE() | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 1         | 0                |
      | select user       | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 5         | 0                |
      | SELECT USER()     | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 2         | 0                |
#      | show tables       | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 4         | 0                |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect                                 | db      |
      #case schema1 has default shardingnode table test100-103 would sent to "dn5"
      | conn_1 | False   | select * from test100                 | Table 'db3.test100' doesn't exist      | schema1 |
      | conn_1 | False   | insert into test101 values (1)        | Table 'db3.test101' doesn't exist      | schema1 |
      | conn_1 | False   | delete from test102                   | Table 'db3.test102' doesn't exist      | schema1 |
      | conn_1 | true    | update test103 set id =2 where id =1  | Table 'db3.test103' doesn't exist      | schema1 |
      #case schema2 has not default shardingnode ,dont count
      | conn_2 | False   | select * from test1000                | Table 'schema2.test1000' doesn't exist | schema2 |
      | conn_2 | False   | insert into test1001 values (1)       | Table 'schema2.test1001' doesn't exist | schema2 |
      | conn_2 | False   | delete from test1002                  | Table 'schema2.test1002' doesn't exist | schema2 |
      | conn_2 | true    | update test1003 set id =2 where id =1 | Table 'schema2.test1003' doesn't exist | schema2 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values
      | sql_id-0 | sql_stmt-1                           | sql_digest-2                        | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 6        | select * from test100                | SELECT * FROM test                  | Select     | 7       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 7        | insert into test101 values (1)       | INSERT INTO test VALUES (?)         | Insert     | 8       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 8        | delete from test102                  | DELETE FROM test                    | Delete     | 9       | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
      | 9        | update test103 set id =2 where id =1 | UPDATE test SET id = ? WHERE id = ? | Update     | 10      | 2       | test   | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_2"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_2" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6 | examined_rows-9 |
      | 7       | 2       | test   | 172.100.9.8   | 8066          | 6         | 1           | 0               |
      | 8       | 2       | test   | 172.100.9.8   | 8066          | 7         | 1           | 0               |
      | 9       | 2       | test   | 172.100.9.8   | 8066          | 8         | 1           | 0               |
      | 10      | 2       | test   | 172.100.9.8   | 8066          | 9         | 1           | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                        | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | DELETE FROM test                    | 2       | test   | 1      | 0      | 0               |
      | INSERT INTO test VALUES (?)         | 2       | test   | 1      | 0      | 0               |
      | SELECT * FROM test                  | 2       | test   | 1      | 0      | 0               |
      | SELECT ?                            | 2       | test   | 1      | 1      | 1               |
      | SELECT DATABASE()                   | 2       | test   | 1      | 1      | 0               |
      | select user                         | 2       | test   | 1      | 0      | 0               |
      | SELECT USER()                       | 2       | test   | 1      | 1      | 0               |
#      | show tables                         | 2       | test   | 1      | 0      | 0               |
      | UPDATE test SET id = ? WHERE id = ? | 2       | test   | 1      | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                         | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | DELETE FROM test                    | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 8         | 0                |
      | INSERT INTO test VALUES (?)         | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 7         | 0                |
      | SELECT * FROM test                  | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 6         | 0                |
      | SELECT ?                            | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 3         | 1                |
      | SELECT DATABASE()                   | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 1         | 0                |
      | select user                         | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 5         | 0                |
      | SELECT USER()                       | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 2         | 0                |
#      | show tables                         | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 4         | 0                |
      | UPDATE test SET id = ? WHERE id = ? | 1      | test   | 2       | 1          | 172.100.9.8   | 8066          | 9         | 0                |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                           | expect  | db      |
      | conn_1 | False   | drop table if exists test                                                     | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                            | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.test1                                            | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1                                            | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sharding_2                                       | success | schema1 |
      | conn_1 | False   | create table test (id int,name varchar(20),age int)                           | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name varchar(20),age int)                  | success | schema1 |
      | conn_1 | False   | create table schema2.test1 (id int,name varchar(20),age int)                  | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name varchar(20),age int)                  | success | schema1 |
      | conn_1 | False   | create table schema2.sharding_2 (id int,name varchar(20),age int)             | success | schema1 |
      | conn_1 | False   | insert into test values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4)               | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4)      | success | schema1 |
      | conn_1 | False   | insert into schema2.test1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4)      | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4)      | success | schema1 |
      | conn_1 | true    | insert into schema2.sharding_2 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4) | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                   | expect       | db               |
      | conn_0 | False   | truncate dble_information.sql_log                     | success      | dble_information |
      #complex don't supported sql
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                            | expect                                            | db      |
      | conn_1 | False   | update schema1.test a,schema2.test1 b set a.age=b.age+1,b.name=a.name-1 where a.name=b.name                                    | This `Complex Update Syntax` is not supported!    | schema1 |
      | conn_1 | False   | delete schema1.test,schema2.test1 from schema1.test,schema2.test1 where schema1.test.name=schema2.test1.name                   | This `Complex Delete Syntax` is not supported!    | schema1 |
      | conn_1 | False   | update schema2.sharding_2_t1 a,db1.single_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=2 and b.id=1                       | Table `db1`.`single_t2` doesn't exist             | schema1 |
      | conn_1 | False   | update db1.sharding_2_t1 a,schema2.single_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=2 and b.id=1                       | Table `db1`.`sharding_2_t1` doesn't exist         | schema1 |
      | conn_1 | False   | delete db1.single_t2 from schema1.sharding_2_t1,schema2.single_t2 where schema1.sharding_2_t1.id=2 and schema2.single_t2.id =2 | Table `db1`.`single_t2` doesn't exist             | schema1 |
      | conn_1 | False   | delete schema2.single_t2 from schema1.sharding_2_t1,schema2.single_t2 where db1.sharding_2_t1.id=2 and schema2.single_t2.id =2 | Table `db1`.`sharding_2_t1` doesn't exist         | schema1 |
      | conn_1 | False   | insert into sharding_4_t1(id,name) select s2.id,s2.name from schema2.sharding_2 s2 join test s2g on s2.id=s2g.id               | This `INSERT ... SELECT Syntax` is not supported  | schema1 |
      | conn_1 | true    | replace into test(name) select name from sharding_4_t1                                                                         | This `REPLACE ... SELECT Syntax` is not supported | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect      | db               |
      | conn_0 | False   | select * from sql_log                               | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(0)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(0)} | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user | length{(0)} | dble_information |


    #case Syntax error sql will not be counted --rwSplitUser
     Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | split1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | split1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | split1 | 111111 | conn_3 | true    | insert into test_table values (1,'1',1),(2, '2',2)        | success | db1 |
     Given Restart dble in "dble-1" success
     Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                    | expect                                      | db  |
      # ERROR 1049 (42000): Unknown database  tx_count +1  tx_rows +1 select_count +1 select_rows +1
      | split1 | 111111 | conn_3 | true     | use db11                              | Unknown database 'db11'                     | db1 |
      # ERROR 1146 (42S02): Table  doesn't exist tx_count +1  tx_rows +1 delete_count +1 delete_rows +0
      | split1 | 111111 | conn_3 | False    | delete from test_table2 where id =1   | Table 'db1.test_table2' doesn't exist       | db1 |
      # ERROR 1064 (42000): You have an error in your SQL synta donot count
      | split1 | 111111 | conn_3 | False    | select * froom test_table where id =1 | error in your SQL syntax                    | db1 |
      #explain  donot count
      | split1 | 111111 | conn_3 | False    | explain select * from test_table      | success                                     | db1 |
      #ERROR 1193 (HY000): Unknown system variable 'user' donot count
      | split1 | 111111 | conn_3 | False    | set user=1                            | Unknown system variable 'user'              | db1 |
      #ERROR 1054 (42S22): Unknown column 'a.id' in 'where clause' tx_count +1  tx_rows +0 select_count +1 select_rows +0
      | split1 | 111111 | conn_3 | False    | select * from test_table where a.id=1 | Unknown column 'a.id'                       | db1 |
      #ERROR 1305 (42000): FUNCTION db1.councat_ws does not exist tx_count +1  tx_rows +0 select_count +1 select_rows +0
      | split1 | 111111 | conn_3 | False    | select councat_ws('',id,age) as 'll' from test_table group by ll | FUNCTION db1.councat_ws does not exist                           | db1 |
      #ERROR 1054 (42S22): Unknown column 'ls' in 'group statement' tx_count +1  tx_rows +0 select_count +1 select_rows +0
      | split1 | 111111 | conn_3 | False    | select concat_ws('',id,age) as 'll' from test_table group by ls  | Unknown column 'ls' in 'group statement'                         | db1 |
      #ERROR 1248 (42000): Every derived table must have its own alias tx_count +1  tx_rows +0 select_count +1 select_rows +0
      | split1 | 111111 | conn_3 | true     | select * from (select s.sno from test_table s where s.id=1)      | Every derived table must have its own alias                      | db1 |

     Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_11"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_11" has lines with following column values
      | sql_id-0 | sql_stmt-1                                                       | sql_digest-2                                                       | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 |
      | 1        | use db11                                                         | use db11                                                           | Other      | 1       | 4       | split1 | 172.100.9.8   | 8066          | 0      | 0                |
      | 2        | delete from test_table2 where id =1                              | DELETE FROM test_table2 WHERE id = ?                               | Delete     | 2       | 4       | split1 | 172.100.9.8   | 8066          | 0      | 0                |
      | 3        | select * from test_table where a.id=1                            | SELECT * FROM test_table WHERE a.id = ?                            | Select     | 5       | 4       | split1 | 172.100.9.8   | 8066          | 0      | 0                |
      | 4        | select councat_ws('',id,age) as 'll' from test_table group by ll | SELECT councat_ws(?, id, age) AS "ll" FROM test_table GROUP BY ll  | Select     | 6       | 4       | split1 | 172.100.9.8   | 8066          | 0      | 0                |
      | 5        | select concat_ws('',id,age) as 'll' from test_table group by ls  | SELECT concat_ws(?, id, age) AS "ll" FROM test_table GROUP BY ls   | Select     | 7       | 4       | split1 | 172.100.9.8   | 8066          | 0      | 0                |
      | 6        | select * from (select s.sno from test_table s where s.id=1)      | SELECT * FROM (  SELECT s.sno  FROM test_table s  WHERE s.id = ? ) | Select     | 8       | 4       | split1 | 172.100.9.8   | 8066          | 0      | 0                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_12"
      | conn   | toClose | sql                                            | db               |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user   | dble_information |
    Then check resultset "resulte_12" has lines with following column values
      | tx_id-0 | entry-1 | user-2 | source_host-3 | source_port-4 | sql_ids-5 | sql_exec-6 | examined_rows-9 |
      | 1       | 4       | split1 | 172.100.9.8   | 8066          | 1         | 1           | 0               |
      | 2       | 4       | split1 | 172.100.9.8   | 8066          | 2         | 1           | 0               |
      | 5       | 4       | split1 | 172.100.9.8   | 8066          | 3         | 1           | 0               |
      | 6       | 4       | split1 | 172.100.9.8   | 8066          | 4         | 1           | 0               |
      | 7       | 4       | split1 | 172.100.9.8   | 8066          | 5         | 1           | 0               |
      | 8       | 4       | split1 | 172.100.9.8   | 8066          | 6         | 1           | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_3"
      | conn   | toClose | sql                                                | db               |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_3" has lines with following column values
      | sql_digest-0                                                       | entry-1 | user-2 | exec-3 | rows-5 | examined_rows-6 |
      | DELETE FROM test_table2 WHERE id = ?                               | 4       | split1 | 1      | 0      | 0               |
      | SELECT * FROM (  SELECT s.sno  FROM test_table s  WHERE s.id = ? ) | 4       | split1 | 1      | 0      | 0               |
      | SELECT * FROM test_table WHERE a.id = ?                            | 4       | split1 | 1      | 0      | 0               |
      | SELECT concat_ws(?, id, age) AS "ll" FROM test_table GROUP BY ls   | 4       | split1 | 1      | 0      | 0               |
      | SELECT councat_ws(?, id, age) AS "ll" FROM test_table GROUP BY ll  | 4       | split1 | 1      | 0      | 0               |
      | use db11                                                           | 4       | split1 | 1      | 0      | 0               |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_4"
      | conn   | toClose | sql                                                   | db               |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user   | dble_information |
    Then check resultset "resulte_4" has lines with following column values
      | tx_digest-0                                                        | exec-1 | user-2 | entry-3 | sql_exec-4 | source_host-5 | source_port-6 | sql_ids-7 | examined_rows-10 |
      | DELETE FROM test_table2 WHERE id = ?                               | 1      | split1 | 4       | 1          | 172.100.9.8   | 8066          | 2         | 0                |
      | SELECT * FROM (  SELECT s.sno  FROM test_table s  WHERE s.id = ? ) | 1      | split1 | 4       | 1          | 172.100.9.8   | 8066          | 6         | 0                |
      | SELECT * FROM test_table WHERE a.id = ?                            | 1      | split1 | 4       | 1          | 172.100.9.8   | 8066          | 3         | 0                |
      | SELECT concat_ws(?, id, age) AS "ll" FROM test_table GROUP BY ls   | 1      | split1 | 4       | 1          | 172.100.9.8   | 8066          | 5         | 0                |
      | SELECT councat_ws(?, id, age) AS "ll" FROM test_table GROUP BY ll  | 1      | split1 | 4       | 1          | 172.100.9.8   | 8066          | 4         | 0                |
      | use db11                                                           | 1      | split1 | 4       | 1          | 172.100.9.8   | 8066          | 1         | 0                |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect  | db      |
      | conn_1 | False   | drop table if exists test                         | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.test1                | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1                | success | schema1 |
      | conn_1 | true    | drop table if exists schema2.sharding_2           | success | schema1 |
     Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | split1 | 111111 | conn_3 | true    | drop table if exists test_table                           | success | db1 |
      | split1 | 111111 | conn_3 | true    | drop table if exists test_table2                          | success | db1 |


@skip
  Scenario: test samplingRate=100 and special case  #12
    Then execute admin cmd "reload @@samplingRate=100"
    Then execute admin cmd "reload @@statistic_table_size =10000000 where table ='sql_log'"

    Given execute sql "1000" times in "dble-1" at concurrent
      | conn   | sql                   | db      |
      | conn_0 | begin;select 2        | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                 | expect         | db               |
      | conn_0 | False   | select * from sql_log                               | length{(1124)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user        | length{(1124)} | dble_information |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user    | length{(1)}    | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_digest_by_entry_by_user | length{(1)}    | dble_information |




  Scenario: test samplingRate>0 and samplingRate<100   #13
    Then execute admin cmd "reload @@samplingRate=40"
    Then execute admin cmd "reload @@statistic_table_size =10 where table ='sql_log'"
    Then execute sql in "dble-1" in "user" mode
      | toClose | sql                                         | expect   | db      |
      | False   | drop table if exists test                   | success  | schema1 |
      | True    | create table test(id int,name varchar(20))  | success  | schema1 |
    Then connect "dble-1" to insert "1000" of data for "test"
    Given execute sql "500" times in "dble-1" at concurrent
      | sql                                | db      |
      | select name from test where id ={} | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect       | db               |
      | conn_0 | False   | select * from sql_log                        | length{(10)} | dble_information |
      | conn_0 | true    | select * from sql_log_by_tx_by_entry_by_user | length{(10)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | toClose | sql                                         | expect   | db      |
      | true    | drop table if exists test                   | success  | schema1 |

    Given execute oscmd in "dble-1"
      """
      mysql -uroot -p111111 -P9066 -h172.100.9.1 -Ddble_information -e "select concat('drop table if exists ',name,';') as 'select 1;' from dble_table" >/opt/dble/test.sql && \
      mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "source /opt/dble/test.sql"
      """