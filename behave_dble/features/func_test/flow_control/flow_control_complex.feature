# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2021/7/22


Feature: test flow_control about complex query


  Scenario: test flow_control about complex query   # 1
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

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                  | expect  | db      | charset |
      | conn_1 | true    | drop table if exists sharding_2_t1                                                                                                                                   | success | schema1 | utf8mb4 |
      | conn_1 | true    | drop table if exists sharding_4_t1                                                                                                                                   | success | schema1 | utf8mb4 |
      | conn_1 | true    | create table sharding_2_t1 (id int,a varchar(120) ,b varchar(120) ,c varchar(120) ,d varchar(120) ) default charset=utf8                                             | success | schema1 | utf8mb4 |
      | conn_1 | true    | create table sharding_4_t1 (id int,a varchar(120) ,b varchar(120) ,c varchar(120) ,d varchar(120) ) default charset=utf8                                             | success | schema1 | utf8mb4 |
      | conn_1 | true    | insert into sharding_2_t1 values (1,repeat("中",32),repeat("华",32),repeat("民",32),repeat("国",32)),(2,repeat("中",32),repeat("华",32),repeat("民",32),repeat("国",32)) | success | schema1 | utf8mb4 |
      | conn_1 | true    | insert into sharding_4_t1 values (1,repeat("中",32),repeat("华",32),repeat("民",32),repeat("国",32)),(2,repeat("中",32),repeat("华",32),repeat("民",32),repeat("国",32)) | success | schema1 | utf8mb4 |
      | conn_1 | true    | insert into sharding_4_t1 values (3,repeat("中",32),repeat("华",32),repeat("民",32),repeat("国",32)),(4,repeat("中",32),repeat("华",32),repeat("民",32),repeat("国",32)) | success | schema1 | utf8mb4 |
    #prepare more data
    Given execute sql "22" times in "dble-1" at concurrent 22
      | sql                                                                                | db      |
      | insert into sharding_2_t1(id,a,b,c,d) select id,a,b,c,d from sharding_2_t1         | schema1 |
    Given execute sql "18" times in "dble-1" at concurrent 18
      | sql                                                                                | db      |
      | insert into sharding_4_t1(id,a,b,c,d) select id,a,b,c,d from sharding_4_t1         | schema1 |
    Then Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect  | db      | charset |
      | conn_1 | true    | drop view if exists view1                             | success | schema1 | utf8mb4 |
      | conn_1 | true    | drop view if exists view2                             | success | schema1 | utf8mb4 |
      | conn_1 | true    | create view view1 as select * from sharding_2_t1      | success | schema1 | utf8mb4 |
      | conn_1 | true    | create view view2 as select * from sharding_4_t1      | success | schema1 | utf8mb4 |

    #####  case 1: unsupported view select #####
    # query would "hang"
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                 | db      | charset |
      | conn_2  | true    | select * from view1 join view2      | schema1 | utf8mb4 |
    # 9066 execute cmd
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |


    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      closed
      Lost connection
      """
 # due to   DBLE0REQ-1275
#    Given sleep "5" seconds
    Given kill mysql query in "dble-1" forcely
      """
      select * from view1 join view2
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      begins flow control
      remove flow control
      NullPointerException
      caught err:
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect        | db      | charset |
      | conn_1 | true    | select * from sharding_2_t1 limit 100                 | length{(100)} | schema1 | utf8mb4 |
    Given execute linux command in "dble-1"
      """
      rm -rf /opt/dble/Memory*
      """
    Then Restart dble in "dble-1" success


    #####  case 2: supported view select #####
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                        | db      | charset |
      | conn_3  | true    | select * from (select * from view1) a      | schema1 | utf8mb4 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      closed
      Lost connection
      """
#    Given sleep "5" seconds
    Given kill mysql query in "dble-1" forcely
      """
      select * from (select * from view1) a
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      begins flow control
      remove flow control
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect        | db      | charset |
      | conn_1 | true    | select * from sharding_2_t1 limit 100                 | length{(100)} | schema1 | utf8mb4 |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      """
    Given execute linux command in "dble-1"
      """
      rm -rf /opt/dble/Memory*
      """
    Then Restart dble in "dble-1" success


    #####  case 3: unsupported complex select  #####
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                                    | db      | charset |
      | conn_4  | true    | select * from sharding_2_t1 a join sharding_4_t1  b on a.id = b.id     | schema1 | utf8mb4 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |

    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      closed
      Lost connection
      """
