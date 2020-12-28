# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_processor test

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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                             | expect            | db               |
      | conn_0 | False   | desc dble_processor             | length{(5)}       | dble_information |
      | conn_0 | False   | select * from dble_processor    | length{(9)}       | dble_information |
  #case select * from dble_processor
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | True    | select * from dble_processor | dble_information |
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
  #case change bootstrap.cnf to check result
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
     $a  -DbackendProcessors=4
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_processor_3"
      | conn   | toClose | sql                                  | db               |
      | conn_0 | false   | select name,type from dble_processor | dble_information |
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

   #case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                               | expect                                                                     |
      | conn_0 | False   | select name,type from dble_processor limit 1                      | has{(('frontProcessor0', 'session'),)}                                     |
      | conn_0 | False   | select name,type from dble_processor order by name desc limit 2   | has{(('frontProcessor0', 'session'), ('backendProcessor3', 'backend'))}    |
      | conn_0 | False   | select * from dble_processor where name like '%or%'               | length{(5)}                                                                |
  #case supported select max/min from
      | conn_0 | False   | select max(name) from dble_processor                      | has{(('frontProcessor0',),)}           |
      | conn_0 | False   | select min(name) from dble_processor                      | has{(('backendProcessor0',),)}         |
  #case supported where [sub-query]
      | conn_0 | False   | select name from dble_processor where type in (select type from dble_processor where conn_count>0) | length{(5)}    |
   #case supported select field from
      | conn_0 | False   | select name from dble_processor where conn_net_out > 0         | length{(5)}  |
  #case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_processor where name = 'frontProcessor0'            | Access denied for table 'dble_processor'  |
      | conn_0 | False   | update dble_processor set name = '2' where name = 'frontProcessor0'  | Access denied for table 'dble_processor'  |
      | conn_0 | True    | insert into dble_processor values ('1','2', 3, 4.5)                  | Access denied for table 'dble_processor'  |

