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
      | 1    | username | managerUser  | root       |                    | None            | None              | None        | false      | no limit         | None         |
      | 2    | username | shardingUser | test       |                    | None            | None              | None        | false      | no limit         | None         |
      | 3    | username | rwSplitUser  | rwSplit    |                    | None            | None              | None        | -          | 20               | None         |
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
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_3"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | select * from dble_entry | dble_information |
    Then check resultset "dble_entry_3" has lines with following column values
      | id-0 | type-1    | user_type-2  | username-3 | password_encrypt-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7               | readonly-8 | max_conn_count-9 | blacklist-10 |
      | 1    | username  | managerUser  | root       |              | None            | None              | None                      | false      | 100              | None         |
      | 2    | username  | managerUser  | root1      |              | None            | None              | 0:0:0:0:0:0:0:1,127.0.0.1 | false      | no limit         | None         |
      | 3    | username  | shardingUser | test       |              | None            | None              | 0:0:0:0:0:0:0:1,127.0.0.1 | false      | no limit         | blacklist1   |
      | 4    | username  | shardingUser | test1      |              | None            | None              | None                      | false      | 150              | blacklist1   |
      | 5    | conn_attr | shardingUser | test2      |              | tenant          | tenant1           | None                      | false      | 120              | None         |
      | 6    | username  | rwSplitUser  | rwSplit    |              | None            | None              | None                      | -          | 20               | blacklist1   |
      | 7    | username  | rwSplitUser  | rwSplit1   |              | None            | None              | None                      | -          | no limit         | blacklist1   |

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
    Then check resultset "dble_entry_schema_2" has not lines with following column values
      | id-0 |
      | 1    |
      | 5    |
  #case select
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                       | expect      | db               |
      | conn_0 | False   | select * from dble_entry where id in (select id from dble_entry_schema)   | length{(3)} | dble_information |
      | conn_0 | False   | select * from dble_entry where id >all (select id from dble_entry_schema) | length{(1)} | dble_information |
      | conn_0 | False   | select * from dble_entry where id <any (select id from dble_entry_schema) | length{(3)} | dble_information |
      | conn_0 | False   | select * from dble_entry where id =any (select id from dble_entry_schema) | length{(3)} | dble_information |

   Scenario:  dble_entry_table_privilege  table #3
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
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema2" sqlMaxLimit="100" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>
     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" />
     <shardingUser name="test1" password="123456" schemas="schema2" readOnly="false" maxCon="150"/>
     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql         | expect   |
      | test1 | 123456 | conn_2 | False   | use schema2 | success  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  |
      | conn_2 | False   | use schema2                 | success |
      | conn_2 | False   | drop table if exists no_s3  | success |
      | conn_2 | False   | create table no_s3 (id int) | success |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" >
          <privileges check="true">
             <schema name="schema1" dml="0110">
             </schema>
         </privileges>
     </shardingUser>
     <shardingUser name="test1" password="123456" schemas="schema1,schema2" readOnly="false" maxCon="150">
         <privileges check="true">
             <schema name="schema2" dml="0111">
                <table name="no_s3" dml="0000"/>
             </schema>
         </privileges>
     </shardingUser>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
   Then execute admin cmd "reload @@config"
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_2"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
    Then check resultset "dble_entry_table_privilege_2" has lines with following column values
      | id-0 | schema-1 | table-2       | insert-3 | update-4 | select-5 | delete-6 |
      | 2    | schema1  | test          | 0        | 1        | 1        | 0        |
      | 2    | schema1  | sharding_2_t1 | 0        | 1        | 1        | 0        |
      | 2    | schema1  | sharding_4_t1 | 0        | 1        | 1        | 0        |
      | 3    | schema2  | no_s3         | 0        | 0        | 0        | 0        |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" >
          <privileges check="true">
             <schema name="schema1" dml="0110">
                <table name="sharding_2_t1" dml="0100"/>
             </schema>
         </privileges>
     </shardingUser>
     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
   Then execute admin cmd "reload @@config"
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_3"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
    Then check resultset "dble_entry_table_privilege_3" has lines with following column values
      | id-0 | schema-1 | table-2       | insert-3 | update-4 | select-5 | delete-6 |
      | 2    | schema1  | sharding_2_t1 | 0        | 1        | 0        | 0        |
    Then check resultset "dble_entry_table_privilege_3" has not lines with following column values
      | id-0 | schema-1 | table-2       | insert-3 | update-4 | select-5 | delete-6 |
      | 2    | schema1  | sharding_2_t1 | 0        | 1        | 1        | 0        |


@skip
   Scenario:  dble_rw_split_entry  table #4
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





   Scenario:  dble_blacklist  table #5
  #case desc dble_blacklist
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_1"
      | conn   | toClose | sql                 | db               |
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
      | conn   | toClose | sql                                                       | db               |
      | conn_0 | False   | select * from dble_blacklist where user_configured='true' | dble_information |
    Then check resultset "dble_blacklist_2" has lines with following column values
      | name-0     | property_key-1              | property_value-2 | user_configured-3 |
      | black1     | truncateAllow               | true             | true              |
      | black1     | updateWhereAlayTrueCheck    | true             | true              |
      | black1     | updateWhereNoneCheck        | false            | true              |
      | black1     | useAllow                    | true             | true              |
      | blacklist2 | caseConditionConstAllow     | true             | true              |
      | blacklist2 | conditionAndAlwayFalseAllow | true             | true              |
      | blacklist2 | objectCheck                 | true             | true              |
      | blacklist2 | tableCheck                  | true             | true              |
      | list3      | completeInsertValuesCheck   | true             | true              |
      | list3      | metadataAllow               | true             | true              |
      | list3      | selectHavingAlwayTrueCheck  | true             | true              |
      | list3      | selelctAllow                | true             | true              |








