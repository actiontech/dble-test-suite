# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/08


Feature: check in zk online key



  Scenario: dble-1 stop,change bootstrap.cnf the same of dble-2,start dble-1,the result will be wrong  #1
    Given reset dble registered nodes in zk
    Then check following " " exist in dir "/opt/dble/conf/bootstrap.cnf" in "dble-2"
      """
      -DinstanceName=2
      """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DinstanceName=1/c -DinstanceName=2
    /-DinstanceId=1/c -DinstanceId=2
    /-DserverId=server_1/c -DserverId=server_2
    """
    Given Restart dble in "dble-1" success
    Then restart dble in "dble-2" failed for
    """
    Online path with other IP or serverPort exist,make sure different instance has different instanceName
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DinstanceName=2/c -DinstanceName=1
    /-DinstanceId=2/c -DinstanceId=1
    /-DserverId=server_2/c -DserverId=server_1
    """
    Given Restart dble in "dble-1" success
    Given reset dble registered nodes in zk
