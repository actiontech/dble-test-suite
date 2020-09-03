# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_entry test

   Scenario:  dble_entry  table #1
  #case desc dble_entry
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_1"
      | conn   | toClose | sql             | db               |
      | conn_0 | False   | desc dble_entry | dble_information |
    Then check resultset "dble_entry_1" has lines with following column values
      | Field-0          | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id               | int(11)      | NO     | PRI   | None      |         |
      | type             | varchar(9)   | NO     |       | None      |         |
      | user_type        | varchar(12)  | NO     |       | None      |         |
      | username         | varchar(64)  | NO     |       | None      |         |
      | password_encrypt | varchar(200) | NO     |       | None      |         |
      | conn_attr_key    | varchar(6)   | YES    |       | None      |         |
      | conn_attr_value  | varchar(64)  | YES    |       | None      |         |
      | white_ips        | varchar(200) | YES    |       | None      |         |
      | readonly         | varchar(5)   | YES    |       | None      |         |
      | max_conn_count   | varchar(64)  | NO     |       | None      |         |
      | blacklist        | varchar(64)  | YES    |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_2"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | select * from dble_entry | dble_information |
    Then check resultset "dble_entry_2" has lines with following column values
      | id-0 | type-1   | user_type-2  | username-3 | password_encrypt-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7 | readonly-8 | max_conn_count-9 | blacklist-10 |
      | 1    | username | managerUser  | root       | 111111             | None            | None              | None        | false      | no limit         | None         |
      | 2    | username | shardingUser | test       | 111111             | None            | None              | None        | false      | no limit         | None         |
      | 3    | username | rwSplitUser  | rwSplit    | 111111             | None            | None              | None        | -          | 20               | None         |
  #case change user.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>
     <managerUser name="root1" password="654321" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false"/>

     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" />
     <shardingUser name="test1" password="123456" schemas="schema1" readOnly="false" blacklist="blacklist1" maxCon="150"/>
     <shardingUser name="test2" password="123456" schemas="schema1" maxCon="120" tenant="tenant1"/>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="dbGroup1" blacklist="blacklist1" maxCon="20"/>
     <rwSplitUser name="rwSplit1" password="123456" dbGroup="dbGroup1" blacklist="blacklist1" />

     <blacklist name="blacklist1">
     <property name="selelctAllow">true</property>
     </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_3"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | select * from dble_entry | dble_information |
    Then check resultset "dble_entry_3" has lines with following column values
      | id-0 | type-1    | user_type-2  | username-3 | password_encrypt-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7               | readonly-8 | max_conn_count-9 | blacklist-10 |
      | 1    | username  | managerUser  | root       | 111111             | None            | None              | None                      | false      | 100              | None         |
      | 2    | username  | managerUser  | root1      | 654321             | None            | None              | 0:0:0:0:0:0:0:1,127.0.0.1 | false      | no limit         | None         |
      | 3    | username  | shardingUser | test       | 111111             | None            | None              | 0:0:0:0:0:0:0:1,127.0.0.1 | false      | no limit         | blacklist1   |
      | 4    | username  | shardingUser | test1      | 123456             | None            | None              | None                      | false      | 150              | blacklist1   |
      | 5    | conn_attr | shardingUser | test2      | 123456             | tenant          | tenant1           | None                      | false      | 120              | None         |
      | 6    | username  | rwSplitUser  | rwSplit    | 111111             | None            | None              | None                      | -          | 20               | blacklist1   |
      | 7    | username  | rwSplitUser  | rwSplit1   | 123456             | None            | None              | None                      | -          | no limit         | blacklist1   |

   Scenario:  dble_entry_schema  table #2
  #case desc dble_entry_schema
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_schema_1"
      | conn   | toClose | sql                   | db               |
      | conn_0 | False   | desc dble_entry_schema | dble_information |
    Then check resultset "dble_entry_schema_1" has lines with following column values
      | Field-0 | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11)     | NO     | PRI   | None      |         |
      | schema  | varchar(64) | NO     | PRI   | None      |         |

    #case change user.xml and sharding.xml and reload
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
            <childTable name="er_child" joinColumn="id" parentColumn="id"/>
        </shardingTable>
    </schema>
     <schema shardingNode="dn1" name="schema2" sqlMaxLimit="1000">
        <singleTable name="test1"  shardingNode="dn1" />
     </schema>
    <schema shardingNode="dn4" name="schema3">
    </schema>

    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

     <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3" readOnly="false" blacklist="blacklist1" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" />
     <shardingUser name="test1" password="123456" schemas="schema2" readOnly="false" blacklist="blacklist1" maxCon="150"/>
     <shardingUser name="test2" password="123456" schemas="schema2,schema3" maxCon="120" tenant="tenant1"/>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="dbGroup1" blacklist="blacklist1" maxCon="20"/>
     <blacklist name="blacklist1">
     <property name="selelctAllow">true</property>
     </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_schema_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from dble_entry_schema | dble_information |
    Then check resultset "dble_entry_schema_2" has lines with following column values
      | id-0 | schema-1 |
      | 2    | schema2  |
      | 2    | schema1  |
      | 2    | schema3  |
      | 3    | schema2  |
      | 4    | schema2  |
      | 4    | schema3  |
  #case select
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                       | expect      | db               |
      | conn_0 | False   | select * from dble_entry where id in (select id from dble_entry_schema)   | length{(3)} | dble_information |
      | conn_0 | False   | select * from dble_entry where id >all (select id from dble_entry_schema) | length{(1)} | dble_information |
      | conn_0 | False   | select * from dble_entry where id <any (select id from dble_entry_schema) | length{(3)} | dble_information |
      | conn_0 | False   | select * from dble_entry where id =any (select id from dble_entry_schema) | length{(3)} | dble_information |

   Scenario:  dble_entry_db_group  table #3
  #case desc dble_entry_db_group
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_db_group_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc dble_entry_db_group | dble_information |
    Then check resultset "dble_entry_db_group_1" has lines with following column values
      | Field-0   | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id        | int(11)     | NO     | PRI   | None      |         |
      | db_group  | varchar(64) | NO     |       | None      |         |

  #case change user.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>
     <managerUser name="root1" password="654321" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false"/>

     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" />
     <shardingUser name="test1" password="123456" schemas="schema1" readOnly="false" blacklist="blacklist1" maxCon="150"/>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
     <rwSplitUser name="rwSplit1" password="123456" dbGroup="ha_group2" blacklist="blacklist1" />

     <blacklist name="blacklist1">
     <property name="selelctAllow">true</property>
     </blacklist>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_3"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_entry_db_group | dble_information |
    Then check resultset "dble_entry_3" has lines with following column values
      | id-0 | db_group-1 |
      | 5    | ha_group1  |
      | 6    | ha_group2  |

