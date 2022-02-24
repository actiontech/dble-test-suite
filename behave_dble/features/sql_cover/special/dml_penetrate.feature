# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2020/7/27
# Created by quexiuping at 2020/7/29
Feature: test dml sql which can penetrate to mysql
  @regression
  Scenario: check insert/replace into ... select syntax #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
         <singleTable name="nos_1_t1"  shardingNode="dn5"/>
         <singleTable name="nos_1_t2"  shardingNode="dn5"/>
          <singleTable name="nos_1_t3"  shardingNode="dn2"/>
          <shardingTable name="s_2_t1"  shardingNode="dn3,dn4" function="hash-two" shardingColumn="id"/>
          <shardingTable name="s_3_t1"  shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id"/>
          <shardingTable name="s_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="s_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
             <childTable name="s_4_t2c1" joinColumn="id" parentColumn="id" sqlMaxLimit="100">
                  <childTable name="s_4_t2g" joinColumn="id" parentColumn="id"/>
             </childTable>
             <childTable name="s_4_t2c2" joinColumn="name" parentColumn="name"/>
          </shardingTable>
          <globalTable name="g_3_t1" shardingNode="dn1,dn2,dn3" />
          <globalTable name="g_4_t1" shardingNode="dn1,dn2,dn3,dn4"  />
          <globalTable name="g_4_t2" shardingNode="dn1,dn2,dn3,dn4"  />
      </schema>

      <schema name="schema2" sqlMaxLimit="100">
          <singleTable name="nos_1_t4"  shardingNode="dn2" />
          <shardingTable name="s_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="s_4_t4" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform" shardingColumn="id" />
          <globalTable name="g_4_t3" shardingNode="dn1,dn2,dn3,dn4"  />
          <globalTable name="g_4_t4" shardingNode="dn1,dn2,dn3,dn4"  />
      </schema>

      <schema name="schema3">
          <singleTable name="nos_1_t5"  shardingNode="dn5" />
          <shardingTable name="s_4_t5" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
          <shardingTable name="s_4_t6" shardingNode="dn1,dn2,dn3,dn5" function="hash-four" shardingColumn="id"/>
          <shardingTable name="s_4_t7" shardingNode="dn1,dn2,dn3,dn6" function="hash-four" shardingColumn="id"/>
          <shardingTable name="s_4_t8" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
          <shardingTable name="s_4_t9" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
          <globalTable name="g_4_t5" shardingNode="dn1,dn2,dn3,dn4"  />
          <globalTable name="g_5_t1" shardingNode="dn1,dn2,dn3,dn4,dn5"  />
          <globalTable name="g_6_t1" shardingNode="dn1,dn2,dn3,dn4,dn5,dn6"  />
      </schema>

      <schema name="schema4" sqlMaxLimit="100" shardingNode="dn5" >
      </schema>

      <schema name="schema5" sqlMaxLimit="100" shardingNode="dn6" >
      </schema>

      <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />

      <function name="hash-string-into-two" class="StringHash">
          <property name="partitionCount">2</property>
          <property name="partitionLength">1</property>
      </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3,schema4,schema5">
          <privileges check="true">
              <schema name="schema3" dml="1111">
                  <table name="s_4_t8" dml="1101"/>
                  <table name="s_4_t9" dml="0011"/>
              </schema>
         </privileges>
      </shardingUser>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      # insert/replace into sharding table
      | conn   | toClose | sql                                                                                                                               | expect                                                              | db      |
      | conn_0 | False   | drop table if exists s_4_t1                                                                                                       | success                                                             | schema1 |
      | conn_0 | False   | create table s_4_t1(id int PRIMARY KEY,name varchar(10),age int,gender int)                                                       | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists s_4_t2                                                                                                       | success                                                             | schema1 |
      | conn_0 | False   | create table s_4_t2(id int,name varchar(10),gender int)                                                                           | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2 values(1,14,14),(2,24,24),(4,34,34)                                                                            | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists s_4_t2c1                                                                                                     | success                                                             | schema1 |
      | conn_0 | False   | create table s_4_t2c1(id int,name varchar(10),gender int)                                                                         | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2c1 values(1,'14c1',14)                                                                                          | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2c1 values(2,'24c1',24)                                                                                          | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2c1 values(4,'34c1',34)                                                                                          | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2c1 values(5,'5c1',5)                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists s_4_t2g                                                                                                      | success                                                             | schema1 |
      | conn_0 | False   | create table s_4_t2g(id int,name varchar(10),gender int)                                                                          | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2g values(1,'14g',14)                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2g values(2,'24g',24)                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2g values(3,'3g',3)                                                                                              | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2g values(4,'34g',34)                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists s_4_t2c2                                                                                                     | success                                                             | schema1 |
      | conn_0 | False   | create table s_4_t2c2(id int,name varchar(10),gender int)                                                                         | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2c2 values(1,14,141)                                                                                             | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2c2 values(3,24,34)                                                                                              | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t2c2 values(4,34,34)                                                                                              | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema2.s_4_t3                                                                                               | success                                                             | schema1 |
      | conn_0 | False   | create table schema2.s_4_t3(id int,name varchar(10),age int,gender int)                                                           | success                                                             | schema1 |
      | conn_0 | False   | insert into schema2.s_4_t3 values(1,15,1,1),(2,25,2,2),(3,35,3,3),(4,45,4,44),(5,55,5,5),(6,65,6,6)                               | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.s_4_t5                                                                                               | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.s_4_t5(id int,name varchar(10),gender int)                                                                   | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.s_4_t5 values(1,16,16),(2,24,24),(4,36,34)                                                                    | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.s_4_t7                                                                                               | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.s_4_t7(id int,name varchar(10),gender int)                                                                   | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.s_4_t7 values(1,100,1),(2,102,2),(3,103,3),(4,104,4)                                                          | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.s_4_t8                                                                                               | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.s_4_t8(id int,name varchar(10),gender int)                                                                   | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.s_4_t8 values(1,38,1),(2,48,2),(3,58,3),(4,84,4)                                                              | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.s_4_t9                                                                                               | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.s_4_t9(id int,name varchar(10),gender int)                                                                   | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists g_4_t2                                                                                                       | success                                                             | schema1 |
      | conn_0 | False   | create table g_4_t2(id int,name varchar(10),age int,gender int)                                                                   | success                                                             | schema1 |
      | conn_0 | False   | insert into g_4_t2 values(1,13,13,13),(3,33,3,3),(4,4,4,4)                                                                        | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.g_5_t1                                                                                               | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.g_5_t1(id int,name varchar(10),gender int)                                                                   | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.g_5_t1 values(1,12,1),(2,22,22),(3,32,32)                                                                     | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists nos_1_t3                                                                                                     | success                                                             | schema1 |
      | conn_0 | False   | create table nos_1_t3(id int,name varchar(10),gender int)                                                                         | success                                                             | schema1 |
      | conn_0 | False    | insert into nos_1_t3 values(1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6)                                                       | success                                                             | schema1 |
      | conn_0 | False    | drop table if exists schema3.s_4_t6                                                                                              | success                                                             | schema1 |
      | conn_0 | True    | create table schema3.s_4_t6(id int,name varchar(10),gender int)                                                                   | success                                                             | schema1 |
      #cases
      | conn_0 | True   | insert into s_4_t1(id,name) select id,name from schema3.s_4_t6                                                                     | INSERT ... SELECT Syntax` is not supported                          | schema1 |
      | conn_0 | False   | insert into schema3.s_4_t9(id,name) select id,name from s_4_t2                                                                    | The statement DML privilege check is not passed                     | schema1 |
      | conn_0 | False   | replace  into schema3.s_4_t9(id,name) select id,name from s_4_t2                                                                  | The statement DML privilege check is not passed                     | schema1 |
      | conn_0 | False   | insert into s_4_t1(id,name) select id,name from g_4_t2                                                                            | This `INSERT ... SELECT Syntax` is not supported                    | schema1 |
      | conn_0 | False   | replace into s_4_t1(id,name) select id,name from `schema3`.s_4_t7                                                                 | This `REPLACE ... SELECT Syntax` is not supported                   | schema1 |
      | conn_0 | False   | insert into s_4_t1(id,name) select s2.id,s2.name from s_4_t2 s2 join s_4_t2g s2g on s2.id=s2g.id                                  | This `INSERT ... SELECT Syntax` is not supported                    | schema1 |
      | conn_0 | False   | insert into s_4_t1(id,name) select s2c1.id,s2c1.name from s_4_t2c1 s2c1 join s_4_t2g s2g on s2c1.id=s2g.id                        | This `INSERT ... SELECT Syntax` is not supported                    | schema1 |
      | conn_0 | False    | replace into s_4_t1(id,name)select s_4_t2.id,s_4_t2.name from s_4_t2 join nos_1_t3 on s_4_t2.name=nos_1_t3.name                  | This `REPLACE ... SELECT Syntax` is not supported                   | schema1 |
      | conn_0 | False   | replace into s_4_t1(id,name,gender) select s3.id,s2.name,s2.gender from schema2.s_4_t3 s3 join s_4_t2 s2 on s3.gender=s2.gender   | This `REPLACE ... SELECT Syntax` is not supported                   | schema1 |
      | conn_0 | False   | insert into s_4_t1(id,name) select s2c1.id,s2c1.name from s_4_t2c1 s2c1 join s_4_t2 s2 on s2c1.id=s2.id                           | This `INSERT ... SELECT Syntax` is not supported                    | schema1 |
      | conn_0 | False   | insert into s_4_t1(id,name) select id,name from s_4_t2                                                                            | success                                                             | schema1 |
      | conn_0 | False   | select * from s_4_t1                                                                                                              | has{(1,'14',None,None),(2,'24',None,None),(4,'34',None,None)}       | schema1 |

      | conn_0 | False   | replace into s_4_t1(id,name) select id,name from schema2.s_4_t3                                                                  | success                          | schema1 |
      | conn_0 | False   | select * from s_4_t1                                                                                                              | length{(6)}                                                         | schema1 |

      | conn_0 | False   | delete from s_4_t1                                                                                                                | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t1(id,name,gender) select s3.id,g2.name,g2.gender from schema2.s_4_t3 s3 join g_4_t2 g2 on s3.gender=g2.gender    | success                                                             | schema1 |
      | conn_0 | False   | select * from s_4_t1                                                                                                              | has{(3,'33',None,3)}                                                | schema1 |

      | conn_0 | False   | replace into s_4_t1(id,name,gender) select s3.id,g2.name,g2.gender from schema2.s_4_t3 s3 join g_4_t2 g2 on s3.gender=g2.gender   | success                                                             | schema1 |
      | conn_0 | False   | select * from s_4_t1                                                                                                              | has{(3,'33',None,3)}                                                | schema1 |

      | conn_0 | False   | delete from s_4_t1                                                                                                                | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t1(id,name,gender) select s3.id,s2.name,s2.gender from schema2.s_4_t3 s3 join s_4_t2 s2 on s3.id=s2.id;           | success                                                             | schema1 |
      | conn_0 | False   | select * from s_4_t1                                                                                                              | has{(4,'34',None,34),(2,'24',None,24),(1,'14',None,14)}             | schema1 |

      | conn_0 | False   | delete from s_4_t1                            | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t1(id,name) select s2.id,s2c1.name from s_4_t2  s2 join s_4_t2c1 s2c1 on s2c1.id=s2.id                            | success                                                             | schema1 |
      | conn_0 | False   | select * from s_4_t1                                                                                                              | has{(4,'34c1',None,None),(1,'14c1',None,None),(2,'24c1',None,None)} | schema1 |

      | conn_0 | False   | insert into s_4_t1(id,name) select s_4_t2.id,s_4_t2.name from s_4_t2 join nos_1_t3 on s_4_t2.name=nos_1_t3.name where s_4_t2.id=1 | success                                                             | schema1 |

      # insert/replace into global table
      | conn_0 | False   | drop table if exists g_3_t1                                                                                                        | success                                                           | schema1 |
      | conn_0 | False   | create table g_3_t1(id int,name varchar(10),age int,gender int)                                                                    | success                                                           | schema1 |
      | conn_0 | False   | insert into g_3_t1 values(1,13,13,13),(2,23,23,23),(3,33,3,33)                                                                    | success                                                            | schema1 |
      | conn_0 | False   | drop table if exists g_4_t1                                                                                                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | create table g_4_t1(id int PRIMARY KEY,name varchar(10),age int,gender int)                                                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists g_4_t2                                                                                                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | create table g_4_t2(id int,name varchar(10),age int,gender int)                                                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | insert into g_4_t2 values(1,13,13,13),(3,33,3,3),(4,4,4,4)                                                                                                                                             | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema2.g_4_t3                                                                                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | create table schema2.g_4_t3(id int,name varchar(10),age int,gender int)                                                                                                                                | success                                                             | schema1 |
      | conn_0 | False   | insert into schema2.g_4_t3 values(1,14,1,1),(2,24,2,2),(3,34,3,3),(4,44,4,44),(5,54,5,5),(6,64,6,6)                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.g_4_t5                                                                                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.g_4_t5(id int,name varchar(10),gender int)                                                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.g_4_t5 values(1,14,14),(2,24,24),(4,34,34)                                                                                                                                         | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.g_5_t1                                                                                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.g_5_t1(id int,name varchar(10),gender int)                                                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.g_5_t1 values(1,12,1),(2,22,22),(3,32,32)                                                                                                                                          | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.g_6_t1                                                                                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.g_6_t1(id int,name varchar(10),gender int)                                                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.g_6_t1 values(1,100,1),(2,102,2),(3,103,3),(4,104,4)                                                                                                                               | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists nos_1_t3                                                                                                                                                                          | success                                                             | schema1 |
      | conn_0 | False   | create table nos_1_t3(id int,name varchar(10),gender int)                                                                                                                                              | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists s_4_t1                                                                                                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | create table s_4_t1(id int,name varchar(10),age int,gender int)                                                                                                                                        | success                                                             | schema1 |
      #cases
      | conn_0 | False   | replace into g_4_t1(name) select name from g_3_t1                                                                                                                                                      | This `REPLACE ... SELECT Syntax` is not supported                   | schema1 |
      | conn_0 | False   | replace into g_4_t1(name) select name from nos_1_t3                                                                                                                                                    | This `REPLACE ... SELECT Syntax` is not supported                   | schema1 |
      | conn_0 | False   | insert into g_4_t1(id,name) select id,name from s_4_t1                                                                                                                                                 | This `INSERT ... SELECT Syntax` is not supported                    | schema1 |

      | conn_0 | False   | insert into g_4_t1(id,name) select id,name from g_4_t2                                                                                                                                                 | success                                                             | schema1 |
      | conn_0 | False   | select * from g_4_t1                                                                                                                                                                                   | has{(1L,'13',None,None),(3L,'33',None,None),(4L,'4',None,None)}     | schema1 |

      | conn_0 | False   | replace into g_3_t1(id,name) select g1.id,g2.name from g_4_t1 g1,g_4_t2 g2                                                                                                                             | success                                                             | schema1 |
      | conn_0 | False   | select * from g_3_t1                                                                                                                                                                                   | length{(12)}                                                        | schema1 |

      | conn_0 | False   | delete from  g_3_t1                                                                                                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | insert into g_3_t1(id,name) select g_4_t2.id,g_4_t2.name from g_4_t1, g_4_t2,schema2.g_4_t3,schema3.g_4_t5                                                                                             | success                                                             | schema1 |
      | conn_0 | False   | select * from g_3_t1 limit 200                                                                                                                                                                         | length{(162)}                                                       | schema1 |

      # insert/replace into no-sharding table
      | conn_0 | False   | drop table if exists nos_1_t1                                                                                                                                                                          | success                                                             | schema1 |
      | conn_0 | False   | create table nos_1_t1 (id int,name varchar(10))                                                                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | insert into nos_1_t1 values(1,41),(2,24)                                                                                                                                                               | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists nos_1_t3                                                                                                                                                                          | success                                                             | schema1 |
      | conn_0 | False   | create table nos_1_t3(id int,name varchar(10),age int,gender int)                                                                                                                                      | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists s_4_t1                                                                                                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | create table s_4_t1(id int,name varchar(10),gender int)                                                                                                                                                | success                                                             | schema1 |
      | conn_0 | False   | insert into s_4_t1 values(1,10,10),(2,20,2),(3,30,30)                                                                                                                                                  | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists s_3_t1                                                                                                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | create table s_3_t1(id int,name varchar(10),gender int)                                                                                                                                                | success                                                             | schema1 |
      | conn_0 | False   | insert into s_3_t1 values(1,11,11),(2,21,21),(4,41,4),(5,51,51)                                                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists nos_1_t2                                                                                                                                                                          | success                                                             | schema1 |
      | conn_0 | False   | create table nos_1_t2(id int,name varchar(10),age int)                                                                                                                                                 | success                                                             | schema1 |
      | conn_0 | False   | insert into nos_1_t2 values(1,13,13),(2,23,23),(3,33,3)                                                                                                                                                | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.nos_1_t5                                                                                                                                                                  | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.nos_1_t5(id int,name varchar(10),gender int)                                                                                                                                      | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.nos_1_t5 values(1,12,1),(2,22,22),(3,32,32)                                                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists g_4_t1                                                                                                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | create table g_4_t1(id int,name varchar(10),age int,gender int)                                                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | insert into g_4_t1 values(1,14,1,1),(2,24,2,2),(3,34,3,3),(4,44,4,44),(5,54,5,5),(6,64,6,6)                                                                                                            | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema2.nos_1_t4                                                                                                                                                                  | success                                                             | schema1 |
      | conn_0 | False   | create table schema2.nos_1_t4(id int,name varchar(10),gender int)                                                                                                                                      | success                                                             | schema1 |
      | conn_0 | False   | insert into schema2.nos_1_t4 values(1,100,1),(2,102,2),(3,103,3),(4,104,4)                                                                                                                             | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema2.g_4_t3                                                                                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | create table schema2.g_4_t3(id int,name varchar(10))                                                                                                                                                   | success                                                             | schema1 |
      | conn_0 | False   | insert into schema2.g_4_t3 values(1,1000)                                                                                                                                                              | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists schema3.s_4_t6                                                                                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | create table schema3.s_4_t6(id int,name varchar(10),age int)                                                                                                                                           | success                                                             | schema1 |
      | conn_0 | False   | insert into schema3.s_4_t6 values(1,41,1),(2,42,2),(3,43,3),(4,43,4)                                                                                                                                   | success                                                             | schema1 |
      #cases
      | conn_0 | False   | replace into nos_1_t1 (id,name) select nos_1_t2.id,nos_1_t2.name from nos_1_t2,s_3_t1                                                                                                                  | This `REPLACE ... SELECT Syntax` is not supported                   | schema1 |
      | conn_0 | False   | insert into nos_1_t3(name,age,gender) select a.name,b.age,c.gender from nos_t1 a, nos_1_t2 b ,g_4_t1 c where c.id in (select g_4_t1.id from s_4_t1 join g_4_t1 on g_4_t1.id=s_4_t1.id and s_4_t1.id=1) | This `INSERT ... SELECT Syntax` is not supported                    | schema1 |
      | conn_0 | False   | insert into nos_1_t3(id,name) select s_4_t1.id,s_3_t1.name from s_3_t1,s_4_t1 where s_3_t1.id=s_4_t1.id and s_3_t1.id=1                                                                                | success                                                             | schema1 |
      | conn_0 | False   | select * from nos_1_t3                                                                                                                                                                                 | has{(1,'11',None,None)}                                             | schema1 |
      | conn_0 | False   | replace into nos_1_t3(name) select a.name from schema2.nos_1_t4 a                                                                                                                                      | success                                                             | schema1 |
      | conn_0 | False   | select id,name from nos_1_t3                                                                                                                                                                           | has{(1,'11'),(None,'100'),(None,'102'),(None,'103'),(None,'104')}   | schema1 |
      | conn_0 | False   | replace into nos_1_t1 (id,name) select nos_1_t2.id,nos_1_t2.name from nos_1_t2,schema3.nos_1_t5                                                                                                        | success                                                             | schema1 |
      | conn_0 | False   | select * from nos_1_t3                                                                                                                                                                                 | success                                                             | schema1 |
      | conn_0 | False   | replace into nos_1_t3(name) select name from g_4_t1                                                                                                                                                    | success                                                             | schema1 |
      | conn_0 | False   | select * from nos_1_t3                                                                                                                                                                                 | success                                                             | schema1 |
      | conn_0 | False   | replace into nos_1_t3(id,name) select g1.id ,g2.name from g_4_t1 g1,schema2.g_4_t3 g2                                                                                                                  | success                                                             | schema1 |
      | conn_0 | False   | select * from nos_1_t3                                                                                                                                                                                 | success                                                             | schema1 |
      | conn_0 | False   | drop table if exists nos_implicy                                                                                                                                                                       | success                                                             | schema1 |
      | conn_0 | False   | create table nos_implicy(id int,name varchar(10),age int)                                                                                                                                              | success                                                             | schema1 |
      | conn_0 | False   | insert nos_implicy(id,name,age) select n1.id,n1.name,s6.age from nos_1_t1 n1 join (select id,name,age from schema3.s_4_t6 where id=3) as s6                                                            | success                                                             | schema1 |
      | conn_0 | False   | select * from nos_implicy                                                                                                                                                                              | success                                                             | schema1 |

      # insert/replace into table which the involved tables are all vertical sharding tables
      | conn_0 | False   | drop table if exists tb_a                                                                                                                                                                              | success                                                             | schema4 |
      | conn_0 | False   | create table tb_a(id int,name varchar(10),age int(10))                                                                                                                                                 | success                                                             | schema4 |
      | conn_0 | False   | drop table if exists tb_b                                                                                                                                                                              | success                                                             | schema4 |
      | conn_0 | False   | create table tb_b(id int,name varchar(10),age int(10))                                                                                                                                                 | success                                                             | schema4 |
      | conn_0 | False   | insert into tb_b values(1,10,1),(2,20,2),(3,30,3),(4,40,4),(5,50,5),(6,60,6),(7,70,7)                                                                                                                  | success                                                             | schema4 |
      | conn_0 | False   | drop table if exists tb_c                                                                                                                                                                              | success                                                             | schema4 |
      | conn_0 | False   | create table tb_c(id int,name varchar(10),age int(10))                                                                                                                                                 | success                                                             | schema4 |
      | conn_0 | False   | insert into tb_c values(1,11,1),(3,31,3),(5,51,5)                                                                                                                                                      | success                                                             | schema4 |
      | conn_0 | False   | drop table if exists schema1.s_4_t1                                                                                                                                                                    | success                                                             | schema4 |
      | conn_0 | False   | create table schema1.s_4_t1(id int,name varchar(10))                                                                                                                                                   | success                                                             | schema4 |
      | conn_0 | False   | drop table if exists schema2.g_4_t3                                                                                                                                                                    | success                                                             | schema4 |
      | conn_0 | False   | create table schema2.g_4_t3 (id int,name varchar(10))                                                                                                                                                  | success                                                             | schema4 |
      | conn_0 | False   | drop table if exists schema3.s_4_t6                                                                                                                                                                    | success                                                             | schema4 |
      | conn_0 | False   | create table schema3.s_4_t6(id int,name varchar(10),gender varchar(10))                                                                                                                                | success                                                             | schema4 |
      | conn_0 | False   | insert into schema3.s_4_t6 values(1,15,1),(2,25,2),(3,35,3)                                                                                                                                            | success                                                             | schema4 |
      #cases
      | conn_0 | False   | insert into tb_a(id,name) select id,name from schema1.s_4_t1                                                                                                                                           | This `INSERT ... SELECT Syntax` is not supported                    | schema4 |
      | conn_0 | False   | replace into tb_a(id,name) select id,name from schema2.g_4_t3                                                                                                                                          | This `REPLACE ... SELECT Syntax` is not supported                   | schema4 |

      | conn_0 | False   | insert into tb_a(id,name) select id,name from tb_b                                                                                                                                                     | success                                                             | schema4 |
      | conn_0 | False   | select * from tb_a                                                                                                                                                                                     | length{(7)}                                                         | schema4 |

      | conn_0 | False   | replace into tb_a(id,name,age) select tb_b.id ,tb_b.name,tb_c.age from tb_b,tb_c                                                                                                                       | success                                                             | schema4 |
      | conn_0 | False   | select * from tb_a                                                                                                                                                                                     | length{(28)}                                                         | schema4 |

      | conn_0 | False   | insert into tb_a(id,name) select id,name from schema3.s_4_t6 where id=3                                                                                                                                | success                                                             | schema4 |
      # not support view
#      | conn_0 | False   | drop view if exists view_test                                                                                                                                                    | success                                                             | schema4 |
#      | conn_0 | False   | create view view_test as select id ,name from tb_b                                                                                                                                                     | success                                                             | schema4 |
#      | conn_0 | False   | replace into tb_a(id,name) select view_test.id,tb_c.name from view_test,tb_c                                                                                                                           | length{(21)}                                                         | schema4 |
#      | conn_0 | False   | select * from tb_a                                                                                                                                                                                     | length{(21)}                                                         | schema4 |

  Scenario: check update/delete  from .... syntax and one table #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="single_t1" shardingNode="dn6" />
        <globalTable name="global_t1" shardingNode="dn1,dn2" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_3_t1" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <schema name="schema2" sqlMaxLimit="100">
        <singleTable name="single_t2" shardingNode="dn1" />
        <singleTable name="single_t3" shardingNode="dn6" />
        <globalTable name="global_t2" shardingNode="dn1,dn2" />
        <globalTable name="global_t3" shardingNode="dn5,dn6" />
        <globalTable name="global_t4" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <schema shardingNode="dn1" name="schema3"/>
    <schema shardingNode="dn2" name="schema4"/>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />

     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
     <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3,schema4">
          <privileges check="true">
            <schema name="schema3" dml="1111">
              <table name="t1" dml="1101"/>
              <table name="t2" dml="1010"/>
            </schema>
          </privileges>
        </shardingUser>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      # prepare sql
      | conn   | toClose | sql                                                                                 | expect                | db      |
      | conn_0 | False   | drop table if exists schema3.t1;                                                    | success               | schema3 |
      | conn_0 | False   | drop table if exists schema3.t2;                                                    | success               | schema3 |
      | conn_0 | False   | drop table if exists schema3.t3;                                                    | success               | schema3 |
      | conn_0 | False   | create table schema3.t1(id int,name char(20),age int);                              | success               | schema3 |
      | conn_0 | False   | create table schema3.t2(id int,name char(20),age int);                              | success               | schema3 |
      | conn_0 | False   | create table schema3.t3(id int,name char(20),age int);                              | success               | schema3 |
      | conn_0 | False   | insert into schema3.t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success               | schema3 |
      | conn_0 | False   | insert into schema3.t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success               | schema3 |
      | conn_0 | False   | insert into schema3.t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success               | schema3 |
      ##case: no privilege
      | conn_0 | False   | update schema3.t3 a set a.age=11 where a.name=(select b.name from schema3.t1 b where b.age=1);      | The statement DML privilege check is not passe      | schema3 |
      | conn_0 | False   | delete from schema3.t3 a where a.name=(select b.name from schema3.t1 b where b.age=1);              | The statement DML privilege check is not passe      | schema3 |
      | conn_0 | False   | update schema3.t2 a set a.age=11 where a.name=(select b.name from schema3.t3 b where b.age=1);      | The statement DML privilege check is not passe      | schema3 |
      | conn_0 | False   | delete from schema3.t2 a where a.name=(select b.name from schema3.t3 b where b.age=1);              | The statement DML privilege check is not passe      | schema3 |
      ##case: has privilege and no Subquery
      | conn_0 | False   | update schema3.t3 set age=age+1;                                                    | success                                                                 | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                                           | has{(1,'1',2),(2,'2',3),(3,'3',4),(4,'4',5),(5,'5',6),(6,'6',7)}        | schema3 |
      | conn_0 | False   | delete from schema3.t3;                                                             | success                                                                 | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                                           | length{(0)}                                                             | schema3 |
      | conn_0 | False   | insert into schema3.t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success                                                                 | schema3 |
      ##has privilege and has Subquery and update/delete the operated table is single table
      # prepare sql
      | conn_0 | False   | drop table if exists schema1.single_t1;                                                    | success           | schema1 |
      | conn_0 | False   | drop table if exists schema2.single_t2;                                                    | success           | schema2 |
      | conn_0 | False   | drop table if exists schema2.single_t3;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema1.single_t1(id int,name char(20),age int);                              | success           | schema1 |
      | conn_0 | False   | create table schema2.single_t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | create table schema2.single_t3(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema1.single_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema1 |
      | conn_0 | False   | insert into schema2.single_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | insert into schema2.single_t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      #case: Subquery conditions can be routed to the node where the non-sharded table is located (single table)
      | conn_0 | False   | update schema1.single_t1 set age=age+1 where name=(select name from schema2.single_t3 order by id desc limit 1);     | success                                                          | schema1 |
      | conn_0 | False   | select * from schema1.single_t1;                                                                                     | has{(1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',7)} | schema1 |
      | conn_0 | False   | delete from schema1.single_t1 where name=(select name from schema2.single_t3 order by id desc limit 1);              | success                                                          | schema1 |
      | conn_0 | False   | select * from schema1.single_t1;                                                                                     | has{(1,'1',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5)}           | schema1 |
      | conn_0 | False   | update schema1.single_t1 set age=age+1 where name in (select name from schema2.single_t3 order by id desc);          | success                                                          | schema1 |
      | conn_0 | False   | select * from schema1.single_t1;                                                                                     | has{(1,'1',2),(2,'2',3),(3,'3',4),(4,'4',5),(5,'5',6)}           | schema1 |
      | conn_0 | False   | delete from schema1.single_t1 where name in (select name from schema2.single_t3 order by id desc);                   | success                                                          | schema1 |
      | conn_0 | False   | select * from schema1.single_t1;                                                                                     |length{(0)}                                                       | schema1 |
      | conn_0 | False   | insert into schema1.single_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);                                | success                                                          | schema1 |
      #case: Subquery conditions cannot be routed to the node where the non-sharded table is located (single table)
      | conn_0 | False   | update schema1.single_t1 set age=age+1 where name=(select name from schema2.single_t2 order by id desc limit 1);  | This `Complex Update Syntax` is not supported!       | schema1 |
      | conn_0 | False   | delete from schema1.single_t1 where name=(select name from schema2.single_t2 order by id desc limit 1);           | This `Complex Delete Syntax` is not supported!       | schema1 |
      #case: Subquery conditions can be routed to the node where the non-sharded table is located (global table )
      # prepare sql
      | conn_0 | False   | drop table if exists schema2.global_t2;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema2.global_t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema2.global_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | update schema2.single_t2 set age=age+1 where name = (select name from schema2.global_t2 where id=1);   | success                                                          | schema2 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                       | has{(1,'1',2),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)} | schema2 |
      | conn_0 | False   | delete from schema2.single_t2 where name in (select name from schema2.global_t2);                      | success                                                          | schema2 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                       | length{(0)}                                                      | schema2 |
      | conn_0 | False   | insert into schema2.single_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);                  | success                                                          | schema2 |
      #case: Subquery conditions cannot be routed to the node where the non-sharded table is located (global table )
      | conn_0 | False   | update schema1.single_t1 set age=age+1 where name in (select name from (select name,age from schema2.global_t2 order by id desc) as tmp );   | This `Complex Update Syntax` is not supported!  | schema1 |
      | conn_0 | False   | delete from schema1.single_t1 where name in (select name from (select name,age from schema2.global_t2 order by id desc) as tmp );            | This `Complex Delete Syntax` is not supported!  | schema1 |
      #case: Subquery conditions can be routed to the node where the non-sharded table is located (sharding table )
      # prepare sql
      | conn_0 | False   | drop table if exists schema1.sharding_2_t1;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema1.sharding_2_t1(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema1.sharding_2_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | update schema2.single_t2 set age=age+1 where name = (select name from schema1.sharding_2_t1 where id=2);   | success                                                          | schema2 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                           | has{(1,'1',1),(2,'2',3),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)} | schema2 |
      | conn_0 | False   | delete from schema2.single_t2 where name in (select name from schema1.sharding_2_t1 where id=2);           | success                                                          | schema2 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                           | has{(1,'1',1),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}           | schema2 |
      #case: Subquery conditions cannot be routed to the node where the non-sharded table is located (sharding table )
      | conn_0 | False   | update schema1.single_t1 set age=age+1 where name in  (select name from  (select name,age from schema2.sharding_2_t1 order by id desc) as tmp );   | This `Complex Update Syntax` is not supported!  | schema1 |
      | conn_0 | False   | delete from schema1.single_t1 where name in (select name from (select name,age from schema2.sharding_2_t1 order by id desc) as tmp );              | This `Complex Delete Syntax` is not supported!  | schema1 |
      #case: Subquery conditions can be routed to the node where the non-sharded table is located (vertical sharding table )
      | conn_0 | False   | update schema2.single_t2 set age=age+1 where name = (select name from schema3.t3 where id=1);   | success                                                     | schema2 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                | has{(1,'1',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}      | schema2 |
      | conn_0 | False   | delete from schema2.single_t2 where name in (select name from schema3.t3 where id=1);           | success                                                     | schema2 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                | has{(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}                | schema2 |
      #case: Subquery conditions cannot be routed to the node where the non-sharded table is located (vertical sharding table )
      | conn_0 | False   | update schema1.single_t1 set age=age+1 where name in (select name from (select name,age from schema3.t3 order by id desc) as tmp );   | This `Complex Update Syntax` is not supported!  | schema1 |
      | conn_0 | False   | delete from schema1.single_t1 where name in (select name from  (select name,age from schema3.t3 order by id desc) as tmp );           | This `Complex Delete Syntax` is not supported!  | schema1 |
      #case: Subquery conditions can be routed to the node where the non-sharded table is located (different tables )
      # prepare sql
      | conn_0 | False   | drop table if exists schema2.single_t2;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema2.single_t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema2.single_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | drop table if exists schema1.global_t1;                                                    | success           | schema1 |
      | conn_0 | False   | create table schema1.global_t1(id int,name char(20),age int);                              | success           | schema1 |
      | conn_0 | False   | insert into schema1.global_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema1 |
      | conn_0 | False   | update schema2.single_t2 set age=age+1 where name in (select a.name from schema3.t3 a  join schema1.global_t1 b on a.id =b.id where a.age = (select age from schema1.sharding_2_t1 where id=2));   | success                                              | schema2 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                           | has{(1,'1',1),(2,'2',3),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)} | schema2 |
      | conn_0 | False   | delete from schema2.single_t2 where name in (select a.name from schema3.t3 a  join schema1.global_t1 b on a.id =b.id where a.age = (select age from schema1.sharding_2_t1 where id=2));            | success                                              | schema2 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                           | has{(1,'1',1),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}           | schema2 |
      | conn_0 | False   | drop table if exists schema2.single_t2;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema2.single_t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema2.single_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      #case: Subquery conditions cannot be routed to the node where the non-sharded table is located (different tables )
      | conn_0 | False   | update schema2.single_t2 set age=age+1 where name in (select a.name from schema3.t3 a  join schema1.global_t1 b on a.id =b.id where a.age = (select age from schema1.sharding_2_t1 where id= ((select id from (select name,id from schema3.t3 where age=1) as tmp))));        | This `Complex Update Syntax` is not supported!  | schema2 |
      | conn_0 | False   | delete from schema2.single_t2 where name in  (select a.name from schema3.t3 a  join schema1.global_t1 b on a.id =b.id where a.age = (select age from schema1.sharding_2_t1 where id= ((select id from (select name,id from schema3.t3 where age=1) as tmp))));                | This `Complex Delete Syntax` is not supported!  | schema2 |
      ##has privilege and has Subquery and update/delete the operated table is global table
      # prepare sql
      | conn_0 | False   | drop table if exists schema2.global_t4;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema2.global_t4(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema2.global_t4 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      #case: the tables involved in the subquery are all global tables and the nodes of the final route of the subquery cover all the nodes of the operated table
      | conn_0 | False   | update schema2.global_t2 set age=age+1 where name in ((select age from (select name,age from schema2.global_t4 order by id desc) as tmp));   | success                                                          | schema2 |
      | conn_0 | False   | select * from schema2.global_t2;                                                                                                             | has{(1,'1',2),(2,'2',3),(3,'3',4),(4,'4',5),(5,'5',6),(6,'6',7)} | schema2 |
      | conn_0 | False   | delete from schema2.global_t2 where name in ((select age from (select name,age from schema2.global_t4 order by id desc) as tmp));            | success                                                          | schema2 |
      | conn_0 | False   | select * from schema2.global_t2;                                                                                                             | length{(0)}                                                      | schema2 |
      | conn_0 | False   | insert into schema2.global_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);                                                        | success                                                          | schema2 |
      #case: have single tables in the subquery
      | conn_0 | False   | update schema2.global_t2 set age=age+1 where name in ((select age from (select name,age from schema2.single_t2 order by id desc) as tmp));   | This `Complex Update Syntax` is not supported!  | schema2 |
      | conn_0 | False   | delete from schema2.global_t2 where name in ((select age from (select name,age from schema2.single_t2 order by id desc) as tmp));            | This `Complex Delete Syntax` is not supported!  | schema2 |
      #case: have sharding tables in the subquery
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema2.sharding_4_t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema2.sharding_4_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | update schema2.global_t2 set age=age+1 where name in ((select age from (select name,age from schema2.sharding_4_t2 order by id desc) as tmp));         | This `Complex Update Syntax` is not supported!  | schema2 |
      | conn_0 | False   | delete from schema2.global_t2 where name in ((select age from (select name,age from schema2.sharding_4_t2 order by id desc) as tmp));                  | This `Complex Delete Syntax` is not supported!  | schema2 |
      #case: the node of a global table involved in the subquery is smaller than the operated table
      | conn_0 | False   | drop table if exists schema2.global_t3;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema2.global_t3(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema2.global_t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | update schema2.global_t2 set age=age+1 where name in (select a.name from schema1.global_t1 a join schema2.global_t3 b on a.id =b.id where a.age in ((select age from (select name,age from schema2.global_t4 order by id desc) as tmp)));        | This `Complex Update Syntax` is not supported!  | schema2 |
      | conn_0 | False   | delete from schema2.global_t2 where name in (select a.name from schema1.global_t1 a join schema2.global_t3 b on a.id =b.id where a.age in ((select age from (select name,age from schema2.global_t4 order by id desc) as tmp)));                 | This `Complex Delete Syntax` is not supported!  | schema2 |
      #case: the node of the final route of the subquery cannot cover the operated table
      | conn_0 | False   | update schema2.global_t3 set age=age+1 where name in ((select age from (select name,age from schema2.global_t2 order by id desc) as tmp));      | This `Complex Update Syntax` is not supported!  | schema2 |
      | conn_0 | False   | delete from schema2.global_t3 where name in ((select age from (select name,age from schema2.global_t2 order by id desc) as tmp));               | This `Complex Delete Syntax` is not supported!  | schema2 |
      ##has privilege and has Subquery and update/delete the operated table is sharding table
      # prepare sql
      | conn_0 | False   | drop table if exists schema1.sharding_3_t1;                                                    | success           | schema1 |
      | conn_0 | False   | create table schema1.sharding_3_t1(id int,name char(20),age int);                              | success           | schema1 |
      | conn_0 | False   | insert into schema1.sharding_3_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema1 |
      | conn_0 | False   | update schema1.sharding_2_t1 set age=age+1 where name in (select name from schema1.sharding_3_t1  where age =1);   | This `Complex Update Syntax` is not supported!  | schema1 |
      | conn_0 | False   | delete from schema1.sharding_2_t1  where name in (select name from schema1.sharding_3_t1  where age =1);           | This `Complex Delete Syntax` is not supported!  | schema1 |
      ##has privilege and has Subquery and update/delete the operated table is vertical sharding table
      # prepare sql
      | conn_0 | False   | drop table if exists schema3.t4;                                                    | success           | schema3 |
      | conn_0 | False   | drop table if exists schema3.t5;                                                    | success           | schema3 |
      | conn_0 | False   | drop table if exists schema3.t6;                                                    | success           | schema3 |
      | conn_0 | False   | drop table if exists schema4.t1;                                                    | success           | schema4 |
      | conn_0 | False   | create table schema3.t4(id int,name char(20),age int);                              | success           | schema3 |
      | conn_0 | False   | create table schema3.t5(id int,name char(20),age int);                              | success           | schema3 |
      | conn_0 | False   | create table schema3.t6(id int,name char(20),age int);                              | success           | schema3 |
      | conn_0 | False   | create table schema4.t1(id int,name char(20),age int);                              | success           | schema4 |
      | conn_0 | False   | insert into schema3.t4 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema3 |
      | conn_0 | False   | insert into schema3.t5 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema3 |
      | conn_0 | False   | insert into schema3.t6 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema3 |
      | conn_0 | False   | insert into schema4.t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema4 |
     #case: the subquery is routed to the node corresponding to the vertical sharding table
      | conn_0 | False   | update schema3.t3 set age=age+1 where name in (select a.name from schema2.global_t2 a join schema2.single_t2 b on a.id =b.id where a.age in (select age from schema1.sharding_2_t1 where id=4));   | success                                              | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                         | has{(1,'1',1),(2,'2',2),(3,'3',3),(4,'4',5),(5,'5',5),(6,'6',6)} | schema3 |
      | conn_0 | False   | delete from schema3.t3 where name in (select a.name from schema2.global_t2 a join schema2.single_t2 b on a.id =b.id where a.age in (select age from schema1.sharding_2_t1 where id=4));            | success                                              | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                         | has{(1,'1',1),(2,'2',2),(3,'3',3),(5,'5',5),(6,'6',6)}           | schema3 |
      | conn_0 | False   | update schema3.t3 set age=age+1 where name in (select a.name from schema3.t5 a join schema3.t6 b on a.id =b.id where a.age in ((select age from (select name,age from schema2.global_t2 order by id desc) as tmp)));   | success                                              | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                         | has{(1,'1',2),(2,'2',3),(3,'3',4),(5,'5',6),(6,'6',7)}           | schema3 |
      | conn_0 | False   | delete from schema3.t3 where name in (select a.name from schema3.t5 a join schema3.t6 b on a.id =b.id where a.age in ((select age from (select name,age from schema2.global_t2 order by id desc) as tmp)));            | success                                              | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                         | length{(0)}                                                      | schema3 |
      | conn_0 | False   | insert into schema3.t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema3 |
      #case: the subquery is connot routed to the node corresponding to the vertical sharding table
      | conn_0 | False   | update schema3.t3 set age=age+1 where name in (select a.name from schema2.global_t2 a join schema2.single_t2 b on a.id =b.id where a.age in (select age from schema1.sharding_2_t1 where id=3));   | This `Complex Update Syntax` is not supported!     | schema3 |
      | conn_0 | False   | delete from schema3.t3 where name in (select a.name from schema2.global_t2 a join schema2.single_t2 b on a.id =b.id where a.age in (select age from schema1.sharding_2_t1 where id=3));            | This `Complex Delete Syntax` is not supported!     | schema3 |
      #case: only the tables of in the same vertical sharding table node are involved in the subquery
      | conn_0 | False   | update schema3.t3 set age=age+1,name=name-1 where name in (select a.name from schema3.t4 a join schema3.t5 b on a.id =b.id where a.age in (select age from schema3.t6 where id in ((select id from (select id,age from schema3.t4 order by id desc) as tmp))));   | success                                              | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                         | has{(1,'0',2),(2,'1',3),(3,'2',4),(4,'3',5),(5,'4',6),(6,'5',7)} | schema3 |
      | conn_0 | False   | delete from schema3.t3 where name in (select a.name from schema3.t4 a join schema3.t5 b on a.id =b.id where a.age in (select age from schema3.t6 where id in ((select id from (select id,age from schema3.t4 where id =1) as tmp))));                             | success                                              | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                         | has{(1,'0',2),(3,'2',4),(4,'3',5),(5,'4',6),(6,'5',7)}           | schema3 |
      #case: the tables of in the different vertical sharding table node are involved in the subquery
      | conn_0 | False   | update schema3.t3 set age=age+1,name=name-1 where name in (select a.name from schema3.t4 a join schema3.t5 b on a.id =b.id where a.age in (select age from schema3.t6 where id in ((select id from (select id,age from schema4.t1 order by id desc) as tmp))));     | This `Complex Update Syntax` is not supported!  | schema3 |
      | conn_0 | False   | delete from schema3.t3 where name in (select a.name from schema3.t4 a join schema3.t5 b on a.id =b.id where a.age in (select age from schema3.t6 where id in ((select id from (select id,age from schema4.t1 where id =1) as tmp))));                               | This `Complex Delete Syntax` is not supported!  | schema3 |

  Scenario: check update/delete  from .... syntax and some tables #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="single_t1" shardingNode="dn6" />
        <globalTable name="global_t1" shardingNode="dn1,dn2" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_3_t1" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <schema name="schema2" sqlMaxLimit="100">
        <singleTable name="single_t2" shardingNode="dn1" />
        <singleTable name="single_t3" shardingNode="dn6" />
        <globalTable name="global_t2" shardingNode="dn1,dn2" />
        <globalTable name="global_t3" shardingNode="dn5,dn6" />
        <globalTable name="global_t4" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <schema shardingNode="dn1" name="schema3"/>
    <schema shardingNode="dn2" name="schema4"/>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />

     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
     <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3,schema4">
          <privileges check="true">
            <schema name="schema3" dml="1111">
              <table name="t1" dml="1101"/>
              <table name="t2" dml="1010"/>
            </schema>
          </privileges>
        </shardingUser>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      # prepare sql
      | conn   | toClose | sql                                                                                 | expect                | db      |
      | conn_0 | False   | drop table if exists schema3.t2;                                                    | success               | schema3 |
      | conn_0 | False   | drop table if exists schema3.t3;                                                    | success               | schema3 |
      | conn_0 | False   | create table schema3.t2(id int,name char(20),age int);                              | success               | schema3 |
      | conn_0 | False   | create table schema3.t3(id int,name char(20),age int);                              | success               | schema3 |
      | conn_0 | False   | insert into schema3.t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success               | schema3 |
      | conn_0 | False   | insert into schema3.t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success               | schema3 |
      ##case: no privilege
      | conn_0 | False   | update schema3.t2 a,schema3.t3 b set a.age=b.age+1 where a.id=2;                 | The statement DML privilege check is not passe      | schema3 |
      | conn_0 | False   | delete from schema3.t2 a,schema3.t3 b where a.id=b.id and b.name=1 ;             | The statement DML privilege check is not passe      | schema3 |
      ##case: has privilege and has Subquery (where)
      | conn_0 | False   | drop table if exists schema3.t4;                                                    | success               | schema3 |
      | conn_0 | False   | drop table if exists schema3.t5;                                                    | success               | schema3 |
      | conn_0 | False   | create table schema3.t4(id int,name char(20),age int);                              | success               | schema3 |
      | conn_0 | False   | create table schema3.t5(id int,name char(20),age int);                              | success               | schema3 |
      | conn_0 | False   | insert into schema3.t4 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success               | schema3 |
      | conn_0 | False   | insert into schema3.t5 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success               | schema3 |
      | conn_0 | False   | update schema3.t3 a,schema3.t4 b set a.age=b.age+1 where a.name=b.name and a.id=(select id from schema3.t5 where name=2);        | This `Complex Update Syntax` is not supported!   | schema3 |
      | conn_0 | False   | delete from  schema3.t3 a,schema3.t4 b where a.name=b.name and a.id=(select id from schema3.t5 where name=2);                    | This `Complex Delete Syntax` is not supported!   | schema3 |
      ##case: has privilege and no Subquery and update/delete the operated all tables is single table
      # prepare sql
      | conn_0 | False   | drop table if exists schema1.single_t1;                                                    | success           | schema1 |
      | conn_0 | False   | drop table if exists schema2.single_t2;                                                    | success           | schema2 |
      | conn_0 | False   | drop table if exists schema2.single_t3;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema1.single_t1(id int,name char(20),age int);                              | success           | schema1 |
      | conn_0 | False   | create table schema2.single_t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | create table schema2.single_t3(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema1.single_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema1 |
      | conn_0 | False   | insert into schema2.single_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | insert into schema2.single_t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      #case: all tables correspond to the same node
      | conn_0 | False   | update schema1.single_t1 a,schema2.single_t3 b set a.age=b.age+1,b.name=a.name-1 where a.name=b.name;                      | success                                                            | schema1 |
      | conn_0 | False   | select * from schema1.single_t1;                                                                                           | has{(1,'1',2),(2,'2',3),(3,'3',4),(4,'4',5),(5,'5',6),(6,'6',7)}   | schema1 |
      | conn_0 | False   | select * from schema2.single_t3;                                                                                           | has{(1,'0',1),(2,'1',2),(3,'2',3),(4,'3',4),(5,'4',5),(6,'5',6)}   | schema2 |
      | conn_0 | False   | delete schema1.single_t1 from schema1.single_t1,schema2.single_t3 where schema1.single_t1.name=schema2.single_t3.name;     | success                                                            | schema1 |
      | conn_0 | False   | select * from schema1.single_t1;                                                                                           | has{(6,'6',7)}                                                     | schema1 |
      | conn_0 | False   | drop table if exists schema1.single_t1;                                                                                    | success                                                            | schema1 |
      | conn_0 | False   | create table schema1.single_t1(id int,name char(20),age int);                                                              | success                                                            | schema1 |
      | conn_0 | False   | insert into schema1.single_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);                                      | success                                                            | schema1 |
      #case: all tables correspond to the different node
      | conn_0 | False   | update schema1.single_t1 a,schema2.single_t2 b set a.age=b.age+1,b.name=a.name-1 where a.name=b.name;                             | This `Complex Update Syntax` is not supported!   | schema1 |
      | conn_0 | False   | delete schema1.single_t1 from schema1.single_t1,schema2.single_t2 where schema1.single_t1.name=schema2.single_t2.name;            | This `Complex Delete Syntax` is not supported!   | schema1 |
      ##case: has privilege and no Subquery and update/delete the operated all tables is global table
      # prepare sql
      | conn_0 | False   | drop table if exists schema1.global_t1;                                                    | success           | schema1 |
      | conn_0 | False   | drop table if exists schema2.global_t2;                                                    | success           | schema2 |
      | conn_0 | False   | drop table if exists schema2.global_t4;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema1.global_t1(id int,name char(20),age int);                              | success           | schema1 |
      | conn_0 | False   | create table schema2.global_t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | create table schema2.global_t4(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema1.global_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema1 |
      | conn_0 | False   | insert into schema2.global_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | insert into schema2.global_t4 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      #case: the tables have the same node
      | conn_0 | False   | update schema1.global_t1 a,schema2.global_t2 b set a.age=b.age+1,b.name=a.name-1 where a.name=b.name;                                    | success                                                            | schema1 |
      | conn_0 | False   | select * from schema1.global_t1;                                                                                                         | has{(1,'1',2),(2,'2',3),(3,'3',4),(4,'4',5),(5,'5',6),(6,'6',7)}   | schema1 |
      | conn_0 | False   | select * from schema2.global_t2;                                                                                                         | has{(1,'0',1),(2,'1',2),(3,'2',3),(4,'3',4),(5,'4',5),(6,'5',6)}   | schema2 |
      | conn_0 | False   | delete schema1.global_t1,schema2.global_t2 from schema1.global_t1,schema2.global_t2 where schema1.global_t1.name=schema2.global_t2.name; | success                                                            | schema1 |
      | conn_0 | False   | select * from schema1.global_t1;                                                                                                         | has{(6,'6',7)}                                                     | schema1 |
      | conn_0 | False   | select * from schema2.global_t2;                                                                                                         | has{(1,'0',1)}                                                        | schema2 |
      | conn_0 | False   | insert into schema1.global_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);                                                    | success                                                            | schema1 |
      | conn_0 | False   | insert into schema2.global_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);                                                    | success                                                            | schema2 |
      #case: the tables have a different node
      | conn_0 | False   | update schema1.global_t1 a,schema2.global_t4 b set a.age=b.age+1,b.name=a.name-1 where a.name=b.name;                                    | This `Complex Update Syntax` is not supported!         | schema1 |
      | conn_0 | False   | delete schema1.global_t1,schema2.global_t4 from schema1.global_t1,schema2.global_t2 where schema1.global_t1.name=schema2.global_t2.name; | This `Complex Delete Syntax` is not supported!         | schema1 |
      ##case: has privilege and no Subquery and update/delete the operated all tables is vertical sharding table
      # prepare sql
      | conn_0 | False   | drop table if exists schema4.t1;                                                    | success           | schema2 |
      | conn_0 | False   | drop table if exists schema4.t2;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema4.t1(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | create table schema4.t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema4.t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      | conn_0 | False   | insert into schema4.t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      #case: all tables are on the same vertical sharding node
      | conn_0 | False   | update schema3.t3 a,schema3.t4 b set a.age=b.age+1,b.name=a.name-1 where a.name=b.name and a.age=1;                               | success                                                            | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                                                                                         | has{(1,'1',2),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}   | schema3 |
      | conn_0 | False   | select * from schema3.t4;                                                                                                         | has{(1,'0',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}   | schema3 |
      | conn_0 | False   | delete schema3.t3,schema3.t5 from schema3.t3,schema3.t5 where schema3.t3.name=schema3.t5.name and schema3.t5.age=1;               | success                                                            | schema3 |
      | conn_0 | False   | select * from schema3.t3;                                                                                                         | has{(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}             | schema3 |
      | conn_0 | False   | select * from schema3.t5;                                                                                                         | has{(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}             | schema3 |
      #case: have one table are on the different vertical sharding node
      | conn_0 | False   | update schema3.t3 a,schema4.t1 b set a.age=b.age+1,b.name=a.name-1 where a.name=b.name and a.age=1;                                      | This `Complex Update Syntax` is not supported!         | schema3 |
      | conn_0 | False   | delete schema3.t3,schema4.t2 from schema3.t3,schema4.t2 where schema3.t3.name=schema4.t2.name and schema4.t2.age=1;                      | This `Complex Delete Syntax` is not supported!         | schema3 |
      ##case: has privilege and no Subquery and update/delete the operated all tables is sharding table
      # prepare sql
      | conn_0 | False   | drop table if exists schema1.sharding_4_t1;                                                    | success           | schema1 |
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2;                                                    | success           | schema2 |
      | conn_0 | False   | create table schema1.sharding_4_t1(id int,name char(20),age int);                              | success           | schema1 |
      | conn_0 | False   | create table schema2.sharding_4_t2(id int,name char(20),age int);                              | success           | schema2 |
      | conn_0 | False   | insert into schema1.sharding_4_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema1 |
      | conn_0 | False   | insert into schema2.sharding_4_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema2 |
      #case: have where condition and route to the same node
      | conn_0 | False   | update schema1.sharding_4_t1 a,schema2.sharding_4_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=1 and b.id=1;                               | success                                                            | schema1 |
      | conn_0 | False   | select * from schema1.sharding_4_t1;                                                                                                            | has{(1,'1',2),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}   | schema1 |
      | conn_0 | False   | select * from schema2.sharding_4_t2;                                                                                                            | has{(1,'0',1),(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}   | schema2 |
      | conn_0 | False   | delete schema1.sharding_4_t1 from schema1.sharding_4_t1,schema2.sharding_4_t2 where schema1.sharding_4_t1.id=1 and schema2.sharding_4_t2.id =1; | success                                                            | schema1 |
      | conn_0 | False   | select * from schema1.sharding_4_t1;                                                                                                            | has{(2,'2',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}             | schema1 |
      #case: have where condition and route to the different node
      | conn_0 | False   | update schema1.sharding_4_t1 a,schema2.sharding_4_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=1 and b.id=2;                                     | This `Complex Update Syntax` is not supported!         | schema1 |
      | conn_0 | False   | delete schema1.sharding_4_t1 from schema1.sharding_4_t1,schema2.sharding_4_t2 where schema1.sharding_4_t1.id=1 and schema2.sharding_4_t2.id =2;       | This `Complex Delete Syntax` is not supported!         | schema1 |
      #case: no have where condition
      | conn_0 | False   | update schema1.sharding_4_t1 a,schema2.sharding_4_t2 b set a.age=b.age+1,b.name=a.name-1                    | This `Complex Update Syntax` is not supported!         | schema1 |
      | conn_0 | False   | delete schema1.sharding_4_t1 from schema1.sharding_4_t1,schema2.sharding_4_t2                               | This `Complex Delete Syntax` is not supported!         | schema1 |
      ##case: has privilege and no Subquery and update/delete the operated all tables is different table
      #case: only have single table and sharding table but no have where condition
      | conn_0 | False   | update schema1.sharding_2_t1 a,schema2.single_t2 b set a.age=b.age+1,b.name=a.name-1;                    | This `Complex Update Syntax` is not supported!         | schema1 |
      | conn_0 | False   | delete schema1.sharding_2_t1 from schema1.sharding_2_t1,schema2.single_t2 ;                              | This `Complex Delete Syntax` is not supported!         | schema1 |
      # prepare sql
      | conn_0 | False   | drop table if exists schema1.sharding_2_t1;                                                    | success           | schema1 |
      | conn_0 | False   | drop table if exists schema2.single_t3;                                                        | success           | schema2 |
      | conn_0 | False   | create table schema1.sharding_2_t1(id int,name char(20),age int);                              | success           | schema1 |
      | conn_0 | False   | create table schema2.single_t3(id int,name char(20),age int);                                  | success           | schema2 |
      | conn_0 | False   | insert into schema1.sharding_2_t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);      | success           | schema1 |
      | conn_0 | False   | insert into schema2.single_t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6);          | success           | schema2 |
      #case: only have single table and sharding table and have where condition and  route to the same node
      | conn_0 | False   | update schema1.sharding_2_t1 a,schema2.single_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=2 and b.id=2;                                   | success                                                            | schema1 |
      | conn_0 | False   | select * from schema1.sharding_2_t1;                                                                                                            | has{(1,'1',1),(2,'2',3),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}   | schema1 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                                                                | has{(1,'1',1),(2,'1',2),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}   | schema2 |
      | conn_0 | False   | delete schema2.single_t2 from schema1.sharding_2_t1,schema2.single_t2 where schema1.sharding_2_t1.id=2 and schema2.single_t2.id =2;             | success                                                            | schema1 |
      | conn_0 | False   | select * from schema2.single_t2;                                                                                                                | has{(1,'1',1),(3,'3',3),(4,'4',4),(5,'5',5),(6,'6',6)}             | schema2 |
      #case: only have single table and sharding table and have where condition and route to the different node
      | conn_0 | False   | update schema1.sharding_2_t1 a,schema2.single_t3 b set a.age=b.age+1,b.name=a.name-1 where a.id=2 and b.id=1;                                   | This `Complex Update Syntax` is not supported!         | schema1 |
      | conn_0 | False   | delete schema2.single_t3 from schema1.sharding_2_t1,schema2.single_t3 where schema1.sharding_2_t1.id=2 and schema3.single_t2.id =2;             | This `Complex Delete Syntax` is not supported!         | schema2 |
      #case: have global table
      | conn_0 | False   | update schema1.sharding_2_t1 a,schema2.global_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=1 and b.id=1;          | This `Complex Update Syntax` is not supported!         | schema1 |
      | conn_0 | False   | delete schema1.sharding_2_t1 from schema1.sharding_2_t1,schema2.global_t2 where schema1.sharding_2_t1.id=1             | This `Complex Delete Syntax` is not supported!         | schema1 |
      #case: some issue
      | conn_0 | False   | update schema2.sharding_2_t1 a,db1.single_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=2 and b.id=1;                                       | Table `db1`.`single_t2` doesn't exist          | schema1 |
      | conn_0 | False   | update db1.sharding_2_t1 a,schema2.single_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=2 and b.id=1;                                       | Table `db1`.`sharding_2_t1` doesn't exist      | schema1 |
      | conn_0 | False   | delete db1.single_t2 from schema1.sharding_2_t1,schema2.single_t2 where schema1.sharding_2_t1.id=2 and schema2.single_t2.id =2;                 | Table `db1`.`single_t2` doesn't exist          | schema1 |
      | conn_0 | False   | delete schema2.single_t2 from schema1.sharding_2_t1,schema2.single_t2 where db1.sharding_2_t1.id=2 and schema2.single_t2.id =2;                 | Table db1.sharding_2_t1 not exists         | schema1 |
