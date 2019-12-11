# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/12/11
Feature: test high-availability related commands
  ha related commands to test:
  dataHost @@disable name='xxx' [node='xxx']
  dataHost @@enable name='xxx' [node='xxx']
  dataHost @@switch name='xxx' master='xxx'
  show @@datasource

  @skip @after_reset_replication
  Scenario: end to end ha switch test
    Given a transaction in processing
    Given execute admin cmd "dataHost @@disable name='master1'"
    Then check transaction is killed forcely
    And dataHost config in schema.xml added attribute disabled=true
    And new query failed for "todo:dataSource is diabled xxxx"
    Then get resultset of admin cmd "show @@backend" named "show_be_rs"
    Then check resultset "show_be_rs" has not lines with following column values
    """
| HOST-3      | PORT-4 |
| 172.100.9.5 | 3306   |
  """
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    """
| DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4| ACTIVE-5| IDLE | SIZE | EXECUTE | READ_LOAD | WRITE_LOAD | DISABLED |
| ha_group1       | master1   | 172.100.9.6   | 3306   | W    |      0  |    0 |   50 |       0 |         0 |          0 | true     |
| dh01       | hostm1   | 172.100.9.5   | 3306   | W    |      1  |    0 |   50 |       1 |         0 |          0 | false    |
    """
    Given add xml segment to node with attribute "{'tag':'writeHost','kv_map':{'host':'master1'}}" in "<schema.xml>"
    """
    <readHost host="slave1" user="test" password="111111" url="172.100.9.2:3306" disabled="true"/>
    """
    Given execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    """
| DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R  | ACTIVE | IDLE | SIZE | EXECUTE | READ_LOAD | WRITE_LOAD | DISABLED |
| ha_group1       | master1   | 172.100.9.6   | 3306   | W    |      0 |    0 |   50 |       0 |         0 |          0 | true     |
| ha_group1       | slave1   | 172.100.9.2   | 3306   | R    |      0 |    0 |   50 |       1 |         0 |          0 | false    |
| dh01       | hostM1   | 172.100.9.5   | 3306   | W    |      1  |    0 |   50 |       1 |         0 |          0 | false    |
    """
    Given execute admin cmd "dataHost @@switch name='ha_group1' master='slave1'"
    Then check host "slave1" in schema.xml is "writeHost"
    And check host "master1" in schema.xml is "readHost"
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    """
| DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R  | ACTIVE | IDLE | SIZE | EXECUTE | READ_LOAD | WRITE_LOAD | DISABLED |
| ha_group1       | master1   | 172.100.9.6   | 3306   | R    |      0 |    0 |   50 |       0 |         0 |          0 | true     |
| ha_group1       | slave1   | 172.100.9.2   | 3306   | W    |      0 |    0 |   50 |       1 |         0 |          0 | true    |
"""
    Given execute admin cmd "dataHost @@enable name='ha_group1'"
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    """
| DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R  | ACTIVE | IDLE | SIZE | EXECUTE | READ_LOAD | WRITE_LOAD | DISABLED |
| ha_group1       | master1   | 172.100.9.6   | 3306   | R    |      0 |    0 |   50 |       0 |         0 |          0 | false     |
| ha_group1       | slave1   | 172.100.9.2   | 3306   | W    |      0 |    0 |   50 |       1 |         0 |          0 | false    |
"""
    Then check host "slave1" config in schema.xml added attribute "disabled=false"
    Then check host "master1" config in schema.xml added attribute "disabled=false"
    Given query a insert/read sql needs to use new master
    Then check query is send to new master
    Given execute admin cmd "dataHost @@disable name='ha_group1' node='slave1'"
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    """
| DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R  | ACTIVE | IDLE | SIZE | EXECUTE | READ_LOAD | WRITE_LOAD | DISABLED |
| ha_group1       | master1   | 172.100.9.6   | 3306   | R    |      0 |    0 |   50 |       0 |         0 |          0 | true     |
| ha_group1       | slave1   | 172.100.9.2   | 3306   | W    |      0 |    0 |   50 |       1 |         0 |          0 | false    |
"""
    Given execute admin cmd "dataHost @@switch name='ha_group1' master='master1'"
    Then Restart dble in "dble-1" success
    Then get resultset of admin cmd "show @@datasource" named "show_ds_rs"
    Then check resultset "show_ds_rs" has lines with following column values
    """
| DATAHOST-0 | NAME-1   | HOST-2        | PORT-3 | W/R  | ACTIVE | IDLE | SIZE | EXECUTE | READ_LOAD | WRITE_LOAD | DISABLED |
| ha_group1       | master1   | 172.100.9.6   | 3306   | R    |      0 |    0 |   50 |       0 |         0 |          0 | true     |
| ha_group1       | slave1   | 172.100.9.2   | 3306   | W    |      0 |    0 |   50 |       1 |         0 |          0 | false    |
"""