#@skip_restart
   Scenario:  dble_entry_table_privilege  table #4
  #case desc dble_entry_table_privilege
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_1"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | desc dble_entry_table_privilege | dble_information |
    Then check resultset "dble_entry_table_privilege_1" has lines with following column values
      | Field-0 | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11)     | NO     | PRI   | None      |         |
      | schema  | varchar(64) | NO     | PRI   | None      |         |
      | table   | varchar(64) | NO     | PRI   | None      |         |
      | insert  | int(1)      | NO     |       | None      |         |
      | update  | int(1)      | NO     |       | None      |         |
      | select  | int(1)      | NO     |       | None      |         |
      | delete  | int(1)      | NO     |       | None      |         |
  #case change user.xml and reload
  # case create new tables
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  |
      | conn_1 | False   | use schema1                 | success |
      | conn_1 | False   | create table no_13 (id int) | success |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" >
          <privileges check="true">
             <schema name="schema1" dml="0110">
             </schema>
         </privileges>
     </shardingUser>
     <shardingUser name="test1" password="123456" schemas="schema1" readOnly="false" maxCon="150">
         <privileges check="true">
             <schema name="schema1" dml="0111">
                <table name="no_13" dml="0000"/>
             </schema>
         </privileges>
     </shardingUser>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_2"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
#    Then check resultset "dble_entry_table_privilege_2" has lines with following column values


   Scenario:  dble_rw_split_entry  table #5
  #case desc dble_rw_split_entry
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_rw_split_entry_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc dble_rw_split_entry | dble_information |
    Then check resultset "dble_rw_split_entry_1" has lines with following column values
      | Field-0 | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11)     | NO     | PRI   | None      |         |
      | schema  | varchar(64) | NO     | PRI   | None      |         |
      | table   | varchar(64) | NO     | PRI   | None      |         |
      | insert  | int(1)      | NO     |       | None      |         |
      | update  | int(1)      | NO     |       | None      |         |
      | select  | int(1)      | NO     |       | None      |         |
      | delete  | int(1)      | NO     |       | None      |         |

@skip_restart
   Scenario:  dble_blacklist  table #6
  #case desc dble_blacklist
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_1"
      | conn   | toClose | sql             | db               |
      | conn_0 | False   | desc dble_blacklist | dble_information |
    Then check resultset "dble_blacklist_1" has lines with following column values
      | Field-0         | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name            | varchar(64) | NO     | PRI   | None      |         |
      | property_key    | varchar(64) | NO     | PRI   | None      |         |
      | property_value  | varchar(5)  | NO     |       | None      |         |
      | user_configured | varchar(5)  | NO     |       | None      |         |

  #case change user.xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="black1" />
     <shardingUser name="test1" password="123456" schemas="schema1" readOnly="false" blacklist="blacklist2" maxCon="150"/>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="list3" maxCon="20"/>

     <blacklist name="black1">
        <property name="updateWhereAlayTrueCheck">true</property>
        <property name="updateWhereNoneCheck">false</property>
        <property name="useAllow">true</property>
        <property name="truncateAllow">true</property>
     </blacklist>
     <blacklist name="blacklist2">
        <property name="objectCheck">true</property>
        <property name="tableCheck">true</property>
        <property name="caseConditionConstAllow">true</property>
        <property name="conditionAndAlwayFalseAllow">true</property>
     </blacklist>
     <blacklist name="list3">
        <property name="metadataAllow">true</property>
        <property name="completeInsertValuesCheck">true</property>
        <property name="selectHavingAlwayTrueCheck">true</property>
        <property name="selelctAllow">true</property>
     </blacklist>
    """
#    Given Restart dble in "dble-1" success
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | False   | select * from dble_blacklist | dble_information |
#    Then check resultset "dble_blacklist_2" has lines with following column values








