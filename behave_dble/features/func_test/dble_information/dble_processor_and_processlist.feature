# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_processor test
@skip_restart
   Scenario:  dble_processor table #1
  #case desc dble_processor
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_1"
      | conn   | toClose | sql                 | db               |
      | conn_0 | False   | desc dble_processor | dble_information |
    Then check resultset "dble_processor_1" has lines with following column values
      | Field-0      | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name         | varchar(64) | NO     | PRI   | None      |         |
      | type         | varchar(7)  | NO     |       | None      |         |
      | conn_count   | int(11)     | NO     |       | None      |         |
      | conn_net_in  | int(11)     | NO     |       | None      |         |
      | conn_net_out | int(11)     | NO     |       | None      |         |
  #case select * from dble_processor
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select * from dble_processor | dble_information |
    Then check resultset "dble_processor_2" has lines with following column values
      | name-0            | type-1  |
      | frontProcessor0   | session |
      | backendProcessor0 | backend |
      | backendProcessor1 | backend |
      | backendProcessor2 | backend |
      | backendProcessor3 | backend |
      | backendProcessor4 | backend |
      | backendProcessor5 | backend |
      | backendProcessor6 | backend |
      | backendProcessor7 | backend |
  #case change bootstrap.cnf
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     $a  -DbackendProcessors=4
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_3"
      | conn   | toClose | sql                                  | db               |
      | conn_0 | true    | select name,type from dble_processor | dble_information |
    Then check resultset "dble_processor_3" has lines with following column values
      | name-0            | type-1  |
      | frontProcessor0   | session |
      | backendProcessor0 | backend |
      | backendProcessor1 | backend |
      | backendProcessor2 | backend |
      | backendProcessor3 | backend |
    Then check resultset "dble_processor_3" has not lines with following column values
      | name-0            | type-1  |
      | backendProcessor4 | backend |
      | backendProcessor5 | backend |
      | backendProcessor6 | backend |
      | backendProcessor7 | backend |

   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                               | expect                                                                     |
      | conn_2 | False   | use dble_information                                              | success                                                                    |
      | conn_2 | False   | select name,type from dble_processor limit 1                      | has{(('frontProcessor0', 'session'),)}                                     |
      | conn_2 | False   | select name,type from dble_processor order by name desc limit 2   | has{(('frontProcessor0', 'session'), ('backendProcessor3', 'backend'))}    |
      | conn_2 | False   | select * from dble_processor where name like '%or%'               | length{(5)}                                                                |
  #case select max/min from
      | conn_2 | False   | select max(name) from dble_processor                      | has{(('frontProcessor0',),)}           |
      | conn_2 | False   | select min(name) from dble_processor                      | has{(('backendProcessor0',),)}         |
  #case where [sub-query]
#      | conn_0 | False   | select name from dble_processor where type in (select type from dble_processor where conn_count>1) | has{(('BusinessExecutor', 1, 1, 0), ('backendBusinessExecutor', 8, 0, 0))}     |
   #case select field from
#      | conn_2 | False   | select name from dble_processor where conn_net_out > 1         | has{('BusinessExecutor'),('complexQueryExecutor'),('writeToBackendExecutor')}                                    |
  #case update/delete
      | conn_2 | False   | delete from dble_processor where name = 'frontProcessor0'            | Access denied for table 'dble_processor'                                                                                                        |
      | conn_2 | False   | update dble_processor set name = '2' where name = 'frontProcessor0'  | Access denied for table 'dble_processor'                                                                                                        |
      | conn_2 | False   | insert into dble_processor values ('1','2', 3, 4.5)                  | update syntax error, not support insert with syntax :[LOW_PRIORITY \| DELAYED \| HIGH_PRIORITY] [IGNORE][ON DUPLICATE KEY UPDATE assignment_list]  |


#@skip_restart
     Scenario:  processlist  table #2
  #case desc processlist
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "processlist_1"
      | conn   | toClose | sql              | db               |
      | conn_0 | False   | desc processlist | dble_information |
    Then check resultset "processlist_1" has lines with following column values
      | Field-0          | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |