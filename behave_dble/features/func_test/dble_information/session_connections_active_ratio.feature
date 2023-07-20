# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2022/5/24

Feature:test session_connections_active_ratio
#DBLE0REQ-1106


  Scenario: desc table and unsupported dml  #1

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                         | expect        | db               |
      | conn_0 | False   | desc dble_information.session_connections_active_ratio      | length{(4)}   | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_1"
      | conn   | toClose | sql                                   | db               |
      | conn_0 | False   | desc session_connections_active_ratio | dble_information |
    Then check resultset "table_1" has lines with following column values
      | Field-0          | Type-1     | Null-2 | Key-3 | Default-4 | Extra-5 |
      | session_conn_id  | int(11)    | NO     | PRI   | None      |         |
      | last_half_minute | varchar(5) | NO     |       | None      |         |
      | last_minute      | varchar(5) | NO     |       | None      |         |
      | last_five_minute | varchar(5) | NO     |       | None      |         |
    #case unsupported update/delete/insert
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                | expect                                                     | db               |
      | conn_0 | False   | delete from session_connections_active_ratio where entry=1         | Access denied for table 'session_connections_active_ratio' | dble_information |
      | conn_0 | False   | update session_connections_active_ratio set entry=22 where entry=1 | Access denied for table 'session_connections_active_ratio' | dble_information |
      | conn_0 | True    | insert into session_connections_active_ratio (entry) values (22)   | Access denied for table 'session_connections_active_ratio' | dble_information |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     $a  -DenableSessionActiveRatioStat=0
     """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect        | db               |
      | conn_0 | true    | select * from dble_information.session_connections_active_ratio      | length{(0)}   | dble_information |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableSessionActiveRatioStat=0/-DenableSessionActiveRatioStat=1/g
     $a  -DusePerformanceMode=1
     """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect        | db               |
      | conn_0 | true    | select * from dble_information.session_connections_active_ratio      | length{(0)}   | dble_information |


    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableSessionActiveRatioStat=1/-DenableSessionActiveRatioStat=0/g
     s/-DusePerformanceMode=1/-DusePerformanceMode=0/g
     """
    Then restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect        | db               |
      | conn_0 | true    | select * from dble_information.session_connections_active_ratio      | length{(0)}   | dble_information |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableSessionActiveRatioStat=0/-DenableSessionActiveRatioStat=1/g
     """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect        | db               |
      | conn_1 | true    | select * from dble_information.session_connections_active_ratio      | length{(1)}   | dble_information |

# DBLE0REQ-2293
#    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
#     """
#     s/-DenableSessionActiveRatioStat=1/-DenableSessionActiveRatioStat=111/g
#     """
#    Then Restart dble in "dble-1" failed for
#     """
#     Property \[ enableFrontActiveRatioStat \] '111' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
#     """
#
#    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
#     """
#     s/-DenableSessionActiveRatioStat=111/-DenableSessionActiveRatioStat=abc/g
#     """
#    Then Restart dble in "dble-1" failed for
#     """
#     property \[ enableSessionActiveRatioStat \] 'abc' data type should be int
#     """
#
#    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
#     """
#     s/-DenableSessionActiveRatioStat=abc/-DenableSessionActiveRatioStat=null/g
#     """
#    Then Restart dble in "dble-1" failed for
#     """
#     property \[ enableSessionActiveRatioStat \] 'null' data type should be int
#     """