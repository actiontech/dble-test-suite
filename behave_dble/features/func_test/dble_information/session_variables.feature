# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26


Feature:  session_variables test

  @skip_restart
   Scenario:  session_variables table #1
  #case desc session_variables
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_1"
      | conn   | toClose | sql                    | db               |
      | conn_0 | False   | desc session_variables | dble_information |
    Then check resultset "session_variables_1" has lines with following column values
      | Field-0         | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | session_conn_id | int(11)     | NO     | PRI   | None      |         |
      | variable_name   | varchar(12) | NO     | PRI   | None      |         |
      | variable_value  | varchar(12) | NO     |       | None      |         |
      | variable_type   | varchar(3)  | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect        | db               |
      | conn_0 | False   | desc session_variables             | length{(4)}   | dble_information |
      | conn_0 | False   | select * from session_variables    | length{(8)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from session_variables | dble_information |
    Then check resultset "session_variables_2" has lines with following column values
      | variable_name-1          | variable_value-2  | variable_type-3 |
      | autocommit               | true              | sys             |
      | character_set_client     | latin1            | sys             |
      | collation_connection     | latin1_swedish_ci | sys             |
      | character_set_results    | latin1            | sys             |
      | character_set_connection | latin1_swedish_ci | sys             |
      | transaction_isolation    | repeatable-read   | sys             |
      | transaction_read_only    | false             | sys             |
      | tx_read_only             | false             | sys             |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | use schema1                            | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_3"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from session_variables | dble_information |
    Then check resultset "session_variables_3" has lines with following column values
      | variable_name-1          | variable_value-2  | variable_type-3 |
      | autocommit               | true              | sys             |
      | character_set_client     | latin1            | sys             |
      | collation_connection     | latin1_swedish_ci | sys             |
      | character_set_results    | latin1            | sys             |
      | character_set_connection | latin1_swedish_ci | sys             |
      | transaction_isolation    | repeatable-read   | sys             |
      | transaction_read_only    | false             | sys             |
      | tx_read_only             | false             | sys             |
      | autocommit               | true              | sys             |
      | character_set_client     | latin1            | sys             |
      | collation_connection     | latin1_swedish_ci | sys             |
      | character_set_results    | latin1            | sys             |
      | character_set_connection | latin1_swedish_ci | sys             |
      | transaction_isolation    | repeatable-read   | sys             |
      | transaction_read_only    | false             | sys             |
      | tx_read_only             | false             | sys             |
      | xa                       | false             | sys             |
      | trace                    | false             | sys             |

#case set xa=on to check xa values
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | set autocommit=0                       | success |
      | conn_1 | False   | set xa=on                              | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_4"
      | conn   | toClose | sql                             | db               |
      | conn_0 | True    | select * from session_variables | dble_information |
    Then check resultset "session_variables_4" has lines with following column values
      | variable_name-1          | variable_value-2  | variable_type-3 |
      | autocommit               | false             | sys             |
      | character_set_client     | latin1            | sys             |
      | collation_connection     | latin1_swedish_ci | sys             |
      | character_set_results    | latin1            | sys             |
      | character_set_connection | latin1_swedish_ci | sys             |
      | transaction_isolation    | repeatable-read   | sys             |
      | transaction_read_only    | false             | sys             |
      | tx_read_only             | false             | sys             |
      | xa                       | true              | sys             |
      | trace                    | false             | sys             |
      | autocommit               | true              | sys             |
      | character_set_client     | latin1            | sys             |
      | collation_connection     | latin1_swedish_ci | sys             |
      | character_set_results    | latin1            | sys             |
      | character_set_connection | latin1_swedish_ci | sys             |
      | transaction_isolation    | repeatable-read   | sys             |
      | transaction_read_only    | false             | sys             |
      | tx_read_only             | false             | sys             |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | set autocommit=1                       | success |
      | conn_1 | True    | set xa=off                             | success |

    #case change transaction_isolation to check transaction_isolation values DBLE0REQ-562
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DtxIsolation=2
    $a -Dautocommit=0
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | use schema1                            | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_5"
      | conn   | toClose | sql                                                                                                        | db               |
      | conn_0 | False   | select * from session_variables where variable_name='transaction_isolation' or variable_name='autocommit'  | dble_information |
    Then check resultset "session_variables_5" has lines with following column values
      | variable_name-1       | variable_value-2 | variable_type-3 |
      | autocommit            | false            | sys             |
      | transaction_isolation | read-committed   | sys             |
      | autocommit            | false            | sys             |
      | transaction_isolation | read-committed   | sys             |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                             | expect  |
      | conn_1 | False   | SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                        | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_6"
      | conn   | toClose | sql                                                                         | db               |
      | conn_0 | False   | select * from session_variables where variable_name='transaction_isolation' | dble_information |
    Then check resultset "session_variables_6" has lines with following column values
      | variable_name-1          | variable_value-2  | variable_type-3 |
      | transaction_isolation    | read-uncommitted  | sys             |
      | transaction_isolation    | read-committed    | sys             |
  #case DBLE0REQ-563
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | expect                               |
      | conn_1 | False   | set @@tx_isolation=REPEATABLE-READ                                  | You have an error in your SQL syntax |
      | conn_1 | False   | set @@session.tx_isolation=REPEATABLE-READ                          | You have an error in your SQL syntax |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | expect  |
      | conn_1 | False   | set @@session.tx_isolation ='read-committed'                        | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_7"
      | conn   | toClose | sql                                                                         | db               |
      | conn_0 | False   | select * from session_variables where variable_name='transaction_isolation' | dble_information |
    Then check resultset "session_variables_7" has lines with following column values
      | variable_name-1          | variable_value-2  | variable_type-3 |
      | transaction_isolation    | read-committed    | sys             |
      | transaction_isolation    | read-committed    | sys             |
    Then check resultset "session_variables_7" has not lines with following column values
      | variable_name-1          | variable_value-2  | variable_type-3 |
      | transaction_isolation    | read-uncommitted  | sys             |

  #case  SET @@tx_read_only  or set @@session.transaction_read_only
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect  |
      | conn_1 | False   | set @@session.transaction_read_only=1 | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect  |
      | conn_2 | False   | use schema1                           | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_8"
      | conn   | toClose | sql                                                                                                         | db               |
      | conn_0 | False   | select * from session_variables where variable_name='transaction_read_only' or variable_name='tx_read_only' | dble_information |
    Then check resultset "session_variables_8" has lines with following column values
      | variable_name-1       | variable_value-2 | variable_type-3 |
      | transaction_read_only | true             | sys             |
      | tx_read_only          | true             | sys             |
      | transaction_read_only | false            | sys             |
      | tx_read_only          | false            | sys             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                  | expect  |
      | conn_1 | False   | SET @@tx_read_only=0 | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_9"
      | conn   | toClose | sql                                                                                                         | db               |
      | conn_0 | False   | select * from session_variables where variable_name='transaction_read_only' or variable_name='tx_read_only' | dble_information |
    Then check resultset "session_variables_9" has lines with following column values
      | variable_name-1       | variable_value-2 | variable_type-3 |
      | transaction_read_only | false            | sys             |
      | tx_read_only          | false            | sys             |
      | transaction_read_only | false            | sys             |
      | tx_read_only          | false            | sys             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                    |
      | conn_1 | False   | SET @@global.tx_read_only=1 | unsupport global          |

  #case  set @@character_set_results='utf8mb4'
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect  |
      | conn_1 | False   | set @@character_set_results='utf8mb4'  | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect  |
      | conn_2 | False   | set @@collation_connection='utf8_unicode_ci'   | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_10"
      | conn   | toClose | sql                                                                                                                 | db               |
      | conn_0 | False   | select * from session_variables where variable_name='character_set_results' or variable_name='collation_connection' | dble_information |
    Then check resultset "session_variables_10" has lines with following column values
      | variable_name-1       | variable_value-2  | variable_type-3 |
      | collation_connection  | latin1_swedish_ci | sys             |
      | character_set_results | latin1            | sys             |
      | collation_connection  | latin1_swedish_ci | sys             |
      | character_set_results | utf8mb4           | sys             |
      | collation_connection  | utf8_unicode_ci   | sys             |
      | character_set_results | latin1            | sys             |
  #case  set @a=1 to check variable_type='user'
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql         | expect  |
      | conn_1 | False   | set @a=1    | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql         | expect  |
      | conn_2 | False   | set @a=2    | success |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "session_variables_11"
      | conn   | toClose | sql                              | db               |
      | conn_0 | False   | select * from session_variables  | dble_information |
    Then check resultset "session_variables_11" has lines with following column values
      | variable_name-1       | variable_value-2  | variable_type-3 |
      | @A                    | 1                 | user            |
      | @A                    | 2                 | user            |

    #case unsupported update/delete/insert
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                            |
      | conn_0 | False   | delete from session_variables where variable_type='sys'                | Access denied for table 'session_variables'       |
      | conn_0 | False   | update session_variables set sys='user' where variable_type='sys'      | Access denied for table 'session_variables'       |
      | conn_0 | True    | insert into session_variables values ('a',1,2,3)                       | Access denied for table 'session_variables'       |