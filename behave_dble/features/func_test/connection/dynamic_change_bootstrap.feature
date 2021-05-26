# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/05/25

Feature: Dynamically adjust parameters on bootstrap use "update dble_thread_pool"

  processors、backendProcessors、processorExecutor、backendProcessorExecutor、complexExecutor、writeToBackendExecutor

@skip_restart
  Scenario: basic test about 'update'  #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     $a  -DbackendProcessorExecutor=1
     $a  -DwriteToBackendExecutor=1
     $a  -DbackendProcessors=1
     $a  -DcomplexExecutor=2
    """
    Then restart dble in "dble-1" success
    # keepAlivetime is 60s, 'complexExecutor' heartbeat and 9066 cmd would use it
    Given sleep "60" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_thread_pool_1"
      | conn   | toClose | sql                            | db                |
      | conn_0 | False   | select * from dble_thread_pool | dble_information  |
    Then check resultset "dble_thread_pool_1" has lines with following column values
      | name-0                  | pool_size-1 | core_pool_size-2 | active_count-3 | waiting_task_count-4 |
      | Timer                   | 1           | 1                | 0              | 0                    |
      | BusinessExecutor        | 1           | 1                | 1              | 0                    |
      | backendBusinessExecutor | 1           | 1                | 0              | 0                    |
      | complexQueryExecutor    | 2           | 2                | 1              | 0                    |
      | writeToBackendExecutor  | 1           | 1                | 1              | 0                    |
      | $_NIO_REACTOR_FRONT-    | 1           | 1                | 1              | 0                    |
      | $_NIO_REACTOR_BACKEND-  | 1           | 1                | 1              | 0                    |
    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty
    #unsupported insert and delete
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                        | expect             | db               |
      | conn_0 | False   | insert into dble_thread_pool values ('aa',1,1,1,1)         | not support insert | dble_information |
      | conn_0 | False   | delete from dble_thread_pool where name='BusinessExecutor' | not support delete | dble_information |
    #unsupported update illegal number
      | conn_0 | False   | update dble_thread_pool set core_pool_size=0 where name ='$_NIO_REACTOR_FRONT-' | Column 'core_pool_size' can not be empty or '0' | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=0.5 where name ='$_NIO_REACTOR_FRONT-' | Not Supported of Value EXPR :0.5 | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='null' where name ='$_NIO_REACTOR_FRONT-' | unknown error:For input string: "null" | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=null where name ='$_NIO_REACTOR_FRONT-' | Column 'core_pool_size' cannot be null | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='afr' where name ='$_NIO_REACTOR_FRONT-' | unknown error:For input string: "afr" | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size=' ' where name ='$_NIO_REACTOR_FRONT-' | Column 'core_pool_size' can not be empty or '0' | dble_information |
      | conn_0 | False   | update dble_thread_pool set core_pool_size='-1' where name ='$_NIO_REACTOR_FRONT-' | unknown error:null | dble_information |

    Then check "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" was empty












