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
      | Field-0            | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id                 | int(11)      | NO     | PRI   | None      |         |
      | type               | varchar(9)   | NO     |       | None      |         |
      | user_type          | varchar(12)  | NO     |       | None      |         |
      | username           | varchar(64)  | NO     |       | None      |         |
      | password_encrypt   | varchar(200) | NO     |       | None      |         |
      | encrypt_configured | varchar(5)   | NO     |       | None      |         |
      | conn_attr_key      | varchar(6)   | YES    |       | None      |         |
      | conn_attr_value    | varchar(64)  | YES    |       | None      |         |
      | white_ips          | varchar(200) | YES    |       | None      |         |
      | readonly           | varchar(5)   | YES    |       | None      |         |
      | max_conn_count     | varchar(64)  | NO     |       | None      |         |
      | blacklist          | varchar(64)  | YES    |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_2"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | select * from dble_entry | dble_information |
    Then check resultset "dble_entry_2" has lines with following column values
      | id-0 | type-1   | user_type-2  | username-3 | encrypt_configured-5 | conn_attr_key-6 | conn_attr_value-7 | white_ips-8 | readonly-9 | max_conn_count-10 | blacklist-11 |
      | 1    | username | managerUser  | root       | false                | None            | None              | None        | false      | no limit          | None         |
      | 2    | username | shardingUser | test       | false                | None            | None              | None        | false      | no limit          | None         |
      | 3    | username | rwSplitUser  | rwSplit    | false                | None            | None              | None        | -          | 20                | None         |
  #case change user.xml and reload
    Given delete the following xml segment
      | file     | parent         | child                  |
      | user.xml | {'tag':'root'} | {'tag':'shardingUser'} |
      | user.xml | {'tag':'root'} | {'tag':'managerUser'}  |
      | user.xml | {'tag':'root'} | {'tag':'rwSplitUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="CrdAFIIPXnXdq7Tc2RRejBwN5pBt0diz/MM9nbLEC7IW62kIJ6Umo0DWjH6KmRGtLF7fmi6rZBB+2TEfqLMf4g==" usingDecrypt="true" readOnly="false" maxCon="100"/>
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
      | id-0 | type-1    | user_type-2  | username-3 | encrypt_configured-5 | conn_attr_key-6 | conn_attr_value-7 | white_ips-8               | readonly-9 | max_conn_count-10 | blacklist-11 |
      | 1    | username  | managerUser  | root       | true                 | None            | None              | None                      | false      | 100               | None         |
      | 2    | username  | managerUser  | root1      | false                | None            | None              | 0:0:0:0:0:0:0:1,127.0.0.1 | false      | no limit          | None         |
      | 3    | username  | shardingUser | test       | false                | None            | None              | 0:0:0:0:0:0:0:1,127.0.0.1 | false      | no limit          | blacklist1   |
      | 4    | username  | shardingUser | test1      | false                | None            | None              | None                      | false      | 150               | blacklist1   |
      | 5    | conn_attr | shardingUser | test2      | false                | tenant          | tenant1           | None                      | false      | 120               | None         |
      | 6    | username  | rwSplitUser  | rwSplit    | false                | None            | None              | None                      | -          | 20                | blacklist1   |
      | 7    | username  | rwSplitUser  | rwSplit1   | false                | None            | None              | None                      | -          | no limit          | blacklist1   |

   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                         | expect                                        |
      | conn_0 | False   | use dble_information                                        | success                                       |
      | conn_0 | False   | select * from dble_entry order by username desc limit 3     | length{(3)}                                   |
      | conn_0 | False   | select * from dble_entry where username like '%test%'       | length{(3)}                                   |
  #case select max/min from
      | conn_0 | False   | select max(username) from dble_entry                      | has{(('test2',),)}  |
      | conn_0 | False   | select min(username) from dble_entry                      | has{(('root',),)}   |
  #case where [sub-query]
      | conn_0 | False   | select username from dble_entry where blacklist in (select blacklist from dble_entry where type = 'username') | has{(('test',), ('test1',),('rwSplit',),('rwSplit1',))}     |
  #case select field from
      | conn_0 | False   | select type from dble_entry where conn_attr_key is not null     | has{(('conn_attr',))}        |
  #case update/delete
      | conn_0 | False   | delete from dble_entry where type='username'               | Access denied for table 'dble_entry'     |
      | conn_0 | False   | update dble_entry set type='aa'  where type='username'     | Access denied for table 'dble_entry'     |
      | conn_0 | False   | insert into dble_entry values ('a',1,2,3)                  | Access denied for table 'dble_entry'     |

 #case delete user
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
      | user.xml     | {'tag':'root'} | {'tag':'managerUser'}  |
      | user.xml     | {'tag':'root'} | {'tag':'rwSplitUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  />
     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" />
     <rwSplitUser name="rwSplit" password="111111" dbGroup="dbGroup1" />

    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_4"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | select * from dble_entry | dble_information |
    Then check resultset "dble_entry_4" has lines with following column values
      | id-0 | type-1   | user_type-2  | username-3 | encrypt_configured-5 | conn_attr_key-6 | conn_attr_value-7 | white_ips-8 | readonly-9 | max_conn_count-10 | blacklist-11 |
      | 1    | username | managerUser  | root       | false                | None            | None              | None        | false      | no limit          | None         |
      | 2    | username | shardingUser | test       | false                | None            | None              | None        | false      | no limit          | None         |
      | 3    | username | rwSplitUser  | rwSplit    | false                | None            | None              | None        | -          | no limit          | None         |


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
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect                                   |
      | conn_0 | False   | use dble_information                                                 | success                                  |
      | conn_0 | False   | select * from dble_entry_schema order by schema desc limit 2         | has{((2, 'schema3'), (4, 'schema3'))}    |
      | conn_0 | False   | select * from dble_entry_schema where id like '%4%'                  | has{((4, 'schema2'), (4, 'schema3'))}    |
  #case select max/min
      | conn_0 | False   | select max(id) from dble_entry_schema                      | has{((4,),)}  |
      | conn_0 | False   | select min(id) from dble_entry_schema                      | has{((2,),)}  |
  #case update/delete
      | conn_0 | False   | delete from dble_entry_schema where schema='schema1'                   | Access denied for table 'dble_entry_schema'     |
      | conn_0 | False   | update dble_entry_schema set schema = 'a' where schema='schema1'       | Access denied for table 'dble_entry_schema'     |
      | conn_0 | False   | insert into dble_entry_schema values (1,'1')                           | Access denied for table 'dble_entry_schema'     |
  #case select where [sub-query]
      | conn_0 | False   | select id from dble_entry where id in (select id from dble_entry_schema)   | has{((2,), (3,), (4,))}                                                                               |
      | conn_0 | False   | select id from dble_entry where id >all (select id from dble_entry_schema) | has{((5,),)}                                                                                          |
      | conn_0 | False   | select id from dble_entry where id <any (select id from dble_entry_schema) | has{((1,), (2,), (3,))}                                                                               |
      | conn_0 | False   | select id from dble_entry where id =any (select id from dble_entry_schema) | has{((2,), (3,), (4,))}                                                                               |
      | conn_0 | False   | select * from dble_entry_schema where id in (select id from dble_entry)    | has{((2, 'schema2'), (2, 'schema1'), (2, 'schema3'), (3, 'schema2'), (4, 'schema2'), (4, 'schema3'))} |
      | conn_0 | False   | select * from dble_entry_schema where id >all (select id from dble_entry)  | success                                                                                               |
      | conn_0 | False   | select * from dble_entry_schema where id <any (select id from dble_entry)  | has{((2, 'schema2'), (2, 'schema1'), (2, 'schema3'), (3, 'schema2'), (4, 'schema2'), (4, 'schema3'))} |
      | conn_0 | False   | select * from dble_entry_schema where id =any (select id from dble_entry)  | has{((2, 'schema2'), (2, 'schema1'), (2, 'schema3'), (3, 'schema2'), (4, 'schema2'), (4, 'schema3'))} |
   #case delete some user.xml and sharding.xml and reload
    Given delete the following xml segment
      | file             | parent         | child                  |
      | sharding.xml     | {'tag':'root'} | {'tag':'schema'}       |
      | user.xml         | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema2" sqlMaxLimit="100" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>
     <shardingUser name="test" password="111111" schemas="schema2" readOnly="false" />
     <rwSplitUser name="rwSplit" password="111111" dbGroup="dbGroup1" />
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_schema_3"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from dble_entry_schema | dble_information |
    Then check resultset "dble_entry_schema_3" has lines with following column values
      | id-0 | schema-1 |
      | 2    | schema2  |
   Then check resultset "dble_entry_schema_3" has not lines with following column values
      | id-0 | schema-1 |
      | 2    | schema1  |
      | 2    | schema3  |
      | 3    | schema2  |
      | 4    | schema2  |
      | 4    | schema3  |


@skip_restart
   Scenario:  dble_entry_table_privilege  table #3
  #case desc dble_entry_table_privilege
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_1"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | desc dble_entry_table_privilege | dble_information |
    Then check resultset "dble_entry_table_privilege_1" has lines with following column values
      | Field-0        | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id             | int(11)     | NO     | PRI   | None      |         |
      | schema         | varchar(64) | NO     | PRI   | None      |         |
      | table          | varchar(64) | NO     | PRI   | None      |         |
      | exist_metas    | varchar(5)  | NO     |       | None      |         |
      | insert         | int(1)      | NO     |       | None      |         |
      | update         | int(1)      | NO     |       | None      |         |
      | select         | int(1)      | NO     |       | None      |         |
      | delete         | int(1)      | NO     |       | None      |         |
      | is_effective   | varchar(5)  | NO     |       | None      |         |
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
      | id-0 | schema-1 | table-2       | exist_metas-3 | insert-4 | update-5 | select-6 | delete-7 | is_effective-8 |
      | 2    | schema1  | test          | false         | 0        | 1        | 1        | 0        | false          |
      | 2    | schema1  | sharding_2_t1 | false         | 0        | 1        | 1        | 0        | false          |
      | 2    | schema1  | sharding_4_t1 | false         | 0        | 1        | 1        | 0        | false          |
      | 3    | schema2  | no_s3         | true          | 0        | 0        | 0        | 0        | true           |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  |
      | conn_2 | False   | drop table if exists no_s3  | success |
   Then execute admin cmd "reload @@config"
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_3"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
    Then check resultset "dble_entry_table_privilege_3" has lines with following column values
      | id-0 | schema-1 | table-2       | exist_metas-3 | insert-4 | update-5 | select-6 | delete-7 | is_effective-8 |
      | 2    | schema1  | test          | false         | 0        | 1        | 1        | 0        | false          |
      | 2    | schema1  | sharding_2_t1 | false         | 0        | 1        | 1        | 0        | false          |
      | 2    | schema1  | sharding_4_t1 | false         | 0        | 1        | 1        | 0        | false          |
      | 3    | schema2  | no_s3         | false         | 0        | 0        | 0        | 0        | false          |

 #case dml standard http://10.186.18.11/jira/browse/DBLE0REQ-515 and http://10.186.18.11/jira/browse/DBLE0REQ-512
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

      <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" >
          <privileges check="true">
             <schema name="schema1" dml="010">
                <table name="test" dml="0110"/>
                <table name="sharding_2_t1" dml="0200"/>
                <table name="sharding_3_t1" dml="0300"/>
             </schema>
         </privileges>
     </shardingUser>
     <shardingUser name="test1" password="123456" schemas="schema1,schema2" readOnly="false" maxCon="150">
         <privileges check="true">
             <schema name="schema2" dml="0111">
                <table name="no_s3" dml="010"/>
             </schema>
         </privileges>
     </shardingUser>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                                                                                                                                 |
      | conn_0 | False   | reload @@config      | Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: the dml privilege for the shema [schema1] configuration under the user [test] is not standard    |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
     the dml privilege for the shema \[schema1\] configuration under the user \[test\] is not standard
    """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

      <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" >
          <privileges check="true">
             <schema name="schema1" dml="0010">
             </schema>
             <schema name="schema2" dml="0010">
                <table name="test" dml="0110"/>
                <table name="sharding_2_t1" dml="0100"/>
                <table name="sharding_3_t1" dml="0110"/>
             </schema>
         </privileges>
     </shardingUser>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                                                                         |
      | conn_0 | False   | reload @@config      | Reload config failure.The reason is SelfCheck### privileges's schema[schema2] was not found in the user [name:test]'s schemas  |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
      schema\[schema2\] was not found in the user \[name:test\]
    """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

      <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" >
          <privileges check="true">
             <schema name="schema1" dml="0010">
                <table name="test" dml="0110"/>
                <table name="sharding_2_t1" dml="0100"/>
                <table name="sharding_3_t1" dml="0110"/>
             </schema>
         </privileges>
     </shardingUser>
     <shardingUser name="test1" password="123456" schemas="schema1,schema2" readOnly="false" maxCon="150">
         <privileges check="true">
             <schema name="schema2" dml="0111">
                <table name="no_s3" dml="0202"/>
             </schema>
         </privileges>
     </shardingUser>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                                                                                                                                                           |
      | conn_0 | true    | reload @@config      | Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: the dml privilege for the table [no_s3] configuration under the shema [schema2] under the user [test1] is not standard     |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
     """
      the dml privilege for the table \[no_s3\] configuration under the shema \[schema2\] under the user \[test1\] is not standard
     """
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
    """
    Given sleep "10" seconds
    Then get result of oscmd named "rs_1" in "dble-1"
    """
    cat /opt/dble/logs/wrapper.log | grep 'the dml privilege for the table \[no_s3\] configuration under the shema \[schema2\] under the user \[test1\] is not standard' |wc -l
    """
    Then check result "rs_1" value is "1"
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

      <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" >
          <privileges check="true">
             <schema name="schema1" dml="0010">
             </schema>
         </privileges>
     </shardingUser>
     <shardingUser name="test1" password="123456" schemas="schema1,schema2" readOnly="false" maxCon="150">
         <privileges check="true">
             <schema name="schema3" dml="0111">
                <table name="no_s3" dml="0101"/>
             </schema>
         </privileges>
     </shardingUser>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
    """
    Given sleep "10" seconds
    Then get result of oscmd named "rs_2" in "dble-1"
    """
    cat /opt/dble/logs/wrapper.log | grep 'schema\[schema3\] was not found in the user \[name:test1\]' |wc -l
    """
    Then check result "rs_2" value is "1"
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>

      <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" >
          <privileges check="true">
             <schema name="schema1" dml="0010">
                <table name="test" dml="0111"/>
                <table name="no_s1" dml="0110"/>
             </schema>
         </privileges>
     </shardingUser>
     <shardingUser name="test1" password="123456" schemas="schema1,schema2" readOnly="true" maxCon="150">
         <privileges check="true">
             <schema name="schema2" dml="0111">
                <table name="no_s1" dml="0111"/>
             </schema>
             <schema name="schema1" dml="0000">
                <table name="no_s2" dml="0101"/>
                <table name="no_s3" dml="0001"/>
                <table name="test" dml="0001"/>
             </schema>
        </privileges>
     </shardingUser>

     <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_group1" blacklist="blacklist1" maxCon="20"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  |
      | conn_1 | False   | use schema1                 | success |
      | conn_1 | False   | drop table if exists test   | success |
      | conn_1 | False   | create table test (id int)  | success |
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_4"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
    Then check resultset "dble_entry_table_privilege_4" has lines with following column values
      | id-0 | schema-1 | table-2 | exist_metas-3 | insert-4 | update-5 | select-6 | delete-7 | is_effective-8 |
      | 2    | schema1  | test    | true          | 0        | 1        | 1        | 1        | true           |
      | 2    | schema1  | no_s1   | false         | 0        | 1        | 1        | 0        | false          |
      | 3    | schema1  | test    | true          | 0        | 0        | 0        | 1        | false          |
      | 3    | schema2  | no_s1   | false         | 0        | 1        | 1        | 1        | false          |
      | 3    | schema1  | no_s3   | false         | 0        | 0        | 0        | 1        | false          |
      | 3    | schema1  | no_s2   | false         | 0        | 1        | 0        | 1        | false          |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  |
      | conn_1 | False   | use schema1                 | success |
      | conn_1 | False   | drop table if exists test   | success |
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_5"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
    Then check resultset "dble_entry_table_privilege_5" has lines with following column values
      | id-0 | schema-1 | table-2 | exist_metas-3 | insert-4 | update-5 | select-6 | delete-7 | is_effective-8 |
      | 2    | schema1  | test    | false         | 0        | 1        | 1        | 1        | true           |
      | 2    | schema1  | no_s1   | false         | 0        | 1        | 1        | 0        | false          |
      | 3    | schema2  | no_s1   | false         | 0        | 1        | 1        | 1        | false          |
      | 3    | schema1  | test    | false         | 0        | 0        | 0        | 1        | false          |
      | 3    | schema1  | no_s3   | false         | 0        | 0        | 0        | 1        | false          |
      | 3    | schema1  | no_s2   | false         | 0        | 1        | 0        | 1        | false          |
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                                  |
      | conn_0 | False   | select schema,is_effective from dble_entry_table_privilege order by table desc limit 2     | has{(('schema1', 'true'), ('schema1', 'false'))}        |
      | conn_0 | False   | select * from dble_entry_table_privilege where schema like '%2%'                           | has{((3,'schema2','no_s1','false',0,1,1,1,'false'))}    |
  #case select max/min
      | conn_0 | False   | select max(id) from dble_entry_table_privilege                      | has{((3,),)}  |
      | conn_0 | False   | select min(id) from dble_entry_table_privilege                      | has{((2,),)}  |
  #case update/delete
      | conn_0 | False   | delete from dble_entry_table_privilege where is_effective='true'                         | Access denied for table 'dble_entry_table_privilege'     |
      | conn_0 | False   | update dble_entry_table_privilege set is_effective = 'a' where is_effective='true'       | Access denied for table 'dble_entry_table_privilege'     |
      | conn_0 | False   | insert into dble_entry_table_privilege values (1,'1',1,1,1)                              | Access denied for table 'dble_entry_table_privilege'     |
  #case select where [sub-query]
      | conn_0 | False   | select table from dble_entry_table_privilege where schema in (select schema from dble_entry_schema where id =2 )   | has{(('test',), ('no_s1',), ('test',), ('no_s3',), ('no_s2',))}       |
      | conn_0 | False   | select table from dble_entry_table_privilege where schema >all (select schema from dble_entry_schema)              | length{(0)}                                                           |
      | conn_0 | False   | select table from dble_entry_table_privilege where schema <any (select schema from dble_entry_schema)              | length{(5)}                                                           |
      | conn_0 | False   | select table from dble_entry_table_privilege where schema =any (select schema from dble_entry_schema)              | length{(6)}                                                           |


   Scenario:  dble_rw_split_entry  table #4
  #case desc dble_rw_split_entry
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_rw_split_entry_1"
      | conn   | toClose | sql                      | db               |
      | conn_0 | False   | desc dble_rw_split_entry | dble_information |
    Then check resultset "dble_rw_split_entry_1" has lines with following column values
      | Field-0            | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id                 | int(11)      | YES    | PRI   | None      |         |
      | type               | varchar(9)   | YES    |       | None      |         |
      | username           | varchar(64)  | NO     |       | None      |         |
      | password_encrypt   | varchar(200) | NO     |       | None      |         |
      | encrypt_configured | varchar(5)   | YES    |       | true      |         |
      | conn_attr_key      | varchar(6)   | YES    |       | None      |         |
      | conn_attr_value    | varchar(64)  | YES    |       | None      |         |
      | white_ips          | varchar(200) | YES    |       | None      |         |
      | max_conn_count     | varchar(64)  | NO     |       | None      |         |
      | blacklist          | varchar(64)  | YES    |       | None      |         |
      | db_group           | varchar(64)  | NO     |       | None      |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_rw_split_entry_2"
      | conn   | toClose | sql                               | db                 |
      | conn_0 | False   | select * from dble_rw_split_entry | dble_information |
    Then check resultset "dble_rw_split_entry_2" has lines with following column values
      | id-0 | type-1   | username-2 | encrypt_configured-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7 | max_conn_count-8 | blacklist-9 | db_group-10 |
      | 3    | username | rwSplit    | false                | None            | None              | None        | 20               | None        | ha_group1   |
  #case change user.xml and reload
    Given delete the following xml segment
      | file     | parent         | child                  |
      | user.xml | {'tag':'root'} | {'tag':'shardingUser'} |
      | user.xml | {'tag':'root'} | {'tag':'managerUser'}  |
      | user.xml | {'tag':'root'} | {'tag':'rwSplitUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111" readOnly="false" maxCon="100"/>
     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" blacklist="blacklist1" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" />

     <rwSplitUser name="rwSplit" password="epeqIkJ7KyzpFqC67+fPdAzLIzYTIlu6OTgFrdmS6+WgxLJr9aSOt+szbhReYSZvoY8PW2x8Gh77pAsFnfbPmQ==" usingDecrypt="true" dbGroup="ha_group1" blacklist="list" maxCon="20"/>
     <rwSplitUser name="rwSplit1" password="123456" dbGroup="ha_group2" blacklist="blacklist1" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1"/>
     <rwSplitUser name="rwSplit2" password="123456" dbGroup="ha_group1" blacklist="black" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1" tenant="ten1"/>

     <blacklist name="list">
        <property name="updateWhereAlayTrueCheck">true</property>
     </blacklist>
     <blacklist name="blacklist">
        <property name="objectCheck">true</property>
     </blacklist>
     <blacklist name="black">
        <property name="metadataAllow">true</property>
     </blacklist>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_rw_split_entry_3"
      | conn   | toClose | sql                               | db                 |
      | conn_0 | False   | select * from dble_rw_split_entry | dble_information   |
    Then check resultset "dble_rw_split_entry_3" has lines with following column values
      | id-0 | type-1    | username-2 | encrypt_configured-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7               | max_conn_count-8 | blacklist-9 | db_group-10 |
      | 3    | username  | rwSplit    | true                 | None            | None              | None                      | 20               | list        | ha_group1   |
      | 4    | username  | rwSplit1   | false                | None            | None              | 0:0:0:0:0:0:0:1,127.0.0.1 | no limit         | None        | ha_group2   |
      | 5    | conn_attr | rwSplit2   | false                | tenant          | ten1              | 0:0:0:0:0:0:0:1,127.0.0.1 | no limit         | black       | ha_group1   |
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect                                                        |
      | conn_0 | False   | select type,username from dble_rw_split_entry order by id desc limit 2     | has{(('conn_attr', 'rwSplit2'), ('username', 'rwSplit1'))}    |
      | conn_0 | False   | select id,db_group,type from dble_rw_split_entry where type like '%conn%'  | has{((5,'ha_group1','conn_attr',))}                           |
  #case select max/min
      | conn_0 | False   | select max(id) from dble_rw_split_entry                      | has{((5,),)}  |
      | conn_0 | False   | select min(id) from dble_rw_split_entry                      | has{((3,),)}  |
  #case select where [sub-query]
      | conn_0 | False   | select username from dble_rw_split_entry where blacklist in (select name from dble_blacklist where user_configured = 'true')      | has{(('rwSplit2',), ('rwSplit',))}       |
      | conn_0 | False   | select username from dble_rw_split_entry where blacklist >all (select name from dble_blacklist where user_configured = 'true')    | length{(0)}                              |
      | conn_0 | False   | select username from dble_rw_split_entry where blacklist <any (select name from dble_blacklist where user_configured = 'true')    | has{(('rwSplit2',))}                     |
      | conn_0 | False   | select username from dble_rw_split_entry where blacklist =any (select name from dble_blacklist where user_configured = 'true')    | has{(('rwSplit2',), ('rwSplit',))}


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
    Given delete the following xml segment
      | file     | parent         | child                  |
      | user.xml | {'tag':'root'} | {'tag':'shardingUser'} |
      | user.xml | {'tag':'root'} | {'tag':'managerUser'}  |
      | user.xml | {'tag':'root'} | {'tag':'rwSplitUser'}  |
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
   #case select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect                                                                                                        |
      | conn_0 | False   | select name,property_key from dble_blacklist order by property_key desc limit 2     | has{(('black1', 'wrapAllow'), ('blacklist2', 'wrapAllow'))}                                          |
      | conn_0 | False   | select name,property_key from dble_blacklist where property_key like '%truncate%'   | has{(('black1','truncateAllow',),('blacklist2','truncateAllow',),('list3','truncateAllow',))}        |
  #case select max/min
      | conn_0 | False   | select max(property_key) from dble_blacklist                      | has{(('wrapAllow',),)}        |
      | conn_0 | False   | select min(property_key) from dble_blacklist                      | has{(('alterTableAllow',),)}  |
      | conn_0 | False   | select count(name),name from dble_blacklist group by name         | has{((59,'black1',),(59,'blacklist2',),(59,'list3',))}  |
  #case update/delete
      | conn_0 | False   | delete from dble_blacklist where property_value='true'                         | Access denied for table 'dble_blacklist'     |
      | conn_0 | False   | update dble_blacklist set property_value = 'a' where property_value='true'     | Access denied for table 'dble_blacklist'     |
      | conn_0 | False   | insert into dble_blacklist values (1,'1',1,1)                                  | Access denied for table 'dble_blacklist'     |










