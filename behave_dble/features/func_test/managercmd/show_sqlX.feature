# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: show @@sql, show @@sql.resultset

  @NORMAL
  Scenario: show @@sql support queries of CRUD, show @@sql.resultset filters sql larger than maxResultSet setting #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <shardingTable shardingNode="dn1,dn2,dn3" name="ta" function="hash-three" shardingColumn="id"/>
    </schema>
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DmaxResultSet/d
    /DsqlRecordCount/a -DmaxResultSet=1024
    """
#    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
#    """
#    <system>
#        <property name="maxResultSet">1024</property>
#    </system>
#    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | db      |
      | conn_0 | False    | drop table if exists ta                    | schema1 |
      | conn_0 | False    | create table ta(id int,k varchar(1500))    | schema1 |
      | conn_0 | False    | insert into ta value(1, repeat('a', 1100)) | schema1 |
      | conn_0 | False    | insert into ta value(2, repeat('b', 1500)) | schema1 |
      | conn_0 | False    | insert into ta value(3, repeat('c', 100))  | schema1 |
      | conn_0 | False    | update ta set k="c" where id=3             | schema1 |
      | conn_0 | False    | select * from ta                           | schema1 |
      | conn_0 | False    | select * from ta order by id limit 1       | schema1 |
      | conn_0 | False    | select * from ta where id=2                | schema1 |
      | conn_0 | False    | delete from ta where id=1                  | schema1 |
      | conn_0 | True     | alter table ta drop column k               | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs_A"
      | sql        |
      | show @@sql |
    #username need to change as test while bug:DBLE0REQ-293 fixed
    Then check resultset "sql_rs_A" has lines with following column values
        | ID-0 | USER-1 | SQL-4                                      |
        |    1 | (test, )   | delete from ta where id=1                  |
        |    2 | (test, )   | SELECT * FROM ta WHERE id = 2 LIMIT 100    |
        |    3 | (test, )   | select * from ta order by id limit 1       |
        |    4 | (test, )   | SELECT * FROM ta LIMIT 100                 |
        |    5 | (test, )   | update ta set k="c" where id=3             |
        |    6 | (test, )   | insert into ta value(3, repeat('c', 100))  |
        |    7 | (test, )   | insert into ta value(2, repeat('b', 1500)) |
        |    8 | (test, )   | insert into ta value(1, repeat('a', 1100)) |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs_B"
      | sql                  |
      | show @@sql.resultset |
    Then check resultset "sql_rs_B" has lines with following column values
        | USER-1 | FREQUENCY-2 | SQL-3                                 | RESULTSET_SIZE-4 |
        | test   |         1   | SELECT * FROM ta ORDER BY id LIMIT ?  | 1185             |
        | test   |         1   | SELECT * FROM ta WHERE id = ? LIMIT ? | 1604             |

