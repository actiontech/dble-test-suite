# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  version table test

 Scenario:  version table #1
  #case desc version
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_1"
      | conn   | toClose | sql                 | db               |
      | conn_0 | False   | desc version        | dble_information |
    Then check resultset "version_1" has lines with following column values
      | Field-0  | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | version  | varchar(64) | NO     | PRI   | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect           | db               |
      | conn_0 | False   | desc version             | length{(1)}      | dble_information |
      | conn_0 | False   | select * from version    | length{(1)}      | dble_information |
#case compare result select * from version and show @@version
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_2"
      | conn   | toClose | sql                   | db                |
      | conn_0 | False   | select * from version | dble_information  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "version_3"
      | conn   | toClose | sql                   | db               |
      | conn_0 | False   | show @@version        | dble_information |
    Then check resultsets "version_2" and "version_3" are same in following columns
      | column   | column_index |
      | version  | 0            |

   #case unsupported dml query
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                    | expect                                           | db               |
      | conn_0 | False   | select version from Version                                            | length{(1)}                                      | dble_information |
      | conn_0 | False   | update version set version='1' where version = (select * from version) | update syntax error, not support sub-query       | dble_information |
      | conn_0 | False   | delete from Version where version = (select * from version)            | delete syntax error, not support sub-query       | dble_information |
      | conn_0 | True    | insert into version values ('1')                                       | Access denied for table 'version'                | dble_information |


