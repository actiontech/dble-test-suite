Feature:
 @smoke
    Scenario: set backend mysql lower_case_table_names=0, dble will deal with queries case insensitive  #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema name="DBTEST">
            <table name="Test_Table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
        </schema>
    """
    Given delete the following xml segment
      |file        | parent           | child          |
      |server.xml  | {'tag':'root'}   | {'tag':'root'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
      <user name="root">
        <property name="password">111111</property>
        <property name="manager">true</property>
      </user>
      <user name="test">
        <property name="password">111111</property>
        <property name="schemas">schema1, DbTest</property>
      </user>
    """
    Then restart dble in "dble-1" failed for
    """
    schema DbTest referred by user test is not exist!
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema name="DbTest">
            <table name="Test_Table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
        </schema>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                              | expect                 | db     |
        | test | 111111 | conn_0 | True    |                                                                                   | Unknown database 'DBTest'     | DBTest |
        | test | 111111 | conn_0 | False   | drop table if exists Test_Table                                              | success               | DbTest |
        | test | 111111 | conn_0 | False   | create table TEst_Table(id int)                                              | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | False   | create table Test_Table(id int)                                              | success               | DbTest |
        | test | 111111 | conn_0 | False   | insert into test_table value(1)                                              | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | False   | insert into Test_Table value(1)                                              | success               | DbTest |
        | test | 111111 | conn_0 | False   | select test_table.id from Test_Table                                        | Unknown column       | DbTest |
        | test | 111111 | conn_0 | False   | select Test_Table.id from test_table                                        | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | False   | select Test_Table.id from test_table                                        | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | False   | use dbtest                                                                      | Unknown database     | DbTest |
        | test | 111111 | conn_0 | False   | select dbtest.test_table.id from dbtest.test_table                        | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | True    | select DbTest.Test_Table.id from DbTest.Test_Table                        | success                | DbTest |
        | test | 111111 | conn_1 | False   | drop table if exists Test                                                     | success               | schema1 |
        | test | 111111 | conn_1 | False   | drop table if exists test                                                     | success               | schema1 |
        | test | 111111 | conn_1 | False   | create table test(Id int)                                                     | success               | schema1 |
        | test | 111111 | conn_1 | False   | insert into test(id) value(2)                                                 | success              | schema1 |
        | test | 111111 | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join Test t2 on t1.id=t2.Id |Test doesn't exist | schema1 |
        | test | 111111 | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join test t2 on t1.id=t2.Id |Unknown column      | schema1 |
        | test | 111111 | conn_1 | False   | select T1.id from DbTest.Test_Table T1 left join test t2 on T1.id=t2.id |success              | schema1 |
        | test | 111111 | conn_1 | False   | select distinct(t1.id) from DbTest.Test_Table t1 limit 2                  |success              | schema1 |
        | test | 111111 | conn_1 | False   | select DISTINCT(T1.id) from DbTest.Test_Table t1 limit 2                  |Unknown column      | schema1 |
        | test | 111111 | conn_1 | False   | select avg(t1.id),t1.id from DbTest.Test_Table t1,test t2 where t1.id=t2.id and t1.id = 1 group by t1.id having avg(t1.id)>(select sum(t1.id)/count(t1.id) from DbTest.Test_Table t1) |success | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table s,test t where s.id = t.Id or s.Id <s.id  or s.id >t.Id |success               | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table S,Test t where s.id = t.id or s.id <s.id  or s.id >t.id |Test doesn't exist  | schema1 |
#        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table S,test t where s.id = t.id or s.id <s.id  or s.id >t.id |error totally whack | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from DbTest.Test_Table s union (select Id from test)          |success               | schema1 |
        | test | 111111 | conn_1 | True    |select s.id from DbTest.Test_Table S union (select id from Test)          |Test doesn't exist  | schema1 |
#        | test | 111111 | conn_1 | True    |select s.id from DbTest.Test_Table S union (select id from test)          |error totally whack | schema1 |