# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/4/26

Feature: check sql plan

  # DBLE0REQ-1672 and DBLE0REQ-1427
  Scenario: check sql plan:  sharding column use `, table use alias and where condition does not use table alias #1

    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                             | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(10))                             | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs1"
      | conn   | toClose | sql                                            | expect      | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where id=1 | length{(1)} | schema1 |
    Then check resultset "rs1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                              |
      | dn2             | BASE SQL | select * from sharding_4_t1 where id=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs2"
      | conn   | toClose | sql                                              | expect      | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 where `id`=1 | length{(1)} | schema1 |
    Then check resultset "rs2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                 |
      | dn2             | BASE SQL | select * from sharding_4_t1 where `id`=1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs3"
      | conn   | toClose | sql                                                    | expect      | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 t1 where id=1      | length{(1)} | schema1 |
    Then check resultset "rs3" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                  |
      | dn2             | BASE SQL | select * from sharding_4_t1 t1 where id=1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs4"
      | conn   | toClose | sql                                                    | expect  | db      |
      | conn_1 | False   | explain select * from sharding_4_t1 t1 where `id`=1    | length{(1)} | schema1 |
    Then check resultset "rs4" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                   |
      | dn2             | BASE SQL | select * from sharding_4_t1 t1 where `id`=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs5"
      | conn   | toClose | sql                                                            | expect      | db      |
      | conn_1 | False   | explain select * from schema1.sharding_4_t1 t1 where t1.`id`=1 | length{(1)} | schema1 |
    Then check resultset "rs5" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                      |
      | dn2             | BASE SQL | select * from sharding_4_t1 t1 where t1.`id`=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs6"
      | conn   | toClose | sql                                                      | expect      | db      |
      | conn_1 | False   | explain select * from schema1.sharding_4_t1 where `id`=1 | length{(1)} | schema1 |
    Then check resultset "rs6" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                 |
      | dn2             | BASE SQL |  select * from sharding_4_t1 where `id`=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs7"
      | conn   | toClose | sql                                                         | expect      | db      |
      | conn_1 | False   | explain select * from schema1.sharding_4_t1 t1 where `id`=1 | length{(1)} | schema1 |
    Then check resultset "rs7" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                   |
      | dn2             | BASE SQL | select * from sharding_4_t1 t1 where `id`=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs8"
      | conn   | toClose | sql                                                       | expect      | db      |
      | conn_1 | False   | explain select * from schema1.sharding_4_t1 t1 where id=1 | length{(1)} | schema1 |
    Then check resultset "rs8" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                 |
      | dn2             | BASE SQL | select * from sharding_4_t1 t1 where id=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs9"
      | conn   | toClose | sql                                                               | expect      | db      |
      | conn_1 | False   | explain update schema1.sharding_4_t1 set name='test' where `id`=1 | length{(1)} | schema1 |
    Then check resultset "rs9" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                         |
      | dn2             | BASE SQL | update sharding_4_t1 set name='test' where `id`=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs10"
      | conn   | toClose | sql                                                                  | expect      | db      |
      | conn_1 | False   | explain update schema1.sharding_4_t1 t1 set name='test' where `id`=1 | length{(1)} | schema1 |
    Then check resultset "rs10" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                             |
      | dn2             | BASE SQL | update sharding_4_t1 t1 set name='test' where `id`=1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs11"
      | conn   | toClose | sql                                                     | expect      | db      |
      | conn_1 | False   | explain update sharding_4_t1 set name='test' where id=1 | length{(1)} | schema1 |
    Then check resultset "rs11" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                       |
      | dn2             | BASE SQL | update sharding_4_t1 set name='test' where id=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs12"
      | conn   | toClose | sql                                                       | expect      | db      |
      | conn_1 | False   | explain update sharding_4_t1 set name='test' where `id`=1 | length{(1)} | schema1 |
    Then check resultset "rs12" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                         |
      | dn2             | BASE SQL | update sharding_4_t1 set name='test' where `id`=1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs13"
      | conn   | toClose | sql                                                          | expect      | db      |
      | conn_1 | False   | explain update sharding_4_t1 t1 set name='test' where `id`=1 | length{(1)} | schema1 |
    Then check resultset "rs13" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                            |
      | dn2             | BASE SQL | update sharding_4_t1 t1 set name='test' where `id`=1 |

    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_1 | True    | drop table if exists sharding_4_t1 | success | schema1 |

  # DBLE0REQ-1613
  Scenario: check single table sql plan #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="single_t1" shardingNode="dn1"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_1 | False   | drop table if exists single_t1                      | success | schema1 |
      | conn_1 | False   | create table single_t1(id int,name varchar(10))     | success | schema1 |
      | conn_1 | False   | insert into single_t1 values(1,'name1'),(2,'name2') | success | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs1"
      | conn   | toClose | sql                                              | expect      | db      |
      | conn_1 | False   | explain select * from single_t1                  | length{(1)} | schema1 |
    Then check resultset "rs1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                         |
      | dn1             | BASE SQL | SELECT * FROM single_t1 LIMIT 100 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs2"
      | conn   | toClose | sql                                                  | expect      | db      |
      | conn_1 | False   | explain select a.* from single_t1 a, (select 1) as b | length{(1)} | schema1 |
    Then check resultset "rs2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                         |
      | dn1             | BASE SQL | SELECT a.* FROM single_t1 a, (   SELECT 1  ) b LIMIT 100 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs3"
      | conn   | toClose | sql                                                      | expect      | db      |
      | conn_1 | False   | explain select a.* from single_t1 a join (select 1) as b | length{(1)} | schema1 |
    Then check resultset "rs3" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                     |
      | dn1             | BASE SQL | SELECT a.* FROM single_t1 a  JOIN (   SELECT 1  ) b LIMIT 100 |
      Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect  | db      |
      | conn_1 | True    | drop table if exists single_t1 | success | schema1 |

  # DBLE0REQ-1610
  @delete_mysql_tables
  Scenario: When the subquery is right join, the result of the query is incorrect   #3
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2'], 'mysql-master2': ['db1', 'db2'], 'mysql':['schema1']}}
  """
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1"  sqlMaxLimit="100">
          <shardingTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="tabler" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="tabler2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="tabler3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        </schema>
      """
    Given execute admin cmd "reload @@config_all" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                   | db      | expect  |
      | conn_0 | false   | drop table if exists test_shard                                                       | schema1 | success |
      | conn_0 | false   | drop table if exists tabler                                                           | schema1 | success |
      | conn_0 | false   | drop table if exists tabler2                                                          | schema1 | success |
      | conn_0 | false   | drop table if exists tabler3                                                          | schema1 | success |
      | conn_0 | false   | create table tabler(id int,name varchar(50), test_id int);                            | schema1 | success |
      | conn_0 | false   | create table tabler2(id int,name varchar(50), test_id int);                           | schema1 | success |
      | conn_0 | false   | create table tabler3(id int,name varchar(50), test_id int);                           | schema1 | success |
      | conn_0 | false   | create table test_shard(id int,name varchar(50), age int);                            | schema1 | success |
      | conn_0 | false   | insert into tabler values(1,'L',6),(2,'D',5),(3,'P',1),(4,'C',3),(5,'M',4),(6,'D',2); | schema1 | success |
      | conn_0 | false   | insert into tabler2 values(1,'D',3),(2,'D',6),(2,'F',7),(7,'F',4);                    | schema1 | success |
      | conn_0 | false   | insert into tabler3 values(1,'D',8),(2,'D',6),(2,'F',7),(7,'F',4);                    | schema1 | success |
      | conn_0 | true    | insert into test_shard values(6,'Y',99),(7,'X',100),(8,'Z',101);                      | schema1 | success |

    #create table used in comparing mysql
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                   | db      | expect  |
      | conn_0 | false   | create table tabler(id int,name varchar(50), test_id int);                            | schema1 | success |
      | conn_0 | false   | create table tabler2(id int,name varchar(50), test_id int);                           | schema1 | success |
      | conn_0 | false   | create table tabler3(id int,name varchar(50), test_id int);                           | schema1 | success |
      | conn_0 | false   | create table test_shard(id int,name varchar(50), age int);                            | schema1 | success |
      | conn_0 | false   | insert into tabler values(1,'L',6),(2,'D',5),(3,'P',1),(4,'C',3),(5,'M',4),(6,'D',2); | schema1 | success |
      | conn_0 | false   | insert into tabler2 values(1,'D',3),(2,'D',6),(2,'F',7),(7,'F',4);                    | schema1 | success |
      | conn_0 | false   | insert into tabler3 values(1,'D',8),(2,'D',6),(2,'F',7),(7,'F',4);                    | schema1 | success |
      | conn_0 | true    | insert into test_shard values(6,'Y',99),(7,'X',100),(8,'Z',101);                      | schema1 | success |

    # one right join in subquery
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                        | db      |
      | conn_0 | true    | select * from test_shard where id in(select b.test_id from tabler a right join tabler2 b on a.name = b.name and a.id = 2); | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                       | db      |
      | conn_0 | true    | select * from test_shard where id in(select b.test_id from tabler a right join tabler2 b on a.name = b.name and a.id = 2 where b.id = 2); | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                        | db      |
      | conn_0 | true    | select * from test_shard where id in(select b.test_id from tabler a right join tabler2 b on a.name = b.name and b.id = 2); | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                          | db      |
      | conn_0 | true    | select * from test_shard where id in(select b.test_id from tabler a right join tabler2 b on a.name = b.name where b.id = 2); | schema1 |
    # two right join in subquery
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                      | db      |
      | conn_0 | true    | select * from test_shard where id in(select c.test_id from tabler a right join tabler2 b on a.name = b.name and a.id = 2 right join tabler3 c on b.test_id = c.test_id); | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                      | db      |
      | conn_0 | true    | select * from test_shard where id in(select c.test_id from tabler a right join tabler2 b on a.name = b.name right join tabler3 c on b.test_id = c.test_id and a.id = 2); | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                      | db      |
      | conn_0 | true    | select * from test_shard where id in(select c.test_id from tabler a right join tabler2 b on a.name = b.name and b.id = 2 right join tabler3 c on b.test_id = c.test_id); | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                      | db      |
      | conn_0 | true    | select * from test_shard where id in(select c.test_id from tabler a right join tabler2 b on a.name = b.name right join tabler3 c on b.test_id = c.test_id and c.id = 2); | schema1 |

  # DBLE0REQ-1661
  @delete_mysql_tables
  Scenario: 3 ER relationships, A left join B inner join C, the query result is wrong   #4
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
  """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
            <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Level" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="levelid"/>
        </schema>

        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
        <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />

        <function name="func_hashString" class="StringHash">
            <property name="partitionCount">2</property>
            <property name="partitionLength">1</property>
            <property name="hashSlice">0:2</property>
        </function>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | false   | drop table if exists Employee                                                                                                                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | drop table if exists Dept                                                                                                                                                                                                                                                                                         | schema1 | success |
      | conn_0 | false   | drop table if exists Info                                                                                                                                                                                                                                                                                         | schema1 | success |
      | conn_0 | false   | drop table if exists Level                                                                                                                                                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

     #create table used in comparing mysql
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                              | db      |
      | conn_0 | false   | explain SELECT * FROM Employee a left join Dept b on a.deptname=b.deptname inner join Info c on a.deptname=c.deptname and b.DeptName=c.DeptName order by a.Name; | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                           |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                      | db      |
      | conn_0 | true    | SELECT * FROM Employee a left join Dept b on a.deptname=b.deptname inner join Info c on a.deptname=c.deptname and b.DeptName=c.DeptName order by a.Name; | schema1 |
    # append sql
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                                                              | db      |
      | conn_0 | false   | explain SELECT * FROM Employee a left join Dept b on a.deptname=b.deptname inner join Info c on b.deptName=c.deptName and a.deptname=c.deptname order by a.Name; | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                           |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptName` = `c`.`deptName` and `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptName` = `c`.`deptName` and `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                      | db      |
      | conn_0 | true    | SELECT * FROM Employee a left join Dept b on a.deptname=b.deptname inner join Info c on b.deptName=c.deptName and a.deptname=c.deptname order by a.Name; | schema1 |

  # DBLE0REQ-1504
  @delete_mysql_tables
  Scenario: The parentheses of the or condition are missing, thus changing the semantics of the condition and eventually causing duplication of results   #5
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
  """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                            | db      | expect  |
      | conn_0 | false   | drop table if exists test                                                                                                                                                                                                                                                                                      | schema1 | success |
      | conn_0 | false   | drop table if exists sharding_2_t1                                                                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | create table test (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8;                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table sharding_2_t1(levelname varchar(250) not null,id int not null,salary int not null)engine=innodb charset=utf8;                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | insert into test values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8'); | schema1 | success |
      | conn_0 | true    | insert into sharding_2_t1 values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000);                                                                                                                                                                                                                 | schema1 | success |

     #create table used in comparing mysql
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                           | db      | expect  |
      | conn_0 | false   | drop table if exists test                                                                                                                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | drop table if exists sharding_2_t1                                                                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table test (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table sharding_2_t1(levelname varchar(250) not null,id int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | insert into test values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | true    | insert into sharding_2_t1 values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                 | schema1 | success |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain SELECT a.Name,a.DeptName,c.levelname,c.salary FROM test a inner JOIN sharding_2_t1 c on c.levelname=a.level and (c.levelname='P7' or (c.salary >=10000 and 22000>=c.salary)) order by a.name; | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                           |
      | dn1_0             | BASE SQL        | select `a`.`Name`,`a`.`DeptName`,`c`.`levelname`,`c`.`salary` from  `test` `a` join  `sharding_2_t1` `c` on `a`.`level` = `c`.`levelname` and (c.salary >= 10000 AND c.salary <= 22000 OR c.levelname IN ('P7')) where 1=1  ORDER BY `a`.`Name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`Name`,`a`.`DeptName`,`c`.`levelname`,`c`.`salary` from  `test` `a` join  `sharding_2_t1` `c` on `a`.`level` = `c`.`levelname` and (c.salary >= 10000 AND c.salary <= 22000 OR c.levelname IN ('P7')) where 1=1  ORDER BY `a`.`Name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | true    | SELECT a.Name,a.DeptName,c.levelname,c.salary FROM test a inner JOIN sharding_2_t1 c on c.levelname=a.level and (c.levelname='P7' or (c.salary >=10000 and 22000>=c.salary)) order by a.name; | schema1 |

  @delete_mysql_tables
  Scenario: After migrating from mycat to dble, some sql compatibility issues   #6
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1'], 'mysql-master2': ['db1'], 'mysql':['schema1']}}
  """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="vs_store_company" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="id" />
            <shardingTable name="vs_store" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="id"/>
            <shardingTable name="vs_fin_cash_accinfo" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="id"/>
        </schema>

        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
        <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />

        <function name="func_hashString" class="StringHash">
            <property name="partitionCount">2</property>
            <property name="partitionLength">1</property>
            <property name="hashSlice">0:2</property>
        </function>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                | db      | expect  |
      | conn_0 | false   | drop table if exists vs_store_company                                                              | schema1 | success |
      | conn_0 | false   | drop table if exists vs_store                                                                      | schema1 | success |
      | conn_0 | false   | drop table if exists vs_fin_cash_accinfo                                                           | schema1 | success |
      | conn_0 | false   | create table vs_store_company(id int not null,pk_id int,remakr int,audit_status int,`status` int); | schema1 | success |
      | conn_0 | false   | create table vs_store(id int not null,fk_store_comp_id int);                                       | schema1 | success |
      | conn_0 | false   | create table vs_fin_cash_accinfo(id int not null,fk_store_comp_id int,audit_status int);           | schema1 | success |
      | conn_0 | false   | insert into vs_store_company values(1,1,3,7,10000),(2,2,5,8,15000),(3,3,10,9,20000),(4,4,99,2,1);  | schema1 | success |
      | conn_0 | true    | insert into vs_store values(1,2),(2,3),(3,4),(4,5),(5,6);                                          | schema1 | success |
      | conn_0 | true    | insert into vs_fin_cash_accinfo values(1,1,2),(2,2,8),(3,3,7),(4,4,2),(5,5,2),(6,6,88);            | schema1 | success |

     #create table used in comparing mysql
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                | db      | expect  |
      | conn_0 | false   | drop table if exists vs_store_company                                                              | schema1 | success |
      | conn_0 | false   | drop table if exists vs_store                                                                      | schema1 | success |
      | conn_0 | false   | drop table if exists vs_fin_cash_accinfo                                                           | schema1 | success |
      | conn_0 | false   | create table vs_store_company(id int not null,pk_id int,remakr int,audit_status int,`status` int); | schema1 | success |
      | conn_0 | false   | create table vs_store(id int not null,fk_store_comp_id int);                                       | schema1 | success |
      | conn_0 | false   | create table vs_fin_cash_accinfo(id int not null,fk_store_comp_id int,audit_status int);           | schema1 | success |
      | conn_0 | false   | insert into vs_store_company values(1,1,3,7,10000),(2,2,5,8,15000),(3,3,10,9,20000),(4,4,99,2,1);  | schema1 | success |
      | conn_0 | false   | insert into vs_store values(1,2),(2,3),(3,4),(4,5),(5,6);                                          | schema1 | success |
      | conn_0 | true    | insert into vs_fin_cash_accinfo values(1,1,2),(2,2,8),(3,3,7),(4,4,2),(5,5,2),(6,6,88);            | schema1 | success |
    # DBLE0REQ-1505 "field not found" error in union all statement
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain SELECT NULL AS ACCOUNTS_ID,t.remakr FROM vs_store_company t WHERE TO_DAYS(NOW())-TO_DAYS(t.pk_id)=1 limit 2 UNION ALL SELECT NULL AS ACCOUNTS_ID,t1.fk_store_comp_id from vs_store t1 where TO_DAYS(NOW())-TO_DAYS(t1.fk_store_comp_id)=1 limit 2; | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                                        |
      | dn1_0           | BASE SQL      | select `t`.`remakr` from  `vs_store_company` `t` where TO_DAYS(NOW()) - TO_DAYS(t.pk_id) = 1 LIMIT 2                             |
      | dn2_0           | BASE SQL      | select `t`.`remakr` from  `vs_store_company` `t` where TO_DAYS(NOW()) - TO_DAYS(t.pk_id) = 1 LIMIT 2                             |
      | merge_1         | MERGE         | dn1_0; dn2_0                                                                                                                     |
      | limit_1         | LIMIT         | merge_1                                                                                                                          |
      | shuffle_field_1 | SHUFFLE_FIELD | limit_1                                                                                                                          |
      | dn1_1           | BASE SQL      | select `t1`.`fk_store_comp_id` as `remakr` from  `vs_store` `t1` where TO_DAYS(NOW()) - TO_DAYS(t1.fk_store_comp_id) = 1 LIMIT 2 |
      | dn2_1           | BASE SQL      | select `t1`.`fk_store_comp_id` as `remakr` from  `vs_store` `t1` where TO_DAYS(NOW()) - TO_DAYS(t1.fk_store_comp_id) = 1 LIMIT 2 |
      | merge_2         | MERGE         | dn1_1; dn2_1                                                                                                                     |
      | limit_3         | LIMIT         | merge_2                                                                                                                          |
      | shuffle_field_3 | SHUFFLE_FIELD | limit_3                                                                                                                          |
      | union_all_1     | UNION_ALL     | shuffle_field_1; shuffle_field_3                                                                                                 |
      | limit_2         | LIMIT         | union_all_1                                                                                                                      |
      | shuffle_field_2 | SHUFFLE_FIELD | limit_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                    | db      |
      | conn_0 | true    | (SELECT NULL AS ACCOUNTS_ID,t.remakr FROM vs_store_company t WHERE TO_DAYS(NOW())-TO_DAYS(t.pk_id)=1 limit 2) UNION ALL (SELECT NULL AS ACCOUNTS_ID,t1.fk_store_comp_id from vs_store t1 where TO_DAYS(NOW())-TO_DAYS(t1.fk_store_comp_id)=1 limit 2); | schema1 |

    # DBLE0REQ-1506 "JoinNode cannot be cast to TableNode" error in query statement
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain SELECT count(0) FROM (SELECT c.pk_id, c.remakr FROM vs_store_company c LEFT JOIN vs_store s ON c.pk_id = s.fk_store_comp_id INNER JOIN vs_fin_cash_accinfo ca ON ca.fk_store_comp_id = c.pk_id WHERE c.`status` = 1 AND ( c.audit_status = 2 OR ca.audit_status = 2 ) )t; | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2                                                                                                                       |
      | dn1_0                      | BASE SQL                 | select `c`.`pk_id`,`c`.`remakr`,`c`.`audit_status` from  `vs_store_company` `c` where `c`.`status` = 1 ORDER BY `c`.`pk_id` ASC |
      | dn2_0                      | BASE SQL                 | select `c`.`pk_id`,`c`.`remakr`,`c`.`audit_status` from  `vs_store_company` `c` where `c`.`status` = 1 ORDER BY `c`.`pk_id` ASC |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                               |
      | dn1_1                      | BASE SQL                 | select `s`.`fk_store_comp_id` from  `vs_store` `s` ORDER BY `s`.`fk_store_comp_id` ASC                                          |
      | dn2_1                      | BASE SQL                 | select `s`.`fk_store_comp_id` from  `vs_store` `s` ORDER BY `s`.`fk_store_comp_id` ASC                                          |
      | merge_and_order_2          | MERGE_AND_ORDER          | dn1_1; dn2_1                                                                                                                    |
      | shuffle_field_5            | SHUFFLE_FIELD            | merge_and_order_2                                                                                                               |
      | join_1                     | JOIN                     | shuffle_field_1; shuffle_field_5                                                                                                |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                          |
      | dn1_2                      | BASE SQL                 | select `ca`.`fk_store_comp_id`,`ca`.`audit_status` from  `vs_fin_cash_accinfo` `ca` ORDER BY `ca`.`fk_store_comp_id` ASC        |
      | dn2_2                      | BASE SQL                 | select `ca`.`fk_store_comp_id`,`ca`.`audit_status` from  `vs_fin_cash_accinfo` `ca` ORDER BY `ca`.`fk_store_comp_id` ASC        |
      | merge_and_order_3          | MERGE_AND_ORDER          | dn1_2; dn2_2                                                                                                                    |
      | shuffle_field_6            | SHUFFLE_FIELD            | merge_and_order_3                                                                                                               |
      | join_2                     | JOIN                     | shuffle_field_2; shuffle_field_6                                                                                                |
      | where_filter_1             | WHERE_FILTER             | join_2                                                                                                                          |
      | shuffle_field_3            | SHUFFLE_FIELD            | where_filter_1                                                                                                                  |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_3                                                                                                                 |
      | aggregate_1                | AGGREGATE                | rename_derived_sub_query_1                                                                                                      |
      | shuffle_field_4            | SHUFFLE_FIELD            | aggregate_1                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | db      |
      | conn_0 | true    | SELECT count(0) FROM (SELECT c.pk_id, c.remakr FROM vs_store_company c LEFT JOIN vs_store s ON c.pk_id = s.fk_store_comp_id INNER JOIN vs_fin_cash_accinfo ca ON ca.fk_store_comp_id = c.pk_id WHERE c.`status` = 1 AND ( c.audit_status = 2 OR ca.audit_status = 2 ) )t; | schema1 |