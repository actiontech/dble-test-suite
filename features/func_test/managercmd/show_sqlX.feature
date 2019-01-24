Feature: show @@sql, show @@sql.resultset

  @NORMAL
  Scenario: show @@sql support queries of CRUD, show @@sql.resultset filters sql larger than maxResultSet setting
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
        <table dataNode="dn1,dn2,dn3" name="ta" rule="hash-three" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="maxResultSet">1024</property>
    </system>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                        | expect     | db     |
        | test | 111111 | conn_0 | False    | drop table if exists ta                    | success    | schema1 |
        | test | 111111 | conn_0 | False    | create table ta(id int,k varchar(1500))    | success    | schema1 |
        | test | 111111 | conn_0 | False    | insert into ta value(1, repeat('a', 1100)) | success    | schema1 |
        | test | 111111 | conn_0 | False    | insert into ta value(2, repeat('b', 1500)) | success    | schema1 |
        | test | 111111 | conn_0 | False    | insert into ta value(3, repeat('c', 100))  | success    | schema1 |
        | test | 111111 | conn_0 | False    | update ta set k="c" where id=3             | success    | schema1 |
        | test | 111111 | conn_0 | False    | select * from ta                           | success    | schema1 |
        | test | 111111 | conn_0 | False    | select * from ta order by id limit 1       | success    | schema1 |
        | test | 111111 | conn_0 | False    | select * from ta where id=2                | success    | schema1 |
        | test | 111111 | conn_0 | False    | delete from ta where id=1                  | success    | schema1 |
        | test | 111111 | conn_0 | True     | alter table ta drop column k               | success    | schema1 |
    Then get resultset of admin cmd "show @@sql" named "sql_rs_A"
    Then check resultset "sql_rs_A" has lines with following column values
        | ID-0 | USER-1 | SQL-4                                      |
        |    1 | test   | delete from ta where id=1                  |
        |    2 | test   | SELECT * FROM ta WHERE id = 2 LIMIT 100    |
        |    3 | test   | select * from ta order by id limit 1       |
        |    4 | test   | SELECT * FROM ta LIMIT 100                 |
        |    5 | test   | update ta set k="c" where id=3             |
        |    6 | test   | insert into ta value(3, repeat('c', 100))  |
        |    7 | test   | insert into ta value(2, repeat('b', 1500)) |
        |    8 | test   | insert into ta value(1, repeat('a', 1100)) |
    Then get resultset of admin cmd "show @@sql.resultset" named "sql_rs_B"
    Then check resultset "sql_rs_B" has lines with following column values
        | USER-1 | FREQUENCY-2 | SQL-3                                 | RESULTSET_SIZE-4 |
        | test   |         1   | SELECT * FROM ta ORDER BY id LIMIT ?  | 1183             |
        | test   |         1   | SELECT * FROM ta WHERE id = ? LIMIT ? | 1604             |
    Given delete the following xml segment
      |file        | parent           | child             |
      |server.xml  |{'tag':'root'}    | {'tag':'system'}  |
