# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_db_group test

   Scenario:  dble_db_group table #1
  #case desc dble_db_group
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | desc dble_db_group      | dble_information |
    Then check resultset "dble_db_group_1" has lines with following column values
      | Field-0           | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name              | varchar(64) | NO     | PRI   | None      |         |
      | heartbeat_stmt    | varchar(64) | NO     |       | None      |         |
      | heartbeat_timeout | int(11)     | YES    |       | 0         |         |
      | heartbeat_retry   | int(11)     | YES    |       | 1         |         |
      | rw_split_mode     | int(11)     | NO     |       | None      |         |
      | delay_threshold   | int(11)     | YES    |       | -1        |         |
      | disable_ha        | varchar(5)  | YES    |       | false     |         |
      | active            | varchar(5)  | YES    |       | false     |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                            | expect            | db               |
      | conn_0 | False   | desc dble_db_group             | length{(8)}       | dble_information |
      | conn_0 | False   | select * from dble_db_group    | length{(2)}       | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_2"
      | conn   | toClose | sql                         | db               |
      | conn_0 | False   | select * from dble_db_group | dble_information |
    Then check resultset "dble_db_group_2" has lines with following column values
      | name-0    | heartbeat_stmt-1 | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
      | ha_group1 | select user()    | 0                   | 1                 | 0               | 100               | false        | true     |
      | ha_group2 | select user()    | 0                   | 1                 | 0               | 100               | false        | true     |
  #case change db.xml and reload
    Given delete the following xml segment
      | file           | parent         | child                       |
      | db.xml         | {'tag':'root'} | {'tag':'dbGroup'}           |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_1" disableHA="true" >
        <heartbeat errorRetryCount="0" timeout="100">show slave status</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="2" name="ha_2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_3" delayThreshold="1000" >
        <heartbeat>select @@read_only</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_3"
      | conn   | toClose | sql                         | db               |
      | conn_0 | False   | select * from dble_db_group | dble_information |
    Then check resultset "dble_db_group_3" has lines with following column values
      | name-0 | heartbeat_stmt-1   | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
      | ha_1   | show slave status  | 100                 | 0                 | 1               | -1                | true         | true     |
      | ha_2   | select user()      | 0                   | 1                 | 2               | 100               | false        | true     |
      | ha_3   | select @@read_only | 0                   | 1                 | 0               | 1000              | false        | true     |

  #case supported select limit/order by
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                          | expect                                                                                                                               |
      | conn_0 | False   | select * from dble_db_group limit 1                          | has{(('ha_1', 'show slave status', 100, 0, 1, -1, 'true', 'true'),)}                                                                 |
      | conn_0 | False   | select * from dble_db_group order by name desc limit 2       | has{(('ha_3', 'select @@read_only', 0, 1, 0, 1000, 'false', 'true'), ('ha_2', 'select user()', 0, 1, 2, 100, 'false', 'true'))}      |
  #case supported select max/min
      | conn_0 | False   | select max(delay_threshold) from dble_db_group         | has{((1000,),)}      |
      | conn_0 | False   | select min(delay_threshold) from dble_db_group         | has{((-1,),)}        |
  #case supported select where like
      | conn_0 | False   | select * from dble_db_group where heartbeat_stmt ='show slave status'      | has{(('ha_1', 'show slave status', 100, 0, 1, -1, 'true', 'true'),)}         |
      | conn_0 | False   | select * from dble_db_group where name like '%ha%'                         | length{(3)}                                                                  |
  #case supported select where [sub-query]
      | conn_0 | False   | select * from dble_db_group where name in (select db_group from dble_db_instance) and rw_split_mode=0     | has{(('ha_3', 'select @@read_only', 0, 1, 0, 1000, 'false', 'true'))}                                                             |
      | conn_0 | False   | select * from dble_db_group where name >all (select db_group from dble_db_instance)                       | length{(0)}                                                                                                                       |
      | conn_0 | False   | select * from dble_db_group where name < any (select db_group from dble_db_instance)                      | has{(('ha_1', 'show slave status', 100, 0, 1, -1, 'true', 'true'), ('ha_2', 'select user()', 0, 1, 2, 100, 'false', 'true'))}     |
      | conn_0 | False   | select * from dble_db_group where name = any (select db_group from dble_db_instance)                      | length{(3)}                                                                                                                       |
   #case supported select field
      | conn_0 | False   | select a.name,a.heartbeat_stmt,b.db_group from dble_db_group a inner join dble_db_instance b on a.name=b.db_group where a.heartbeat_retry = 0     | has{(('ha_1', 'show slave status', 'ha_1',))}                           |
      | conn_0 | False   | select * from dble_db_group where name in (select db_group from dble_db_instance where name ='hostM1')                                            | has{(('ha_1', 'show slave status', 100, 0, 1, -1, 'true', 'true'))}     |
      | conn_0 | True    | select name,heartbeat_stmt from dble_db_group where rw_split_mode > 0                                                                             | has{(('ha_1', 'show slave status',),('ha_2', 'select user()',))}        |
