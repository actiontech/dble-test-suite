# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2020/11/30

Feature: test sqlMaxLimit for all types of table
  @NORMAL
  Scenario: test the sqlMaxLimit of table is prior to the sqlMaxLimit of schema #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="-1">
        <singleTable name="sharding_1_t1" shardingNode="dn5" sqlMaxLimit="2"/>
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" sqlMaxLimit="3"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" sqlMaxLimit="4">
           <childTable name="tb_child1" joinColumn="id" parentColumn="id" sqlMaxLimit="3">
                <childTable name="tb_grandson1" joinColumn="id" parentColumn="id" sqlMaxLimit="2" />
                <childTable name="tb_grandson2" joinColumn="id" parentColumn="id" sqlMaxLimit="4"/>
            </childTable>
        </shardingTable>
        <globalTable name="global_4_t1" shardingNode="dn1,dn2,dn3,dn4" sqlMaxLimit="6" />
    </schema>

    <schema name="schema2" shardingNode="dn5" sqlMaxLimit="4">
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" sqlMaxLimit="-1"/>
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" sqlMaxLimit="3"/>
        <globalTable name="global_4_t1" shardingNode="dn1,dn2,dn3,dn4" sqlMaxLimit="5" />
        <globalTable name="global_4_t2" shardingNode="dn1,dn2,dn3,dn4" />
    </schema>

    <schema name="schema3" shardingNode="dn5" sqlMaxLimit="3">
    </schema>
    """
   Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
       <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    """
  Then execute admin cmd "reload @@config_all"
  Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                      | expect                         | db      |
      | conn_0 | False   | drop table if exists nosharding                                                      | success                        | schema1 |
      | conn_0 | False   | create table nosharding(id int)                                                      | success                       | schema1 |
      | conn_0 | False   | insert into nosharding values(1),(2),(3),(4),(5),(6),(7),(8)                     | success                        | schema1 |
      | conn_0 | False   | drop table if exists sharding_1_t1                                                   | success                        | schema1 |
      | conn_0 | False   | create table sharding_1_t1(id int)                                                   | success                       | schema1 |
      | conn_0 | False   | insert into sharding_1_t1 values(1),(2),(3),(4),(5),(6),(7),(8)                  | success                        | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                   | success                        | schema1 |
      | conn_0 | False   | create table sharding_2_t1(id int)                                                   | success                        | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values(1),(2),(3),(4),(5),(6),(7),(8)                  | success                        | schema1 |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                   | success                        | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)                                                   | success                        | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4),(5),(6),(7),(8)                  | success                        | schema1 |
      | conn_0 | False   | drop table if exists global_4_t1                                                      | success                        | schema1 |
      | conn_0 | False   | create table global_4_t1(id int)                                                      | success                        | schema1 |
      | conn_0 | False   | insert into global_4_t1 values(1),(2),(3),(4),(5),(6),(7),(8)                     | success                        | schema1 |

      | conn_0 | False   | drop table if exists tb_child1                                                        | success                        | schema1 |
      | conn_0 | False   | create table tb_child1(id int)                                                        | success                        | schema1 |
      | conn_0 | False   | insert into tb_child1 values(1)                                                       | success                        | schema1 |
      | conn_0 | False   | insert into tb_child1 values(2)                                                       | success                        | schema1 |
      | conn_0 | False   | insert into tb_child1 values(3)                                                       | success                        | schema1 |
      | conn_0 | False   | insert into tb_child1 values(4)                                                       | success                        | schema1 |
      | conn_0 | False   | insert into tb_child1 values(5)                                                       | success                        | schema1 |
      | conn_0 | False   | insert into tb_child1 values(6)                                                       | success                        | schema1 |

      | conn_0 | False   | drop table if exists tb_grandson1                                                      | success                        | schema1 |
      | conn_0 | False   | create table tb_grandson1(id int)                                                      | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson1 values(1)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson1 values(2)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson1 values(3)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson1 values(4)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson1 values(5)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson1 values(6)                                                     | success                        | schema1 |

      | conn_0 | False   | drop table if exists tb_grandson2                                                      | success                        | schema1 |
      | conn_0 | False   | create table tb_grandson2(id int)                                                      | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson2 values(1)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson2 values(2)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson2 values(3)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson2 values(4)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson2 values(5)                                                     | success                        | schema1 |
      | conn_0 | False   | insert into tb_grandson2 values(6)                                                     | success                        | schema1 |

      | conn_0 | False   | drop table if exists schema2.nosharding2                                               | success                        | schema1 |
      | conn_0 | False   | create table schema2.nosharding2(id int)                                               | success                        | schema1 |
      | conn_0 | False   | insert into schema2.nosharding2 values(1),(2),(3),(4),(5),(6),(7),(8)              | success                        | schema1 |

      | conn_0 | False   | drop table if exists schema2.sharding_4_t2                                             | success                        | schema1 |
      | conn_0 | False   | create table schema2.sharding_4_t2(id int)                                             | success                        | schema1 |
      | conn_0 | False   | insert into schema2.sharding_4_t2 values(1),(2),(3),(4),(5),(6),(7),(8)            | success                        | schema1 |

      | conn_0 | False   | drop table if exists schema2.sharding_4_t3                                             | success                        | schema1 |
      | conn_0 | False   | create table schema2.sharding_4_t3(id int)                                              | success                        | schema1 |
      | conn_0 | False   | insert into schema2.sharding_4_t3 values(1),(2),(3),(4),(5),(6),(7),(8)             | success                        | schema1 |

      | conn_0 | False   | drop table if exists schema2.global_4_t1                                                | success                        | schema1 |
      | conn_0 | False   | create table schema2.global_4_t1(id int)                                                 | success                        | schema1 |
      | conn_0 | False   | insert into schema2.global_4_t1 values(1),(2),(3),(4),(5),(6),(7),(8)                | success                        | schema1 |

      | conn_0 | False   | drop table if exists schema2.global_4_t2                                                 | success                        | schema1 |
      | conn_0 | False   | create table schema2.global_4_t2(id int)                                                 | success                        | schema1 |
      | conn_0 | False   | insert into schema2.global_4_t2 values(1),(2),(3),(4),(5),(6),(7),(8)                | success                        | schema1 |

      | conn_0 | False   | drop table if exists schema3.nosharding3_1                                                | success                        | schema1 |
      | conn_0 | False   | create table schema3.nosharding3_1(id int)                                               | success                        | schema1 |
      | conn_0 | False   | insert into schema3.nosharding3_1 values(1),(2),(3),(4),(5),(6),(7),(8)              | success                        | schema1 |
      | conn_0 | False   | drop table if exists schema3.nosharding3_2                                                | success                        | schema1 |
      | conn_0 | False   | create table schema3.nosharding3_2(id int)                                               | success                        | schema1 |
      | conn_0 | False   | insert into schema3.nosharding3_2 values(1),(2),(3),(4),(5),(6),(7),(8)               | success                        | schema1 |

      | conn_0 | False   | select * from nosharding                                                               | length{(8)}                   | schema1 |
      | conn_0 | False   | select * from sharding_1_t1                                                            | length{(2)}                   | schema1 |
      | conn_0 | False   | select * from sharding_2_t1                                                            | length{(3)}                    | schema1 |
      | conn_0 | False   | select * from sharding_4_t1                                                            | length{(4)}                     | schema1|
      | conn_0 | False   | select * from tb_child1                                                                | length{(3)}                     | schema1 |
      | conn_0 | False   | select * from tb_grandson1                                                             | length{(2)}                    | schema1 |
      | conn_0 | False   | select * from tb_grandson2                                                             | length{(4)}                    | schema1 |
      | conn_0 | False   | select * from tb_grandson2 limit 2                                                    | length{(2)}                    | schema1 |
      | conn_0 | False   | select * from global_4_t1                                                              | length{(6)}                    | schema1 |
      | conn_0 | False   | select * from global_4_t1 limit 3                                                    | length{(3)}                    | schema1 |

      | conn_0 | False   | select * from schema2.sharding_4_t2                                                   | length{(8)}                    | schema1 |
      | conn_0 | False   | select * from schema2.sharding_4_t3                                                   | length{(3)}                    | schema1 |
      | conn_0 | False   | select * from schema2.global_4_t1                                                     | length{(5)}                     | schema1 |
      | conn_0 | False   | select * from schema2.global_4_t2                                                      | length{(4)}                     | schema1 |
      | conn_0 | False   | select * from schema2.global_4_t2 limit 6                                             | length{(6)}                     | schema1 |

      | conn_0 | False   | select * from schema3.nosharding3_1                                                   | length{(3)}                     | schema1 |
      | conn_0 | False   | select * from schema3.nosharding3_2                                                   | length{(3)}                     | schema1 |

      | conn_0 | False   | drop table if exists nosharding_1                                                       | success                         | schema1 |
      | conn_0 | False   | drop table if exists sharding_1_t1                                                       | success                         | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                       | success                         | schema1 |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                       | success                         | schema1 |
      | conn_0 | False   | drop table if exists tb_child1                                                          | success                           | schema1 |
      | conn_0 | False   | drop table if exists tb_grandson1                                                       | success                         | schema1 |
      | conn_0 | False   | drop table if exists tb_grandson2                                                       | success                         | schema1 |
      | conn_0 | False   | drop table if exists tb_grandson2                                                       | success                         | schema1 |

      | conn_0 | False   | drop table if exists schema2.nosharding2                                               | success                         | schema1 |
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2                                             | success                         | schema1 |
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2                                             | success                         | schema1 |
      | conn_0 | False   | drop table if exists schema2.global_4_t1                                                | success                         | schema1 |
      | conn_0 | False   | drop table if exists schema2.global_4_t2                                               | success                         | schema1 |

      | conn_0 | False   | drop table if exists schema3.nosharding3_1                                             | success                         | schema1 |
      | conn_0 | True    | drop table if exists schema3.nosharding3_2                                             | success                         | schema1 |

