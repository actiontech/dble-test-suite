# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2022/5/24

Feature:test backend_connections_associate_thread   session_connections_associate_thread
#DBLE0REQ-1105


  Scenario: desc table and unsupported dml  #1

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                            | expect        | db               |
      | conn_0 | False   | desc backend_connections_associate_thread      | length{(2)}   | dble_information |
      | conn_0 | False   | desc session_connections_associate_thread      | length{(2)}   | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_1"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | desc backend_connections_associate_thread | dble_information |
    Then check resultset "table_1" has lines with following column values
      | Field-0          | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | backend_conn_id  | int(11)     | NO     | PRI   | None      |         |
      | thread_name      | varchar(64) | NO     |       | None      |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "table_2"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | desc session_connections_associate_thread | dble_information |
    Then check resultset "table_2" has lines with following column values
      | Field-0          | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | session_conn_id  | int(11)     | NO     | PRI   | None      |         |
      | thread_name      | varchar(64) | NO     |       | None      |         |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect                                                         | db               |
      | conn_0 | False   | delete from session_connections_associate_thread where session_conn_id=1         | Access denied for table 'session_connections_associate_thread' | dble_information |
      | conn_0 | False   | update session_connections_associate_thread set entry=22 where session_conn_id=1 | Access denied for table 'session_connections_associate_thread' | dble_information |
      | conn_0 | False   | insert into session_connections_associate_thread (session_conn_id) values (22)   | Access denied for table 'session_connections_associate_thread' | dble_information |

      | conn_0 | False   | delete from backend_connections_associate_thread where backend_conn_id=1         | Access denied for table 'backend_connections_associate_thread' | dble_information |
      | conn_0 | False   | update backend_connections_associate_thread set entry=22 where backend_conn_id=1 | Access denied for table 'backend_connections_associate_thread' | dble_information |
      | conn_0 | True    | insert into backend_connections_associate_thread (backend_conn_id) values (22)   | Access denied for table 'backend_connections_associate_thread' | dble_information |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect              | db               |
      | conn_0 | True    | select * from dble_variables where variable_name="enableConnectionAssociateThread"      | has{(('enableConnectionAssociateThread', 'true', 'Whether to open frontend connection and backend connection are associated with threads. The default value is 1.', 'true'),)}      | dble_information |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     $a -DenableConnectionAssociateThread=0
     """
    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                  | expect               | db               |
      | conn_0 | True    | select variable_value from dble_variables where variable_name="enableConnectionAssociateThread"      | has{(('false',),)}   | dble_information |

##111
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableConnectionAssociateThread=0/-DenableConnectionAssociateThread=111/g
     """
    Then Restart dble in "dble-1" failed for
     """
     Property \[ enableConnectionAssociateThread \] '111' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
     """
##
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableConnectionAssociateThread=111/-DenableConnectionAssociateThread=/g
     """
    Then Restart dble in "dble-1" failed for
     """
     Property \[ enableConnectionAssociateThread \] '' data type should be int
     """
##null
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableConnectionAssociateThread=/-DenableConnectionAssociateThread=null/g
     """
    Then Restart dble in "dble-1" failed for
     """
     Property \[ enableConnectionAssociateThread \] 'null' data type should be int
     """
##-1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableConnectionAssociateThread=null/-DenableConnectionAssociateThread=-1/g
     """
    Then Restart dble in "dble-1" failed for
     """
     Property \[ enableConnectionAssociateThread \] '-1' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
     """
##0.1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableConnectionAssociateThread=-1/-DenableConnectionAssociateThread=0.1/g
     """
    Then Restart dble in "dble-1" failed for
     """
     Property \[ enableConnectionAssociateThread \] '0.1' data type should be int
     """
##false
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     s/-DenableConnectionAssociateThread=0.1/-DenableConnectionAssociateThread=false/g
     """
    Then Restart dble in "dble-1" failed for
     """
     Property \[ enableConnectionAssociateThread \] 'false' data type should be int
     """
