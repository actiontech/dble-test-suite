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