# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2022/5/12
Feature: Transaction query error due to connection used error

  # according to http://10.186.18.11/jira/browse/DBLE0REQ-1744
  Scenario: connection distinguished with two ways
    # backend connection naming changed liked:  shardingNode-flag-{schema.table},
    # flag is a variable with boolean
    # true: connection distinguished with shardingNode && schema.table
    # false: connection distinguished only with shardingNode, schema.table will not participate in distinguished connections
    # only sql contains duplicate nodes, flag is true

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
          <shardingTable name="table1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
          <shardingTable name="table2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="code"/>
          <globalTable name="pm_rule_edit"  shardingNode="dn1,dn2"/>
          <globalTable name="pm_rule"  shardingNode="dn1,dn2"/>
        </schema>
      """
    Given execute admin cmd "reload @@config_all" success
    # dble.log not easy and not necessary to verify, more details could find in dble.log

    # shardingNode-true-{schema.table}【complex query】 && shardingNode-false-{schema.table}【delete from table2】
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect      | db      |
      | conn_0 | False   | drop table if exists table1                                      | success     | schema1 |
      | conn_0 | False   | drop table if exists table2                                      | success     | schema1 |
      | conn_0 | False   | create table table1(id int)                                      | success     | schema1 |
      | conn_0 | False   | create table table2(id int, code int)                            | success     | schema1 |
      | conn_0 | False   | insert  into table1 values(1),(2),(3)                            | success     | schema1 |
      | conn_0 | False   | insert into  table2 values(1,1),(2,2),(3,3)                      | success     | schema1 |
      | conn_0 | False   | begin                                                            | success     | schema1 |
      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(3)} | schema1 |
      | conn_0 | False   | delete from table2                                               | success     | schema1 |
      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(0)} | schema1 |
      | conn_0 | False   | commit                                                           | success     | schema1 |
      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(0)} | schema1 |

    # shardingNode-false-{schema.table}
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect      | db      |
      | conn_0 | False   | drop table if exists pm_rule                                     | success     | schema1 |
      | conn_0 | False   | drop table if exists pm_rule_edit                                | success     | schema1 |
      | conn_0 | False   | create table pm_rule(id int, state varchar(20))                  | success     | schema1 |
      | conn_0 | False   | create table pm_rule_edit(id int, state varchar(20))             | success     | schema1 |
      | conn_0 | False   | insert  into pm_rule_edit values(449, 'SOA')                     | success     | schema1 |
      | conn_0 | False   | begin                                                            | success     | schema1 |
      | conn_0 | False   | update pm_rule_edit set state='S0X' where id=449                 | success     | schema1 |
      | conn_0 | False   | delete from pm_rule                                              | success     | schema1 |
      | conn_0 | False   | insert into pm_rule select * from pm_rule_edit where id=449      | success     | schema1 |
      | conn_0 | False   | select state from pm_rule where id = 449                         | has{(('S0X',),)}     | schema1 |
      | conn_0 | False   | select state from pm_rule_edit where id = 449                    | has{(('S0X',),)}     | schema1 |
      | conn_0 | False   | commit                                                           | success     | schema1 |
      | conn_0 | False   | select state from pm_rule where id = 449                         | has{(('S0X',),)}     | schema1 |
      | conn_0 | False   | select state from pm_rule_edit where id = 449                    | has{(('S0X',),)}     | schema1 |

# issue: http://10.186.18.11/jira/browse/DBLE0REQ-1757
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                                              | expect      | db      |
#      | conn_0 | False   | insert  into table1 values(1),(2),(3)                            | success     | schema1 |
#      | conn_0 | False   | begin                                                            | success     | schema1 |
#      | conn_0 | False   | delete from table2                                               | success     | schema1 |
#      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(0)} | schema1 |
#      | conn_0 | False   | commit                                                           | success     | schema1 |
#      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(0)} | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect      | db      |
      | conn_0 | False   | drop table if exists table1                                      | success     | schema1 |
      | conn_0 | False   | drop table if exists table2                                      | success     | schema1 |
      | conn_0 | False   | drop table if exists pm_rule                                     | success     | schema1 |
      | conn_0 | False   | drop table if exists pm_rule_edit                                | success     | schema1 |

