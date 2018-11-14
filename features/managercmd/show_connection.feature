# Created by maofei at 2018/11/6
Feature: #Enter feature name here
  # Enter feature description here

  Scenario: # show @@connection.sql
    # 1 the execute time of query <1ms
    # 2 the execute time of query >1ms
    # 3 multiple session query display
    # 4 multiple select executed query
    Given Restart dble in "dble-1" success
    #1
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose | sql                      | expect  | db       |
      | test  | 111111    | conn_0 | False   | select sleep(0.0001)   | success | mytest  |
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_A"
    Then check resultset "conn_rs_A" has lines with following column values
      | EXECUTE_TIME-5 | SQL-6                  |
      |    0+100         | select sleep(0.0001) |
    Given sleep "2" seconds
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_B"
    Then check resultset "conn_rs_B" has lines with following column values
      | EXECUTE_TIME-5 | SQL-6                  |
      |    0+100         | select sleep(0.0001) |
    #2
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose  | sql                      | expect  | db       |
      | test  | 111111    | conn_0 | False    | select sleep(0.1)      | success | mytest   |
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_C"
    Then check resultset "conn_rs_C" has lines with following column values
      | EXECUTE_TIME-5 | SQL-6                  |
      |    100+100      | select sleep(0.1)    |
    Given sleep "2" seconds
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_D"
    Then check resultset "conn_rs_D" has lines with following column values
      | EXECUTE_TIME-5 | SQL-6                  |
      |    100+100      | select sleep(0.1)    |
    #3
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose  | sql                      | expect  | db       |
      | test  | 111111    | conn_1 | False    | select sleep(1)        | success | mytest   |
    Then get resultset of admin cmd "show @@connection.sql" named "conn_rs_E"
    Then check resultset "conn_rs_E" has lines with following column values
      | EXECUTE_TIME-5 | SQL-6                 |
      |    100+100      | select sleep(0.1)    |
      |    1000+100     | select sleep(1)      |






