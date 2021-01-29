# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_algorithm test

   Scenario:  dble_algorithm  table #1
#case desc dble_algorithm
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_algorithm_1"
      | conn   | toClose | sql                 | db               |
      | conn_0 | False   | desc dble_algorithm | dble_information |
    Then check resultset "dble_algorithm_1" has lines with following column values
      | Field-0 | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name    | varchar(64) | NO     | PRI   | None      |         |
      | key     | varchar(64) | NO     | PRI   | None      |         |
      | value   | text        | NO     |       | None      |         |
      | is_file | varchar(5)  | NO     |       | None      |         |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                             | expect       | db               |
      | conn_0 | False   | desc dble_algorithm             | length{(4)}  | dble_information |
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_algorithm_2"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select * from dble_algorithm | dble_information |
    Then check resultset "dble_algorithm_2" has lines with following column values
      | name-0               | key-1           | value-2                                              | is_file-3 |
      | hash-two             | class           | com.actiontech.dble.route.function.PartitionByLong   | false     |
      | hash-two             | partitionCount  | 2                                                    | false     |
      | hash-two             | partitionLength | 1                                                    | false     |
      | hash-three           | class           | com.actiontech.dble.route.function.PartitionByLong   | false     |
      | hash-three           | partitionCount  | 3                                                    | false     |
      | hash-three           | partitionLength | 1                                                    | false     |
      | hash-four            | class           | com.actiontech.dble.route.function.PartitionByLong   | false     |
      | hash-four            | partitionCount  | 4                                                    | false     |
      | hash-four            | partitionLength | 1                                                    | false     |
      | hash-string-into-two | class           | com.actiontech.dble.route.function.PartitionByString | false     |
      | hash-string-into-two | partitionCount  | 2                                                    | false     |
      | hash-string-into-two | partitionLength | 1                                                    | false     |