#    Given sleep "5" seconds
    Given kill mysql query in "dble-1" forcely
      """
      select * from sharding_2_t1 a join sharding_4_t1  b on a.id = b.id
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      begins flow control
      remove flow control
      NullPointerException
      caught err:
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect        | db      | charset |
      | conn_1 | true    | select * from sharding_2_t1 limit 100                 | length{(100)} | schema1 | utf8mb4 |
    Given execute linux command in "dble-1"
      """
      rm -rf /opt/dble/Memory*
      """
    Then Restart dble in "dble-1" success


    #####  case 4: supported complex select  #####
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                                                     | db      | charset |
      | conn_5  | true    | select * from sharding_2_t1 where id in (select id from sharding_4_t1) order by id      | schema1 | utf8mb4 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      closed
      Lost connection
      """
    Given sleep "10" seconds
    Given kill mysql query in "dble-1" forcely
      """
      select * from sharding_2_t1 where id in (select id from sharding_4_t1) order by id
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      begins flow control
      remove flow control
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect        | db      | charset |
      | conn_1 | true    | select * from sharding_2_t1 limit 100                 | length{(100)} | schema1 | utf8mb4 |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      """
    Given execute linux command in "dble-1"
      """
      rm -rf /opt/dble/Memory*
      """
    Then Restart dble in "dble-1" success


    #####  case 5: supported complex select  #####
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                | db      | charset |
      | conn_6  | true    | select * from (select * from sharding_2_t1) a      | schema1 | utf8mb4 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      closed
      Lost connection
      """
    Given sleep "2" seconds
    Given kill mysql query in "dble-1" forcely
      """
      select * from (select * from sharding_2_t1) a
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      begins flow control
      remove flow control
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect        | db      | charset |
      | conn_1 | true    | select * from sharding_2_t1 limit 100                 | length{(100)} | schema1 | utf8mb4 |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      """
    Given execute linux command in "dble-1"
      """
      rm -rf /opt/dble/Memory*
      """
    Then Restart dble in "dble-1" success


    #####  case 6: supported complex select  #####
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                                       | db      | charset |
      | conn_7  | true    | select * from sharding_2_t1 union all select * from sharding_4_t1         | schema1 | utf8mb4 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      closed
      Lost connection
      """
#    Given sleep "2" seconds
    Given kill mysql query in "dble-1" forcely
      """
      select * from sharding_2_t1 union all select * from sharding_4_t1
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      begins flow control
      remove flow control
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect        | db      | charset |
      | conn_1 | true    | select * from sharding_2_t1 limit 100                 | length{(100)} | schema1 | utf8mb4 |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      """
    Given execute linux command in "dble-1"
      """
      rm -rf /opt/dble/Memory*
      """
    Then Restart dble in "dble-1" success

    #####  case 7: supported complex select  #####
    Given execute sqls in "dble-1" at background
      | conn    | toClose | sql                                                          | db      | charset |
      | conn_8  | true    | select * from sharding_2_t1 order by id limit 1000000000     | schema1 | utf8mb4 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      closed
      Lost connection
      """
    Given sleep "5" seconds
    Given kill mysql query in "dble-1" forcely
      """
      select * from sharding_2_t1 order by id limit 1000000000
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | true    | select conn_send_task_queue,sql from session_connections                                | success | dble_information |
      | conn_0 | true    | flow_control @@list                                                                     | success | dble_information |
      | conn_0 | true    | flow_control @@set enableFlowControl=true flowControlStart=2 flowControlEnd=1           | success | dble_information |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      begins flow control
      remove flow control
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect        | db      | charset |
      | conn_1 | true    | select * from sharding_2_t1 limit 100                 | length{(100)} | schema1 | utf8mb4 |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      """
    Given execute linux command in "dble-1"
      """
      rm -rf /opt/dble/Memory*
      """

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                         | expect  | db      | charset |
      | conn_1 | true    | drop table if exists sharding_2_t1          | success | schema1 | utf8mb4 |
      | conn_1 | true    | drop table if exists sharding_4_t1          | success | schema1 | utf8mb4 |
      | conn_1 | true    | drop view if exists view1                   | success | schema1 | utf8mb4 |
      | conn_1 | true    | drop view if exists view2                   | success | schema1 | utf8mb4 |