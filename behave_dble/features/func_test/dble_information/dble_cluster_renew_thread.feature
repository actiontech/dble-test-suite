# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2022/5/24

Feature:test dble_cluster_renew_thread
#DBLE0REQ-1555

  Scenario: desc table and unsupported dml  #1

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                 | expect        | db               |
      | conn_0 | False   | desc dble_cluster_renew_thread      | length{(1)}   | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_1"
      | conn   | toClose | sql                                | db               |
      | conn_0 | False   | desc dble_cluster_renew_thread     | dble_information |
    Then check resultset "table_1" has lines with following column values
      | Field-0          | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | renew_thread     | varchar(200) | NO     |       | None      |         |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect                                              | db               |
      | conn_0 | False   | delete from dble_cluster_renew_thread where renew_thread=1           | Access denied for table 'dble_cluster_renew_thread' | dble_information |
      | conn_0 | False   | update dble_cluster_renew_thread set entry=22 where renew_thread=1   | Access denied for table 'dble_cluster_renew_thread' | dble_information |
      | conn_0 | True    | insert into dble_cluster_renew_thread (renew_thread) values (22)     | Access denied for table 'dble_cluster_renew_thread' | dble_information |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                         | expect                       | db               |
      | conn_0 | False   | select * from dble_cluster_renew_thread     | length{(0)}                  | dble_information |
      | conn_0 | False   | kill @@cluster_renew_thread 'threadName'    | wrong cluster renew thread!  | dble_information |


    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      NullPointerException
      caught err:
      exception occurred
      Exception processing
      """