#  case change sharding.xml add some schema/function  and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sharding_1_t1" shardingNode="dn5" />
        <singleTable name="sharding_1_t2" shardingNode="dn5" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_2_t2" shardingNode="dn3,dn4" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_3_t1" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="sharding_enum_t1" shardingNode="dn1,dn2,dn3,dn4" function="enum_integer_rule" shardingColumn="id"/>
        <shardingTable name="sharding_enum_string_t1" shardingNode="dn1,dn2,dn3,dn4" function="enum_string_rule" shardingColumn="id"/>
    </schema>

    <schema name="schema2" sqlMaxLimit="100">
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="id"/>
        <globalTable name="global_4_t1" shardingNode="dn1,dn2,dn3,dn4" />
        <globalTable name="global_4_t2" shardingNode="dn1,dn2,dn3,dn4" />
    </schema>

    <schema name="schema3" >
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <function name="hash-two" class="Hash">
        <property name="partitionCount">2</property>
        <property name="partitionLength">1</property>
    </function>
    <function name="hash-three" class="Hash">
        <property name="partitionCount">3</property>
        <property name="partitionLength">1</property>
    </function>
    <function name="hash-four" class="Hash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">1</property>
    </function>
    <function name="hash-three-step10" class="Hash">
        <property name="partitionCount">3</property>
        <property name="partitionLength">10</property>
    </function>
    <function name="fixed_uniform" class="Hash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
    </function>
    <function name="fixed_nonuniform" class="Hash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
    </function>
    <function name="fixed_uniform_string_rule" class="StringHash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
        <property name="hashSlice">0:2</property>
    </function>
    <function name="fixed_nonuniform_string_rule" class="StringHash">
        <property name="partitionCount">2,1</property>
        <property name="partitionLength">256,512</property>
         <property name="hashSlice">0:2</property>
    </function>
     <function name="enum_integer_rule" class="Enum">
         <property name="mapFile">enum-integer.txt</property>
         <property name="type">0</property>
         <property name="defaultNode">0</property>
     </function>
         <function name="enum_string_rule" class="Enum">
         <property name="mapFile">enum-string.txt</property>
         <property name="type">1</property>
         <property name="defaultNode">0</property>
     </function>
     <function name="range_rule" class="NumberRange">
         <property name="mapFile">range.txt</property>
     </function>
     <function name="range_string" class="NumberRange">
         <property name="mapFile">range_default.txt</property>
         <property name="defaultNode">3</property>
     </function>
     <function name="date_rule" class="Date">
         <property name="dateFormat">yyyy-MM-dd</property>
         <property name="sBeginDate">2020-09-18</property>
         <property name="sEndDate">2020-11-11</property>
         <property name="sPartionDay">10</property>
     </function>
     <function name="date_default_rule" class="Date">
         <property name="dateFormat">yyyy-MM-dd</property>
         <property name="sBeginDate">2020-09-18</property>
         <property name="sEndDate">2020-11-11</property>
         <property name="sPartionDay">10</property>
         <property name="defaultNode">0</property>
     </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
    """
    When Add some data in "enum-integer.txt"
      """
      10000000=0
      20000000=0
      30000000=0
      40000000=0
      50000000=0
      60000000=1
      70000000=1
      80000000=1
      90000000=1
      100000000=1
      110000000=2
      120000000=2
      130000000=2
      140000000=2
      150000000=2
      160000000=3
      170000000=3
      180000000=3
      190000000=3
      200000000=3
      210000000=0
      210000000=0
      220000000=0
      230000000=0
      240000000=0
      250000000=1
      260000000=1
      270000000=1
      280000000=1
      290000000=1
      300000000=1
      310000000=2
      310000000=2
      320000000=2
      330000000=2
      340000000=2
      350000000=3
      360000000=3
      370000000=3
      380000000=3
      390000000=3
      400000000=0
      410000000=0
      420000000=0
      430000000=0
      440000000=1
      450000000=1
      460000000=1
      470000000=1
      480000000=1
      490000000=2
      500000000=2
      510000000=2
      510000000=2
      520000000=2
      530000000=3
      540000000=3
      550000000=3
      560000000=3
      570000000=3
      580000000=0
      590000000=0
      600000000=0
      400000001=0
      410000001=0
      420000001=0
      430000001=0
      440000001=1
      450000001=1
      460000001=1
      470000001=1
      480000001=1
      490000001=2
      500000001=2
      510000001=2
      510000001=2
      520000001=2
      530000001=3
      540000001=3
      550000001=3
      560000001=3
      570000001=3
      580000001=0
      590000001=0
      600000001=0
      DEFAULT_NODE=1
      """
    When Add some data in "enum-string.txt"
    """
    aaa=0
    bbb=1
    ccc=2
    ddd=3
    DEFAULT_NODE=0
    """
    When Add some data in "range.txt"
    """
    0-255=0
    256-511=1
    512-767=2
    768-1024=3
    """
    When Add some data in "range_default.txt"
    """
    0-255=0
    256-511=1
    512-767=2
    """
#    Then execute admin cmd "reload @@config"
    Then Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_algorithm_3"
      | conn   | toClose | sql                                | db               |
      | conn_0 | False   | select * from dble_algorithm       | dble_information |
    Then check resultset "dble_algorithm_3" has lines with following column values
      | name-0                       | key-1           | value-2                                                      | is_file-3 |
      | hash-two                     | class           | com.actiontech.dble.route.function.PartitionByLong           | false     |
      | hash-two                     | partitionCount  | 2                                                            | false     |
      | hash-two                     | partitionLength | 1                                                            | false     |
      | hash-three                   | class           | com.actiontech.dble.route.function.PartitionByLong           | false     |
      | hash-three                   | partitionCount  | 3                                                            | false     |
      | hash-three                   | partitionLength | 1                                                            | false     |
      | hash-four                    | class           | com.actiontech.dble.route.function.PartitionByLong           | false     |
      | hash-four                    | partitionCount  | 4                                                            | false     |
      | hash-four                    | partitionLength | 1                                                            | false     |
      | hash-string-into-two         | class           | com.actiontech.dble.route.function.PartitionByString         | false     |
      | hash-string-into-two         | partitionCount  | 2                                                            | false     |
      | hash-string-into-two         | partitionLength | 1                                                            | false     |
      | hash-three-step10            | class           | com.actiontech.dble.route.function.PartitionByLong           | false     |
      | hash-three-step10            | partitionCount  | 3                                                            | false     |
      | hash-three-step10            | partitionLength | 10                                                           | false     |
      | fixed_uniform                | class           | com.actiontech.dble.route.function.PartitionByLong           | false     |
      | fixed_uniform                | partitionCount  | 4                                                            | false     |
      | fixed_uniform                | partitionLength | 256                                                          | false     |
      | fixed_nonuniform             | class           | com.actiontech.dble.route.function.PartitionByLong           | false     |
      | fixed_nonuniform             | partitionCount  | 2,1                                                          | false     |
      | fixed_nonuniform             | partitionLength | 256,512                                                      | false     |
      | fixed_uniform_string_rule    | class           | com.actiontech.dble.route.function.PartitionByString         | false     |
      | fixed_uniform_string_rule    | partitionCount  | 4                                                            | false     |
      | fixed_uniform_string_rule    | partitionLength | 256                                                          | false     |
      | fixed_uniform_string_rule    | hashSlice       | 0:2                                                          | false     |
      | fixed_nonuniform_string_rule | class           | com.actiontech.dble.route.function.PartitionByString         | false     |
      | fixed_nonuniform_string_rule | partitionCount  | 2,1                                                          | false     |
      | fixed_nonuniform_string_rule | partitionLength | 256,512                                                      | false     |
      | fixed_nonuniform_string_rule | hashSlice       | 0:2                                                          | false     |
      | enum_integer_rule            | class           | com.actiontech.dble.route.function.PartitionByFileMap        | false     |
      | enum_integer_rule            | mapFile         | enum-integer.txt                                             | true      |
      | enum_integer_rule            | defaultNode     | 0                                                            | false     |
      | enum_integer_rule            | type            | 0                                                            | false     |
      | enum_string_rule             | class           | com.actiontech.dble.route.function.PartitionByFileMap        | false     |
      | enum_string_rule             | mapFile         | {"aaa":"0","bbb":"1","ccc":"2","ddd":"3","DEFAULT_NODE":"0"} | false     |
      | enum_string_rule             | defaultNode     | 0                                                            | false     |
      | enum_string_rule             | type            | 1                                                            | false     |
      | range_rule                   | class           | com.actiontech.dble.route.function.AutoPartitionByLong       | false     |
      | range_rule                   | mapFile         | {"0-255":"0","256-511":"1","512-767":"2","768-1024":"3"}     | false     |
      | range_string                 | class           | com.actiontech.dble.route.function.AutoPartitionByLong       | false     |
      | range_string                 | mapFile         | {"0-255":"0","256-511":"1","512-767":"2"}                    | false     |
      | range_string                 | defaultNode     | 3                                                            | false     |
      | date_rule                    | class           | com.actiontech.dble.route.function.PartitionByDate           | false     |
      | date_rule                    | sBeginDate      | 2020-09-18                                                   | false     |
      | date_rule                    | dateFormat      | yyyy-MM-dd                                                   | false     |
      | date_rule                    | sPartionDay     | 10                                                           | false     |
      | date_rule                    | sEndDate        | 2020-11-11                                                   | false     |
      | date_default_rule            | class           | com.actiontech.dble.route.function.PartitionByDate           | false     |
      | date_default_rule            | defaultNode     | 0                                                            | false     |
      | date_default_rule            | sBeginDate      | 2020-09-18                                                   | false     |
      | date_default_rule            | dateFormat      | yyyy-MM-dd                                                   | false     |
      | date_default_rule            | sPartionDay     | 10                                                           | false     |
      | date_default_rule            | sEndDate        | 2020-11-11                                                   | false     |
#case supported select limit/order by/where like
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                         | expect                                                                                           |
      | conn_0 | False   | select * from dble_algorithm limit 1                        | has{(('hash-two', 'class', 'com.actiontech.dble.route.function.PartitionByLong', 'false'),)}     |
      | conn_0 | False   | select * from dble_algorithm order by key desc limit 1      | has{(('enum_integer_rule', 'type', '0', 'false'),)}                                              |
      | conn_0 | False   | select * from dble_algorithm where name like '%da%'         | length{(11)}                                                                                     |
#case supported select max/min
      | conn_0 | False   | select min(value) from dble_algorithm                       | has{(('0',),)}       |
      | conn_0 | False   | select count(*) from dble_algorithm group by name           | has{((6,), (5,), (4,), (4,), (3,), (4,), (3,), (4,), (3,), (3,), (3,), (3,), (3,), (2,), (3,))}  |
#case supported select field and where [sub-query]
      | conn_0 | False   | select name,key from dble_algorithm where is_file in (select is_file from dble_algorithm where value ='enum-integer.txt')     | has{(('enum_integer_rule','mapFile',))}     |
      | conn_0 | False   | select name,key from dble_algorithm where is_file >all (select is_file from dble_algorithm where value ='enum-integer.txt')   | length{(0)}                                 |
      | conn_0 | False   | select name,key from dble_algorithm where is_file <any (select is_file from dble_algorithm where value ='enum-integer.txt')   | length{(52)}                                |
      | conn_0 | False   | select name,key from dble_algorithm where is_file = (select is_file from dble_algorithm where value ='enum-integer.txt')      | has{(('enum_integer_rule','mapFile',))}     |
      | conn_0 | False   | select name,key from dble_algorithm where is_file = any (select is_file from dble_algorithm where value ='enum-integer.txt')  | has{(('enum_integer_rule','mapFile',))}     |
      | conn_0 | False   | select id,sharding_column,algorithm_name from dble_sharding_table where algorithm_name in  (select name from dble_algorithm where is_file ='true')  | has{(('C7', 'ID', 'enum_integer_rule'),)}     |
#case insupported dml
      | conn_0 | False   | delete from dble_algorithm where name='date_rule'               | Access denied for table 'dble_algorithm'   |
      | conn_0 | False   | update dble_algorithm set name = 'a' where name='date_rule'     | Access denied for table 'dble_algorithm'   |
      | conn_0 | True    | insert into dble_algorithm values ('a','1','a','1')             | Access denied for table 'dble_algorithm'   |

#case change sharding.xml remove some schema or function,then reload config to check
    Given delete the following xml segment
      | file         | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="new-two" shardingColumn="id" />
    </schema>

    <function name="new-two" class="Hash">
        <property name="partitionCount">2</property>
        <property name="partitionLength">10</property>
    </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test" password="111111" schemas="schema1"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_algorithm_4"
      | conn   | toClose | sql                          | db               |
      | conn_0 | true    | select * from dble_algorithm | dble_information |
    Then check resultset "dble_algorithm_4" has lines with following column values
      | name-0              | key-1           | value-2                                              | is_file-3 |
      | new-two             | class           | com.actiontech.dble.route.function.PartitionByLong   | false     |
      | new-two             | partitionCount  | 2                                                    | false     |
      | new-two             | partitionLength | 10                                                   | false     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_algorithm_5"
      | conn   | toClose | sql                                                           | db               |
      | conn_0 | True    | show @@algorithm where schema=schema1 and table=sharding_2_t1 | dble_information |
    Then check resultset "dble_algorithm_5" has lines with following column values
      | KEY-0           | VALUE-1                                            |
      | TYPE            | SHARDING TABLE                                     |
      | COLUMN          | ID                                                 |
      | CLASS           | com.actiontech.dble.route.function.PartitionByLong |
      | partitionCount  | 2                                                  |
      | partitionLength | 10                                                 |