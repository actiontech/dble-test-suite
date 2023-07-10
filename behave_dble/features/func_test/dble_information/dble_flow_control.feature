# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2023/07/07

Feature:  dble_flow_control test


  Scenario:  dble_flow_control  table #1
  #case desc dble_flow_control
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_flow_control"
      | conn   | toClose | sql                    | db               |
      | conn_0 | False   | desc dble_flow_control | dble_information |
    Then check resultset "dble_flow_control" has lines with following column values
      | Field-0             | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | connection_type     | varchar(15)  | NO     | PRI   | None      |         |
      | connection_id       | int(11)      | NO     | PRI   | None      |         |
      | connection_info     | varchar(255) | NO     |       | None      |         |
      | writing_queue_bytes | int(11)      | NO     |       | None      |         |
      | reading_queue_bytes | int(11)      | YES    |       | None      |         |
      | flow_controlled     | varchar(7)   | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect            | db               |
      | conn_0 | False   | desc dble_flow_control             | length{(6)}       | dble_information |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                       | expect                                      |
      | conn_0 | False   | select connection_type from dble_flow_control limit 1                                                     | has{(('MySQLConnection',),)}                |
      | conn_0 | False   | select writing_queue_bytes,reading_queue_bytes from dble_flow_control order by connection_id desc limit 1 | has{((0, 0),)}                              |
      | conn_0 | False   | select * from dble_flow_control where flow_controlled like '%false%'                                      | length{(22)}                                |
      | conn_0 | False   | select max(connection_type) from dble_flow_control                                                        | has{(('MySQLConnection',),)}                |
      | conn_0 | False   | select min(connection_type) from dble_flow_control                                                        | has{(('MySQLConnection',),)}                |
      | conn_0 | False   | delete from dble_flow_control where connection_id = 3                                                     | Access denied for table 'dble_flow_control' |
      | conn_0 | False   | update dble_flow_control set connection_id = 1 where flow_controlled is null                              | Access denied for table 'dble_flow_control' |
      | conn_0 | True    | insert into dble_flow_control values (1,2,3,4,5,6)                                                        | Access denied for table 'dble_flow_control' |


  Scenario: test flow control manager command  #2
   ##test flow_control @@show  #1
     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       $a\-DenableFlowControl=false
       """
     Then Restart dble in "dble-1" success
     Then execute sql in "dble-1" in "admin" mode
       | sql                   | expect      |
       | flow_control @@show   | length{(0)} |
     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       $a\-DenableFlowControl=true
       """
     Then Restart dble in "dble-1" success
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
       | conn   | toClose | sql                     | db               |
       | conn_0 | true    | flow_control @@show     | dble_information |
     Then check resultset "B" has lines with following column values
       | FLOW_CONTROL_TYPE-0     | FLOW_CONTROL_HIGH_LEVEL-1 |  FLOW_CONTROL_LOW_LEVEL-2 |
       | FRONT_END               | 4194304                   |  262144                   |
       | ha_group1-hostM1        | 4194304                   |  262144                   |
       | ha_group2-hostM2        | 4194304                   |  262144                   |
     ##test flow_control @@set [enableFlowControl = true/false] [flowControlHighLevel = ?] [flowControlLowLevel = ?]
     Then execute sql in "dble-1" in "admin" mode
       | conn   | toClose | sql                                                                                           | expect                                                        |
       | conn_0 | False   | flow_control @@set enableFlowControl=true flowControlHighLevel=128 flowControlLowLevel=256    | The flowControlHighLevel must bigger than flowControlLowLevel |
       | conn_0 | False   | flow_control @@set enableFlowControl=true flowControlHighLevel=128                            | The flowControlHighLevel must bigger than flowControlLowLevel |
       | conn_0 | False   | flow_control @@set enableFlowControl=true flowControlHighLevel=128 flowControlLowLevel=128    | The flowControlHighLevel must bigger than flowControlLowLevel |
       | conn_0 | False   | flow_control @@set enableFlowControl=true flowControlHighLevel=4096 flowControlLowLevel=256   | success                                                       |
       | conn_0 | False   | flow_control @@set flowControlHighLevel=1024                                                  | success                                                       |
       | conn_0 | False   | flow_control @@set flowControlLowLevel=128                                                    | success                                                       |
       | conn_0 | False   | flow_control @@set enableFlowControl=false                                                    | success                                                       |
     Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
       """
       flowControlLowLevel=128
       enableFlowControl=false
       flowControlHighLevel=1024
       """