# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/9/14
Feature: test " check @@global schema = '' [and table = '']"

  @skip_restart
  Scenario: check @@global schema = '' [and table = ''] #1

  #case global table exists with not global check
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect                                                       |
      | conn_0 | False   | check @@global                                     | length{(0)}                                                  |
      | conn_0 | False   | check @@global schema='schema1'                    | length{(0)}                                                  |
      | conn_0 | False   | check @@global schema='schema1' and table = 'test' | tables must exist and must be global table with global check |
      | conn_0 | False   | check @@global schema='schema2' and table = 'test' | schema must exists                                           |
      | conn_0 | true    | check @@global schema='schema1' and table = 't1'   | tables must exist and must be global table with global check |

  #case the more global table
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="g1" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
        <globalTable name="g2" shardingNode="dn1,dn3" />
    </schema>

    <schema shardingNode="dn1" name="schema2" >
        <globalTable name="g3" shardingNode="dn1,dn2" cron="/10 * * * * ? " checkClass="COUNT" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
       <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config"




    
  #case change sharding.xml add global check and reload
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="g1" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
        <globalTable name="g2" shardingNode="dn1,dn3" />
    </schema>

    <schema shardingNode="dn1" name="schema2" >
        <globalTable name="g3" shardingNode="dn1,dn2" cron="/10 * * * * ? " checkClass="COUNT" />
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
       <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config"
  #case global table meta not exists
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                            | expect  |
      | conn_1 | false    | use schema1                                    | success |
      | conn_1 | false    | drop table if exists g1                        | success |
      | conn_1 | false    | use schema2                                    | success |
      | conn_1 | true     | drop table if exists g3                        | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect                                                         |
      | conn_0 | False   | check @@global schema='schema1' and table = 'g1'   | has{(('schema1', 'g1', 0, 0),)}                                |
      | conn_0 | False   | check @@global schema='schema1' and table = 'g2'   | tables must exist and must be global table with global check   |
      | conn_0 | true    | check @@global schema='schema2' and table = 'g3'   | has{(('schema2', 'g3', 0, 0),)}                                |
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global check start .........g1
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global check skip because of Meta
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global check start .........g3
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global check skip because of Meta
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global check start .........g2
    """

   #case global table meta exists
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                           | expect  |
      | conn_1 | false    | use schema1                                   | success |
      | conn_1 | false    | create table g1(id int,name int)              | success |
      | conn_1 | false    | use schema2                                   | success |
      | conn_1 | True     | create table g3(id int,name int)              | success |
    Given delete file "/opt/dble/logs/dble.log" on "dble-1"
    Given Restart dble in "dble-1" success
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check success for table :schema1-g1
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check success for table :schema2-g3
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global check skip because of Meta
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect                              |
      | conn_0 | False   | check @@global schema='schema1' and table = 'g1'   | has{(('schema1', 'g1', 1, 0),)}     |
      | conn_0 | true    | check @@global schema='schema2' and table = 'g3'   | has{(('schema2', 'g3', 1, 0),)}     |

   #case the global table data different
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                           | expect  |
      | conn_1 | false    | insert into schema1.g1 values (1,1),(2,2)     | success |
      | conn_1 | True     | insert into schema2.g3 values (3,3),(4,4)     | success |
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                           | expect   |
      | conn_2 | False    | delete from db1.g1 where id=1 | success  |
      | conn_2 | true     | delete from db1.g3 where id=3 | success  |
    Given delete file "/opt/dble/logs/dble.log" on "dble-1"
    Given Restart dble in "dble-1" success
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check fail for table :schema1-g1
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check fail for table :schema2-g3
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check success for table :schema1-g1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check success for table :schema2-g3
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect                              |
      | conn_0 | False   | check @@global schema='schema1' and table = 'g1'   | has{(('schema1', 'g1', 2, 0),)}     |
      | conn_0 | true    | check @@global schema='schema2' and table = 'g3'   | has{(('schema2', 'g3', 2, 0),)}     |

   #case the global table one shardingNode is not created, others shardingNode are created and the same
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                           | expect   |
      | conn_2 | False    | drop table if exists db1.g1   | success  |
      | conn_2 | true     | drop table if exists db1.g3   | success  |
    Given delete file "/opt/dble/logs/dble.log" on "dble-1"
    Given Restart dble in "dble-1" success
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check fail for table :schema1-g1
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check fail for table :schema2-g3
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check success for table :schema1-g1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check success for table :schema2-g3
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect                              |
      | conn_0 | False   | check @@global schema='schema1' and table = 'g1'   | has{(('schema1', 'g1', 2, 0),)}     |
      | conn_0 | true    | check @@global schema='schema2' and table = 'g3'   | has{(('schema2', 'g3', 1, 1),)}     |

   #case the global table one shardingNode is not created, others shardingNode are created and not the same
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                               | expect   |
      | conn_2 | False    | insert into db2.g1 values (5,5)   | success  |
      | conn_2 | true     | insert into db2.g3 values (6,6)   | success  |
    Given delete file "/opt/dble/logs/dble.log" on "dble-1"
    Given Restart dble in "dble-1" success
    Given sleep "11" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check fail for table :schema1-g1
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check fail for table :schema2-g3
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check success for table :schema1-g1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check success for table :schema2-g3
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect                              |
      | conn_0 | False   | check @@global schema='schema1' and table = 'g1'   | has{(('schema1', 'g1', 3, 0),)}     |
      | conn_0 | true    | check @@global schema='schema2' and table = 'g3'   | has{(('schema2', 'g3', 1, 1),)}     |

   #case the mysql down
    Given stop mysql in host "mysql-master1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       error node is : null-null
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check fail for table :schema1-g1
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
       Global Consistency Check fail for table :schema2-g3
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect                              |
      | conn_0 | False   | check @@global schema='schema1' and table = 'g1'   | has{(('schema1', 'g1', 1, 2),)}     |
      | conn_0 | true    | check @@global schema='schema2' and table = 'g3'   | has{(('schema2', 'g3', 1, 1),)}     |



