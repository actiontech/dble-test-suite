# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_entry test

  @skip_restart
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
#case change user.xml to check values
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
     """
     <dbGroup rwSplitMode="0" name="dbGroup3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="dbGroup4" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM4" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn1" name="schema2" sqlMaxLimit="1000">
        <singleTable name="sing1"  shardingNode="dn1" />
     </schema>
    <schema shardingNode="dn4" name="schema3">
    </schema>
    <schema shardingNode="dn5" name="schema4">
    </schema>
    """
#case whiteIPs filed supported more ips and "%"
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
     <managerUser name="root" password="CrdAFIIPXnXdq7Tc2RRejBwN5pBt0diz/MM9nbLEC7IW62kIJ6Umo0DWjH6KmRGtLF7fmi6rZBB+2TEfqLMf4g==" usingDecrypt="true" readOnly="false" whiteIPs="172.100.9.%" maxCon="1000"/>
     <managerUser name="root1" password="123456" whiteIPs="%.%.%.1" />
     <managerUser name="root2" password="123456" whiteIPs="%.100.%.2"/>
     <managerUser name="root3" password="123456" whiteIPs="%.%.%.%" readOnly="false"/>
     <managerUser name="root4" password="jdhXetiURAxVXzRssOLuh4rE4awd6ZFyF/b2uGmi33ynfiQzTUYZTeEhX4eOBsVH3o11vexOiZPU3lN49KlW7w==" usingDecrypt="true" whiteIPs="fe80:%:%:%:%:%:%:%"/>

     <shardingUser name="test" password="111111" schemas="schema1,schema4" whiteIPs="172.100.9.1,172.100.9.3" maxCon="100" blacklist='list3' />
     <shardingUser name="test1" password="XuvqCBPP/Ycex6EYGGjR1IYJKQBpmZZqgKmsG040ruJlj331uswfWtHk5Y9b/tAFWsDX3JFJiF6RVWSoIDazUA==" usingDecrypt="true" schemas="schema1,schema2" whiteIPs="172.100.9.2/20" tenant="tenuser1" />
     <shardingUser name="test2" password="123456" schemas="schema2,schema3" whiteIPs="172.100.%.1,172.%.9.%" readOnly="false"  maxCon="50"/>
     <shardingUser name="test3" password="123456" schemas="schema1,schema2,schema3,schema4" whiteIPs="%:%:%:%:%:%:%:%,fe80:%:%:%:%:%:%:%" readOnly="false" tenant="tenuser2"/>
     <shardingUser name="test4" password="123456" schemas="schema4" whiteIPs="2001:%:%:%:%:%:%:%" blacklist='blacklist' />
     <shardingUser name="test5" password="123456" schemas="schema3,schema1" whiteIPs="::1" maxCon="500" tenant="tenuser3"/>

     <rwSplitUser name="rwS" password="123456" dbGroup="dbGroup3" whiteIPs="172.100.9.1-172.100.9.3"/>
     <rwSplitUser name="rwS1" password="123456" dbGroup="dbGroup3" whiteIPs="%.%.%.1" tenant="tenuser4" blacklist='blacklist2' />
     <rwSplitUser name="rwS2" password="UDluVVAvL5vf/PQj3Gxjj6BycVRSApdTcZ7pVkoxp9xDcEAHa4R53vQXzTe1lgwMXDVBV+0DdbluWT+Jt2yH6w==" usingDecrypt="true" dbGroup="dbGroup3" whiteIPs="172.100.9.7-172.100.9.3" maxCon="10" blacklist='list3'/>
     <rwSplitUser name="rwS3" password="123456" dbGroup="dbGroup4" whiteIPs="%.%.%.%,%:%:%:%:%:%:%:%"/>
     <rwSplitUser name="rwS4" password="111111" dbGroup="dbGroup4" whiteIPs="fe80::fea4:9473:b424:bb41/64" tenant="tenuser5" maxCon="1001" blacklist='black1'/>

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
     <blacklist name="blacklist">
        <property name="deleteWhereNoneCheck">true</property>
        <property name="completeInsertValuesCheck">true</property>
        <property name="strictSyntaxCheck">true</property>
        <property name="variantCheck">true</property>
     </blacklist>
     """
#case todo add some case to check conn
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                         | expect        | db               |
      | conn_0 | False   | desc dble_entry             | length{(12)}  | dble_information |
      | conn_0 | False   | select * from dble_entry    | length{(16)}  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_3"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry                  | dble_information |
    Then check resultset "dble_entry_3" has lines with following column values
      | id-0 | type-1    | user_type-2  | username-3 | encrypt_configured-5 | conn_attr_key-6 | conn_attr_value-7 | white_ips-8                                  | readonly-9 | max_conn_count-10 | blacklist-11 |
      | 1    | username  | managerUser  | root       | true                 | None            | None              | 172.100.9.%,0:0:0:0:0:0:0:1,127.0.0.1        | false      | 1000              | None         |
      | 2    | username  | managerUser  | root1      | false                | None            | None              | %.%.%.1,0:0:0:0:0:0:0:1,127.0.0.1            | false      | no limit          | None         |
      | 3    | username  | managerUser  | root2      | false                | None            | None              | 0:0:0:0:0:0:0:1,%.100.%.2,127.0.0.1          | false      | no limit          | None         |
      | 4    | username  | managerUser  | root3      | false                | None            | None              | 0:0:0:0:0:0:0:1,%.%.%.%,127.0.0.1            | false      | no limit          | None         |
      | 5    | username  | managerUser  | root4      | true                 | None            | None              | fe80:%:%:%:%:%:%:%,0:0:0:0:0:0:0:1,127.0.0.1 | false      | no limit          | None         |
      | 6    | username  | shardingUser | test       | false                | None            | None              | 172.100.9.1,172.100.9.3                      | false      | 100               | list3        |
      | 7    | conn_attr | shardingUser | test1      | true                 | tenant          | tenuser1          | 172.100.9.2/20                               | false      | no limit          | None         |
      | 8    | username  | shardingUser | test2      | false                | None            | None              | 172.%.9.%,172.100.%.1                        | false      | 50                | None         |
      | 9    | conn_attr | shardingUser | test3      | false                | tenant          | tenuser2          | %:%:%:%:%:%:%:%,fe80:%:%:%:%:%:%:%           | false      | no limit          | None         |
      | 10   | username  | shardingUser | test4      | false                | None            | None              | 2001:%:%:%:%:%:%:%                           | false      | no limit          | blacklist    |
      | 11   | conn_attr | shardingUser | test5      | false                | tenant          | tenuser3          | ::1                                          | false      | 500               | None         |
      | 12   | username  | rwSplitUser  | rwS        | false                | None            | None              | 172.100.9.1-172.100.9.3                      | -          | no limit          | None         |
      | 13   | conn_attr | rwSplitUser  | rwS1       | false                | tenant          | tenuser4          | %.%.%.1                                      | -          | no limit          | blacklist2   |
      | 14   | username  | rwSplitUser  | rwS2       | true                 | None            | None              | 172.100.9.7-172.100.9.3                      | -          | 10                | list3        |
      | 15   | username  | rwSplitUser  | rwS3       | false                | None            | None              | %:%:%:%:%:%:%:%,%.%.%.%                      | -          | no limit          | None         |
      | 16   | conn_attr | rwSplitUser  | rwS4       | false                | tenant          | tenuser5          | fe80::fea4:9473:b424:bb41/64                 | -          | 1001              | black1       |

#case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                             | expect                                               |
      | conn_0 | False   | select type from dble_entry order by username desc limit 3                      | has{(('conn_attr',), ('username',), ('conn_attr',))} |
      | conn_0 | False   | select * from dble_entry where username like '%test%'                           | length{(6)}                                          |
      | conn_0 | False   | select count(type),type from dble_entry group by type                           | has{((5,'conn_attr',),(11,'username',))}             |
#case supported select max/min from
      | conn_0 | False   | select max(username) from dble_entry                      | has{(('test5',),)}  |
      | conn_0 | False   | select min(username) from dble_entry                      | has{(('root',),)}   |
#case supported where [sub-query]
      | conn_0 | False   | select username from dble_entry where blacklist in (select blacklist from dble_entry where type = 'username')  | has{(('test4',), ('test',),('rwS2',))}     |
#case supported select field from
      | conn_0 | False   | select type from dble_entry where conn_attr_key is not null     | has{(('conn_attr',))}        |
#case unsupported dml
      | conn_0 | False   | delete from dble_entry where type='username'               | Access denied for table 'dble_entry'     |
      | conn_0 | False   | update dble_entry set type='aa'  where type='username'     | Access denied for table 'dble_entry'     |
      | conn_0 | True    | insert into dble_entry values ('a',1,2,3)                  | Access denied for table 'dble_entry'     |

  @skip_restart
   Scenario:  dble_entry_schema  table #2
  #case desc dble_entry_schema
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_schema_1"
      | conn   | toClose | sql                    | db               |
      | conn_0 | False   | desc dble_entry_schema | dble_information |
    Then check resultset "dble_entry_schema_1" has lines with following column values
      | Field-0 | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | id      | int(11)     | NO     | PRI   | None      |         |
      | schema  | varchar(64) | NO     | PRI   | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect        | db               |
      | conn_0 | False   | desc dble_entry_schema             | length{(2)}   | dble_information |
      | conn_0 | False   | select * from dble_entry_schema    | length{(13)}  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_schema_2"
      | conn   | toClose | sql                             | db               |
      | conn_0 | False   | select * from dble_entry_schema | dble_information |
    Then check resultset "dble_entry_schema_2" has lines with following column values
      | id-0 | schema-1 |
      | 6    | schema1  |
      | 6    | schema4  |
      | 7    | schema2  |
      | 7    | schema1  |
      | 8    | schema2  |
      | 8    | schema3  |
      | 9    | schema2  |
      | 9    | schema1  |
      | 9    | schema4  |
      | 9    | schema3  |
      | 10   | schema4  |
      | 11   | schema1  |
      | 11   | schema3  |
#case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect                                                                   |
      | conn_0 | False   | select * from dble_entry_schema order by schema desc limit 2         | has{((6, 'schema4'), (9, 'schema4'))}                                    |
      | conn_0 | False   | select * from dble_entry_schema where schema like '%4%'              | has{((6, 'schema4'), (9, 'schema4'), (10, 'schema4'))}                   |
      | conn_0 | False   | select count(schema),schema from dble_entry_schema group by schema   | has{((4, 'schema1'), (3, 'schema2'), (3, 'schema3'), (3, 'schema4'))}    |
#case supported select max/min
      | conn_0 | False   | select max(id) from dble_entry_schema                      | has{((11,),)}  |
      | conn_0 | False   | select min(id) from dble_entry_schema                      | has{((6,),)}   |
      | conn_0 | False   | select abs(id) from dble_entry_schema                      | length{(13)}   |
#case supported select where [sub-query]
      | conn_0 | False   | select id from dble_entry where id in (select id from dble_entry_schema) limit 3                   | has{((6,), (7,), (8,))}                          |
      | conn_0 | False   | select id from dble_entry where id >all (select id from dble_entry_schema)                         | has{((12,),(13,),(14,),(15,),(16,),)}            |
      | conn_0 | False   | select id from dble_entry where id <any (select id from dble_entry_schema) limit 3                 | has{((1,), (2,), (3,))}                          |
      | conn_0 | False   | select id from dble_entry where id =any (select id from dble_entry_schema)                         | has{((6,), (7,), (8,), (9,), (10,), (11,))}      |
      | conn_0 | False   | select * from dble_entry_schema where id in (select id from dble_entry) limit 1 order by id        | has{((6, 'schema1'))}                            |
      | conn_0 | False   | select * from dble_entry_schema where id >all (select id from dble_entry)                          | success                                          |
      | conn_0 | False   | select * from dble_entry_schema where id <any (select id from dble_entry) limit 1                  | has{((6, 'schema1'))}                            |
      | conn_0 | False   | select * from dble_entry_schema where id =any (select id from dble_entry) limit 1 order by id desc | has{((11, 'schema1'))}                           |
#case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_entry_schema where schema='schema1'                   | Access denied for table 'dble_entry_schema'     |
      | conn_0 | False   | update dble_entry_schema set schema = 'a' where schema='schema1'       | Access denied for table 'dble_entry_schema'     |
      | conn_0 | True    | insert into dble_entry_schema values (1,'1')                           | Access denied for table 'dble_entry_schema'     |

  @skip_restart
   Scenario:  dble_rw_split_entry  table #3
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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                  | expect        | db               |
      | conn_0 | False   | desc dble_rw_split_entry             | length{(11)}  | dble_information |
      | conn_0 | False   | select * from dble_rw_split_entry    | length{(5)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_rw_split_entry_2"
      | conn   | toClose | sql                               | db                 |
      | conn_0 | False   | select * from dble_rw_split_entry | dble_information |
    Then check resultset "dble_rw_split_entry_2" has lines with following column values
      | id-0 | type-1    | username-2 | encrypt_configured-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7                  | max_conn_count-8 | blacklist-9 | db_group-10 |
      | 12   | username  | rwS        | false                | None            | None              | 172.100.9.1-172.100.9.3      | no limit         | None        | dbGroup3    |
      | 13   | conn_attr | rwS1       | false                | tenant          | tenuser4          | %.%.%.1                      | no limit         | blacklist2  | dbGroup3    |
      | 14   | username  | rwS2       | true                 | None            | None              | 172.100.9.7-172.100.9.3      | 10               | list3       | dbGroup3    |
      | 15   | username  | rwS3       | false                | None            | None              | %:%:%:%:%:%:%:%,%.%.%.%      | no limit         | None        | dbGroup4    |
      | 16   | conn_attr | rwS4       | false                | tenant          | tenuser5          | fe80::fea4:9473:b424:bb41/64 | 1001             | black1      | dbGroup4    |

#case sopported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect                                                                |
      | conn_0 | False   | select type,username from dble_rw_split_entry order by id desc limit 2     | has{(('conn_attr', 'rwS4'), ('username', 'rwS3'))}                    |
      | conn_0 | False   | select id,db_group,type from dble_rw_split_entry where type like '%conn%'  | has{((13, 'dbGroup3', 'conn_attr'), (16, 'dbGroup4', 'conn_attr'))}   |
#case sopported select max/min
      | conn_0 | False   | select max(id) from dble_rw_split_entry                      | has{((16,),)}  |
      | conn_0 | False   | select min(id) from dble_rw_split_entry                      | has{((12,),)}  |
#case sopported select where [sub-query]
      | conn_0 | False   | select username from dble_rw_split_entry where blacklist in (select name from dble_blacklist where user_configured = 'true')      | has{(('rwS4',), ('rwS1',), ('rwS2',))}          |
      | conn_0 | False   | select username from dble_rw_split_entry where blacklist >all (select name from dble_blacklist where user_configured = 'true')    | length{(0)}                                     |
      | conn_0 | False   | select username from dble_rw_split_entry where blacklist <any (select name from dble_blacklist where user_configured = 'true')    | has{(('rwS1',), ('rwS4',))}                     |
      | conn_0 | true    | select username from dble_rw_split_entry where blacklist =any (select name from dble_blacklist where user_configured = 'true')    | has{(('rwS4',), ('rwS1',), ('rwS2',))}          |

  @skip_restart
   Scenario:  dble_blacklist  table #4
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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                             | expect          | db               |
      | conn_0 | False   | desc dble_blacklist             | length{(4)}     | dble_information |
      | conn_0 | False   | select * from dble_blacklist    | length{(236)}   | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_blacklist_2"
      | conn   | toClose | sql                                                       | db               |
      | conn_0 | False   | select * from dble_blacklist where user_configured='true' | dble_information |
    Then check resultset "dble_blacklist_2" has lines with following column values
      | name-0     | property_key-1              | property_value-2 | user_configured-3 |
      | blacklist2 | caseConditionConstAllow     | true             | true              |
      | blacklist2 | conditionAndAlwayFalseAllow | true             | true              |
      | blacklist2 | objectCheck                 | true             | true              |
      | blacklist2 | tableCheck                  | true             | true              |
      | black1     | truncateAllow               | true             | true              |
      | black1     | updateWhereAlayTrueCheck    | true             | true              |
      | black1     | updateWhereNoneCheck        | false            | true              |
      | black1     | useAllow                    | true             | true              |
      | list3      | completeInsertValuesCheck   | true             | true              |
      | list3      | metadataAllow               | true             | true              |
      | list3      | selectHavingAlwayTrueCheck  | true             | true              |
      | list3      | selelctAllow                | true             | true              |
      | blacklist  | completeInsertValuesCheck   | true             | true              |
      | blacklist  | deleteWhereNoneCheck        | true             | true              |
      | blacklist  | strictSyntaxCheck           | true             | true              |
      | blacklist  | variantCheck                | true             | true              |
#case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                                                    |
      | conn_0 | False   | select name,property_key from dble_blacklist order by property_key desc limit 2            | has{(('black1', 'wrapAllow'), ('blacklist2', 'wrapAllow'))}               |
      | conn_0 | False   | select name,property_key from dble_blacklist where property_key like '%truncate%' limit 2  | has{(('black1','truncateAllow',),('blacklist2','truncateAllow',))}        |
#case supported select max/min
      | conn_0 | False   | select max(property_key) from dble_blacklist                      | has{(('wrapAllow',),)}        |
      | conn_0 | False   | select min(property_key) from dble_blacklist                      | has{(('alterTableAllow',),)}  |
      | conn_0 | False   | select count(name),name from dble_blacklist group by name         | has{((59,'black1',),(59,'blacklist2',),(59,'list3',),(59,'blacklist',))}  |
#case unsupported dml
      | conn_0 | False   | delete from dble_blacklist where property_value='true'                         | Access denied for table 'dble_blacklist'     |
      | conn_0 | False   | update dble_blacklist set property_value = 'a' where property_value='true'     | Access denied for table 'dble_blacklist'     |
      | conn_0 | True    | insert into dble_blacklist values (1,'1',1,1)                                  | Access denied for table 'dble_blacklis       |


     Scenario:  dble_entry_table_privilege  table #5
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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                         | expect          | db               |
      | conn_0 | False   | desc dble_entry_table_privilege             | length{(9)}     | dble_information |
#case change user.xml and reload
    Given delete the following xml segment
      | file              | parent         | child                  |
      | sharding.xml      | {'tag':'root'} | {'tag':'schema'}       |
      | user.xml          | {'tag':'root'} | {'tag':'managerUser'}  |
      | user.xml          | {'tag':'root'} | {'tag':'shardingUser'} |
      | user.xml          | {'tag':'root'} | {'tag':'rwSplitUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="dn1" name="schema1" sqlMaxLimit="1000">
        <singleTable name="sing1"  shardingNode="dn1" />
     </schema>
    <schema shardingNode="dn4" name="schema2">
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <managerUser name="root" password="111111"  readOnly="false" maxCon="100"/>
     <shardingUser name="test" password="111111" schemas="schema1" readOnly="false" />
     <shardingUser name="test1" password="123456" schemas="schema2" readOnly="false" maxCon="150"/>
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
    """
   Then execute admin cmd "reload @@config"
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_2"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
    Then check resultset "dble_entry_table_privilege_2" has lines with following column values
      | schema-1 | table-2       | exist_metas-3 | insert-4 | update-5 | select-6 | delete-7 | is_effective-8 |
      | schema2  | no_s3         | true          | 0        | 0        | 0        | 0        | true           |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  |
      | conn_2 | true    | drop table if exists no_s3  | success |
   Then execute admin cmd "reload @@config"
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_3"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
    Then check resultset "dble_entry_table_privilege_3" has lines with following column values
      | schema-1 | table-2       | exist_metas-3 | insert-4 | update-5 | select-6 | delete-7 | is_effective-8 |
      | schema2  | no_s3         | false         | 0        | 0        | 0        | 0        | false          |

 #case dml format standard DBLE0REQ-515/DBLE0REQ-512
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
 # case the dml values format less more 4 position
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
    """
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                                                                                                 |
      | conn_0 | False   | reload @@config      | Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: [user.xml] occurred  parse errors, The detailed results are as follows . com.actiontech.dble.config.util.ConfigException: User [test]'s schema [schema1]'s privilege's dml is not correct  |
      | conn_0 | False   | dryrun               | [user.xml] occurred  parse errors, The detailed results are as follows . com.actiontech.dble.config.util.ConfigException: User [test]'s schema [schema1]'s privilege's dml is not correct  |
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
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                                                                         |
      | conn_0 | True    | reload @@config      | Reload config failure.The reason is SelfCheck### privileges's schema[schema2] was not found in the user [name:test]'s schemas  |
    Given delete the following xml segment
      | file         | parent         | child                  |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
 # case the dml values format mistake
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
    """
   Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                                                                                                                    |
      | conn_0 | true    | reload @@config      | Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: [user.xml] occurred  parse errors, The detailed results are as follows . com.actiontech.dble.config.util.ConfigException: User [test1]'s schema [schema2]'s table [no_s3]'s privilege's dml is not correct  |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
     """
      dml is not correct
     """
    Given execute linux command in "dble-1"
    """
    /opt/dble/bin/dble restart
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
         </privileges>
     </shardingUser>
     <shardingUser name="test1" password="123456" schemas="schema1,schema2" readOnly="false" maxCon="150">
         <privileges check="true">
             <schema name="schema3" dml="0111">
                <table name="no_s3" dml="0101"/>
             </schema>
         </privileges>
     </shardingUser>
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
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db      |
      | conn_1 | False   | drop table if exists test   | success | schema1 |
      | conn_1 | False   | create table test (id int)  | success | schema1 |
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
      | conn_1 | True    | drop table if exists test   | success |
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_entry_table_privilege_5"
      | conn   | toClose | sql                                       | db               |
      | conn_0 | False   | select * from dble_entry_table_privilege  | dble_information |
    Then check resultset "dble_entry_table_privilege_5" has lines with following column values
      | id-0 | schema-1 | table-2 | exist_metas-3 | insert-4 | update-5 | select-6 | delete-7 | is_effective-8 |
      | 2    | schema1  | test    | false         | 0        | 1        | 1        | 1        | false          |
      | 2    | schema1  | no_s1   | false         | 0        | 1        | 1        | 0        | false          |
      | 3    | schema2  | no_s1   | false         | 0        | 1        | 1        | 1        | false          |
      | 3    | schema1  | test    | false         | 0        | 0        | 0        | 1        | false          |
      | 3    | schema1  | no_s3   | false         | 0        | 0        | 0        | 1        | false          |
      | 3    | schema1  | no_s2   | false         | 0        | 1        | 0        | 1        | false          |
#case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                        | expect                                                  |
      | conn_0 | False   | select schema,is_effective from dble_entry_table_privilege order by table desc limit 2     | has{(('schema1', 'false'), ('schema1', 'false'))}       |
      | conn_0 | False   | select * from dble_entry_table_privilege where schema like '%2%'                           | has{((3,'schema2','no_s1','false',0,1,1,1,'false'))}    |
#case supported select max/min
      | conn_0 | False   | select max(id) from dble_entry_table_privilege                      | has{((3,),)}  |
      | conn_0 | False   | select min(id) from dble_entry_table_privilege                      | has{((2,),)}  |
#case unsupported update/delete/insert
      | conn_0 | False   | delete from dble_entry_table_privilege where is_effective='true'                         | Access denied for table 'dble_entry_table_privilege'     |
      | conn_0 | False   | update dble_entry_table_privilege set is_effective = 'a' where is_effective='true'       | Access denied for table 'dble_entry_table_privilege'     |
      | conn_0 | False   | insert into dble_entry_table_privilege values (1,'1',1,1,1)                              | Access denied for table 'dble_entry_table_privilege'     |
#case supported select where [sub-query]
      | conn_0 | False   | select table from dble_entry_table_privilege where schema in (select schema from dble_entry_schema where id =2 )   | has{(('test',), ('no_s1',), ('test',), ('no_s3',), ('no_s2',))}       |
      | conn_0 | False   | select table from dble_entry_table_privilege where schema >all (select schema from dble_entry_schema)              | length{(0)}                                                           |
      | conn_0 | False   | select table from dble_entry_table_privilege where schema <any (select schema from dble_entry_schema)              | length{(5)}                                                           |
      | conn_0 | True    | select table from dble_entry_table_privilege where schema =any (select schema from dble_entry_schema)              | length{(6)}                                                           |
