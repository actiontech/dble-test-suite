# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/04/13

Feature: test flow control manager command

   @NORMAL
   Scenario: test flow_control @@show  #1
     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     $a\-DenableFlowControl=false
     """
     Then Restart dble in "dble-1" success
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
     | conn   | toClose | sql                     | db               |
     | conn_0 | true    | flow_control @@show     | dble_information |
     Then check resultset "A" has lines with following column values
     | FLOW_CONTROL_ENABLE-0   | FLOW_CONTROL_START-1 |  FLOW_CONTROL_END-2 |
     | false                   | 4096                 |  256                |
     Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     $a\-DenableFlowControl=true
     """
     Then Restart dble in "dble-1" success
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
     | conn   | toClose | sql                     | db               |
     | conn_0 | true    | flow_control @@show     | dble_information |
     Then check resultset "B" has lines with following column values
     | FLOW_CONTROL_ENABLE-0   | FLOW_CONTROL_START-1 |  FLOW_CONTROL_END-2 |
     | true                    | 4096                 |  256                |


   Scenario: test flow_control @@set[enableFlowControl = true/false] [flowControlStart = ?] [flowControlEnd = ?] #2
     Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                                                  | expect                                                                  |
     | conn_0 | False   | flow_control @@set enableFlowControl=true flowControlStart=128 flowControlEnd=256    | The flowControlStartThreshold must bigger than flowControlStopThreshold |
     | conn_0 | False   | flow_control @@set enableFlowControl=true flowControlStart=128                       | The flowControlStartThreshold must bigger than flowControlStopThreshold |
     | conn_0 | False   | flow_control @@set enableFlowControl=true flowControlStart=128 flowControlEnd=128    | The flowControlStartThreshold must bigger than flowControlStopThreshold |
     | conn_0 | False   | flow_control @@set enableFlowControl=true flowControlStart=4096 flowControlEnd=256   | success                                                                 |
     | conn_0 | False   | flow_control @@set flowControlStart=1024                                             | success                                                                 |
     | conn_0 | False   | flow_control @@set flowControlEnd=128                                                | success                                                                 |
     | conn_0 | False   | flow_control @@set enableFlowControl=false                                           | success                                                                 |
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
     | conn   | toClose | sql                     | db               |
     | conn_0 | true    | flow_control @@show     | dble_information |
     Then check resultset "C" has lines with following column values
     | FLOW_CONTROL_ENABLE-0    | FLOW_CONTROL_START-1 |  FLOW_CONTROL_END-2 |
     | false                    | 1024                 |  128                |
     Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
       """
       flowControlStopThreshold=128
       enableFlowControl=false
       flowControlStartThreshold=1024
       """