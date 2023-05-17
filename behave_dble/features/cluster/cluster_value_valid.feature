# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2023/05/17

Feature: test cluster cnf


  Scenario: test grpcTimeout from DBLE0REQ-2089    #1
    ###dble_variables查看默认值为空，ucore集群模式下，才会显示grpcTimeout的值
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                              | expect          | db               |
      | conn_0 | true    | select * from dble_variables where variable_name like "%grp%"    | length{(0)}     | dble_information |

    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      $a grpcTimeout=100
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                      | expect          | db               |
      | conn_0 | true    | select * from dble_variables where variable_name like "%grpcTimeout%"    | length{(0)}     | dble_information |

    ##配置非法值
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      s/grpcTimeout=100/grpcTimeout=a/g
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ grpcTimeout \] 'a' data type should be int
      """

    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      s/grpcTimeout=a/grpcTimeout=1.1/g
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ grpcTimeout \] '1.1' data type should be int
      """

    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      s/grpcTimeout=1.1/grpcTimeout=null/g
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ grpcTimeout \] 'null' data type should be int
      """

    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      s/grpcTimeout=null/grpcTimeout=/g
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ grpcTimeout \] '' data type should be int
      """

    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      s/grpcTimeout=/grpcTimeout=0/g
      """
    Then restart dble in "dble-1" failed for
      """
      grpcTimeout should be greater than 1
      """

    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      s/grpcTimeout=0/grpcTimeout=-1/g
      """
    Then restart dble in "dble-1" failed for
      """
      grpcTimeout should be greater than 1
      """