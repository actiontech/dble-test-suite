# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/04/13
# Modified by Jolie at 2021/09/09

Feature: test flow control manager command

   @NORMAL
   Scenario: test flow_control @@show  #1
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


   Scenario: test flow_control @@set [enableFlowControl = true/false] [flowControlHighLevel = ?] [flowControlLowLevel = ?] #2
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