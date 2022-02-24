# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2021/7/22


Feature: test flow_control about loaddata

@skip
  Scenario: test flow_control about loaddata   # 1
    # prepare data
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       s/-Xmx1G/-Xmx4G/
       s/-XX:MaxDirectMemorySize=1G/-XX:MaxDirectMemorySize=4G/
       s/-Dprocessors=1/-Dprocessors=4/
       s/-DprocessorExecutor=1/-DprocessorExecutor=8/

       $a -DbufferPoolChunkSize=256
       $a -DprocessorCheckPeriod=1
       $a -DfrontSocketSoSndbuf=4096
       $a -DfrontSocketNoDelay=0
       $a -DenableFlowControl=true
       $a -DflowControlStartThreshold=2
       $a -DflowControlStopThreshold=1
       $a -DsqlExecuteTimeout=1800000
       $a -DidleTimeout=1800000
       """
    Then Restart dble in "dble-1" success
    Given create local and server file "data1.txt" with "50000" lines
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists test                                            | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_2_t1                                   | success | schema1 |
      | conn_1 | False   | create table test(id int,c int,d varchar(10),e varchar(10))          | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1(id int,c int,d varchar(10),e varchar(10)) | success | schema1 |
      | conn_1 | true    | insert into sharding_2_t1 values (1,1,repeat("b",8),repeat("c",8))   | success | schema1 |
    Given execute sql "6" times in "dble-1" at concurrent
      | sql                                                                | db      |
      | insert into sharding_2_t1(id) select id from sharding_2_t1         | schema1 |

    Given prepare a thread run btrace script "BtraceAboutFlowControl.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                                               | db      |
      | conn_1 | true    | load data infile '/opt/dble/data1.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'  | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | False   | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | False   | flow_control @@list                                                                     | success | dble_information |

    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      closed
      Lost connection
      """
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                            | expect  | db               |
      | conn_0 | False   | select conn_send_task_queue,sql from session_connections       | success | dble_information |
      | conn_0 | False   | flow_control @@list                                            | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=false                     | success | dble_information |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      begins flow control
      remove flow control
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect        | db      |
      | conn_1 | true    | select * from sharding_2_t1 limit 20                  | length{(20)}  | schema1 |

    Given stop btrace script "BtraceAboutFlowControl.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutFlowControl.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutFlowControl.java.log" on "dble-1"
    Given delete file "/opt/dble/data1.txt" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect  | db      |
      | conn_1 | False   | drop table if exists test                                            | success | schema1 |
      | conn_1 | true    | drop table if exists sharding_2_t1                                   | success | schema1 |