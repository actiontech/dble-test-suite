# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/4/15

Feature:  test  dble's config xml and table dble_config in dble_information to check json



  Scenario: test modify dble's config xml and restart dble #1

    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    "dbGroup":\[
    {"rwSplitMode":0,"name":"ha_group1","delayThreshold":100,"heartbeat":{"value":"select user()"},
    "dbInstance":\[{"name":"hostM1","url":"172.100.9.5:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true}\]},
    {"rwSplitMode":0,"name":"ha_group2","delayThreshold":100,"heartbeat":{"value":"select user()"},
    "dbInstance":\[{"name":"hostM2","url":"172.100.9.6:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true}\]}\],
    "schema":\[
    {"name":"schema1","sqlMaxLimit":100,"shardingNode":"dn5",
    "table":\[
    {"type":"GlobalTable","properties":{"name":"test","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"hash-two","shardingColumn":"id","name":"sharding_2_t1","shardingNode":"dn1,dn2"}},
    {"type":"ShardingTable","properties":{"function":"hash-four","shardingColumn":"id","name":"sharding_4_t1","shardingNode":"dn1,dn2,dn3,dn4"}}\]}\],
    "shardingNode":\[
    {"name":"dn1","dbGroup":"ha_group1","database":"db1"},
    {"name":"dn2","dbGroup":"ha_group2","database":"db1"},
    {"name":"dn3","dbGroup":"ha_group1","database":"db2"},
    {"name":"dn4","dbGroup":"ha_group2","database":"db2"},
    {"name":"dn5","dbGroup":"ha_group1","database":"db3"}\],
    "function":\[
    {"name":"hash-two","clazz":"Hash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-three","clazz":"Hash","property":\[{"value":"3","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-four","clazz":"Hash","property":\[{"value":"4","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-string-into-two","clazz":"StringHash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]}\],
    "user":\[
    {"type":"ManagerUser","properties":{"name":"root","password":"111111"}},
    {"type":"ShardingUser","properties":{"schemas":"schema1","name":"test","password":"111111"}}\]
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" disableHA='false' >
        <heartbeat errorRetryCount="0" timeout="10" >select user()</heartbeat>
        <dbInstance name="hostM1" password="EZGuPOlq+lyYvtnAHPYN7NOido4idWDJfdH0aAWsXzfPhxDw0FWIDoYtxy0LL45slFFtLXl9NukyJujadQEoUA==" usingDecrypt="true" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
            <property name="testOnCreate">true</property>
            <property name="testOnBorrow">false</property>
            <property name="testOnReturn">true</property>
            <property name="testWhileIdle">false</property>
            <property name="connectionTimeout">53000</property>
            <property name="connectionHeartbeatTimeout">5200</property>
            <property name="timeBetweenEvictionRunsMillis">50000</property>
            <property name="idleTimeout">90000</property>
            <property name="heartbeatPeriodMillis">30000</property>
            <property name="evictorShutdownTimeoutMillis">10000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="-1" >
        <heartbeat errorRetryCount="1" timeout="0" >select 1</heartbeat>
        <dbInstance name="hostM2" password="111111" usingDecrypt="false" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="false">
           <property name="testOnCreate">true</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="200" >
        <heartbeat errorRetryCount="3" timeout="1000" >select @@read_only</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" />
        <dbInstance name="hostS3" password="111111" usingDecrypt="false" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false" readWeight="3" >
            <property name="testOnCreate">true</property>
            <property name="testOnBorrow">true</property>
            <property name="testOnReturn">true</property>
            <property name="testWhileIdle">true</property>
            <property name="connectionTimeout">50000</property>
            <property name="connectionHeartbeatTimeout">500</property>
            <property name="timeBetweenEvictionRunsMillis">40000</property>
            <property name="idleTimeout">600030</property>
            <property name="heartbeatPeriodMillis">230000</property>
            <property name="evictorShutdownTimeoutMillis">100000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="2" name="ha_group4" delayThreshold="500" disableHA='true'>
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM4" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true" readWeight="1" disabled="true">
            <property name="testOnCreate">true</property>
            <property name="testOnBorrow">false</property>
            <property name="testWhileIdle">true</property>
            <property name="connectionTimeout">50000</property>
            <property name="connectionHeartbeatTimeout">500</property>

        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="1000" minCon="10" primary="false" readWeight="12" />
        <dbInstance name="hostS2" password="111111" usingDecrypt="false" url="172.100.9.12:3306" user="test" maxCon="1000" minCon="10" primary="false" readWeight="2" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="CrdAFIIPXnXdq7Tc2RRejBwN5pBt0diz/MM9nbLEC7IW62kIJ6Umo0DWjH6KmRGtLF7fmi6rZBB+2TEfqLMf4g==" usingDecrypt="true" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="1000" />
    <managerUser name="root1" password="111111" usingDecrypt="false" readOnly="true" maxCon="0" whiteIPs="172.100.9.8"/>
    <managerUser name="root2" password="111111" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1"/>

    <shardingUser name="test" password="ZOCAWNiqk8c5e0/A9hi7vwiyVdJyuKrlIcdeohsZ7w5p0rI5S5io92tFActLroFjzaWWlav9Zlx39AKgwHr2Lw==" usingDecrypt="true" schemas="schema1" whiteIPs="0:0:0:0:0:0:0:1"/>
    <shardingUser name="test1" password="111111" usingDecrypt="false" schemas="schema1,schema2" whiteIPs="" readOnly="false" tenant="tenant1" />
    <shardingUser name="test2" password="111111" usingDecrypt="false" schemas="schema1" whiteIPs="2001:3984:3989::12,2001:3984:3989:0:0:0:0:13"/>
    <shardingUser name="test3" password="111111" usingDecrypt="false" schemas="schema1,schema3" readOnly="true" tenant="tenant2" maxCon="0" blacklist="blacklist1"/>
    <shardingUser name="test4" password="111111" schemas="schema1,schema2" tenant="tenant3" maxCon="1000" blacklist="black2">
        <privileges check="true">
            <schema name="schema1" dml="0000" >
                <table name="tableA" dml="1111"></table>
                <table name="tableB" dml="1111"></table>
            </schema>
            <schema name="schema2" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
            </schema>
        </privileges>
    </shardingUser>

    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group4" maxCon="0" whiteIPs="2001:3984:3989:0000:0000:0000:0000:0014-2001:3984:3989:0:0:0:0:16"/>
    <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" usingDecrypt="false" tenant="tenant3"/>
    <rwSplitUser name="rwS3" password="111111" dbGroup="ha_group4" maxCon="0" blacklist="black2" />


    <blacklist name="blacklist1">
        <property name="metadataAllow">true</property>
        <property name="conditionDoubleConstAllow">false</property>
        <property name="conditionDoubleConstAllow">false</property>
    </blacklist>
    <blacklist name="black2">
        <property name="conditionDoubleConstAllow">false</property>
        <property name="conditionDoubleConstAllow">false</property>
        <property name="intersectAllow">false</property>
        <property name="metadataAllow">true</property>
    </blacklist>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sharding_1_t1" shardingNode="dn5" sqlMaxLimit="100"/>
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" incrementColumn="id2" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" sqlRequiredSharding="true"/>
        <shardingTable name="sharding_enum_string_t1" shardingNode="dn1,dn2,dn3,dn4" function="fixed_nonuniform_string_rule" shardingColumn="id"/>
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
             <childTable name="er_child" joinColumn="id" parentColumn="id" incrementColumn="id3" sqlMaxLimit="-1"/>
        </shardingTable>
        <shardingTable name="sharding_date_t1" shardingNode="dn1,dn2,dn3,dn4" function="date_default_rule" shardingColumn="id"/>
    </schema>

    <schema name="schema2" sqlMaxLimit="-1">
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="id"/>
        <globalTable name="global3" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
        <globalTable name="global4" shardingNode="dn1,dn3,dn5" cron="/10 * * * * ?" checkClass="COUNT" />
        <globalTable name="global5" shardingNode="dn1,dn3,dn5" sqlMaxLimit="200"/>
    </schema>

    <schema name="schema3" shardingNode="dn5" >
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />

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
    <function name="date_rule" class="Date">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2016-12-01</property>
        <property name="sEndDate">2017-01-9</property>
        <property name="sPartionDay">10</property>
    </function>
    <function name="date_default_rule" class="Date">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2016-12-01</property>
        <property name="sEndDate">2017-01-9</property>
        <property name="sPartionDay">10</property>
        <property name="defaultNode">0</property>
    </function>
    """
    Then Restart dble in "dble-1" success

    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    "dbGroup":\[
    {"rwSplitMode":0,"name":"ha_group1","delayThreshold":100,"disableHA":"false","heartbeat":{"value":"select user()","timeout":10,"errorRetryCount":0},
    "dbInstance":\[
    {"name":"hostM1","url":"172.100.9.5:3306","password":
    "user":"test","maxCon":1000,"minCon":10,"usingDecrypt":"true","primary":true,
    "property":\[
    {"value":"true","name":"testOnCreate"},{"value":"false","name":"testOnBorrow"},{"value":"true","name":"testOnReturn"},
    {"value":"false","name":"testWhileIdle"},{"value":"53000","name":"connectionTimeout"},{"value":"5200","name":"connectionHeartbeatTimeout"},
    {"value":"50000","name":"timeBetweenEvictionRunsMillis"},{"value":"90000","name":"idleTimeout"},
    {"value":"30000","name":"heartbeatPeriodMillis"},{"value":"10000","name":"evictorShutdownTimeoutMillis"}\]}\]},
    {"rwSplitMode":1,"name":"ha_group2","delayThreshold":-1,"heartbeat":{"value":"select 1","timeout":0,"errorRetryCount":1},
    "dbInstance":\[
    {"name":"hostM2","url":"172.100.9.3:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"usingDecrypt":"false","disabled":"false","primary":true,
    "property":\[
    {"value":"true","name":"testOnCreate"}\]}\]},
    {"rwSplitMode":2,"name":"ha_group3","delayThreshold":200,"heartbeat":{"value":"select @@read_only","timeout":1000,"errorRetryCount":3},
    "dbInstance":\[
    {"name":"hostM3","url":"172.100.9.6:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true},
    {"name":"hostS3","url":"172.100.9.2:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"usingDecrypt":"false","readWeight":"3","primary":false,
    "property":\[{"value":"true","name":"testOnCreate"},{"value":"true","name":"testOnBorrow"},{"value":"true","name":"testOnReturn"},
    {"value":"true","name":"testWhileIdle"},{"value":"50000","name":"connectionTimeout"},{"value":"500","name":"connectionHeartbeatTimeout"},
    {"value":"40000","name":"timeBetweenEvictionRunsMillis"},{"value":"600030","name":"idleTimeout"},{"value":"230000","name":"heartbeatPeriodMillis"},
    {"value":"100000","name":"evictorShutdownTimeoutMillis"}\]}\]},
    {"rwSplitMode":2,"name":"ha_group4","delayThreshold":500,"disableHA":"true","heartbeat":{"value":"show slave status"},
    "dbInstance":\[
    {"name":"hostM4","url":"172.100.9.10:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"disabled":"true","readWeight":"1","primary":true,
    "property":\[
    {"value":"true","name":"testOnCreate"},{"value":"false","name":"testOnBorrow"},
    {"value":"true","name":"testWhileIdle"},{"value":"50000","name":"connectionTimeout"},{"value":"500","name":"connectionHeartbeatTimeout"}\]},
    {"name":"hostS1","url":"172.100.9.11:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"readWeight":"12","primary":false},
    {"name":"hostS2","url":"172.100.9.12:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"usingDecrypt":"false","readWeight":"2","primary":false}\]}\],
    "schema":\[
    {"name":"schema1","sqlMaxLimit":100,"shardingNode":"dn5",
    "table":\[
    {"type":"SingleTable","properties":{"name":"sharding_1_t1","shardingNode":"dn5","sqlMaxLimit":100}},
    {"type":"ShardingTable","properties":{"function":"hash-two","shardingColumn":"id","incrementColumn":"id2","name":"sharding_2_t1","shardingNode":"dn1,dn2"}},
    {"type":"ShardingTable","properties":{"function":"hash-four","shardingColumn":"id","sqlRequiredSharding":true,"name":"sharding_4_t1","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"fixed_nonuniform_string_rule","shardingColumn":"id","name":"sharding_enum_string_t1","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"hash-four","shardingColumn":"id",
    "childTable":\[
    {"name":"er_child","joinColumn":"id","parentColumn":"id","incrementColumn":"id3","sqlMaxLimit":-1}\],
    "name":"er_parent","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"date_default_rule","shardingColumn":"id","name":"sharding_date_t1","shardingNode":"dn1,dn2,dn3,dn4"}}\]},
    {"name":"schema2","sqlMaxLimit":-1,
    "table":\[
    {"type":"ShardingTable","properties":{"function":"fixed_uniform_string_rule","shardingColumn":"id","name":"sharding_4_t3","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"GlobalTable","properties":{"checkClass":"CHECKSUM","cron":"/5 \* \* \* \* ? \*","name":"global3","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"GlobalTable","properties":{"checkClass":"COUNT","cron":"/10 \* \* \* \* ?","name":"global4","shardingNode":"dn1,dn3,dn5"}},
    {"type":"GlobalTable","properties":{"name":"global5","shardingNode":"dn1,dn3,dn5","sqlMaxLimit":200}}\]},
    {"name":"schema3","shardingNode":"dn5"}\],
    "shardingNode":\[
    {"name":"dn1","dbGroup":"ha_group1","database":"db1"},
    {"name":"dn2","dbGroup":"ha_group2","database":"db1"},
    {"name":"dn3","dbGroup":"ha_group1","database":"db2"},
    {"name":"dn4","dbGroup":"ha_group2","database":"db2"},
    {"name":"dn5","dbGroup":"ha_group1","database":"db3"}\],
    "function":\[
    {"name":"hash-two","clazz":"Hash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-three","clazz":"Hash","property":\[{"value":"3","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-four","clazz":"Hash","property":\[{"value":"4","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-string-into-two","clazz":"StringHash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-three-step10","clazz":"Hash","property":\[{"value":"3","name":"partitionCount"},{"value":"10","name":"partitionLength"}\]},
    {"name":"fixed_uniform","clazz":"Hash","property":\[{"value":"4","name":"partitionCount"},{"value":"256","name":"partitionLength"}\]},
    {"name":"fixed_nonuniform","clazz":"Hash","property":\[{"value":"2,1","name":"partitionCount"},{"value":"256,512","name":"partitionLength"}\]},
    {"name":"fixed_uniform_string_rule","clazz":"StringHash","property":\[{"value":"4","name":"partitionCount"},{"value":"256","name":"partitionLength"},{"value":"0:2","name":"hashSlice"}\]},
    {"name":"fixed_nonuniform_string_rule","clazz":"StringHash","property":\[{"value":"2,1","name":"partitionCount"},{"value":"256,512","name":"partitionLength"},{"value":"0:2","name":"hashSlice"}\]},
    {"name":"date_rule","clazz":"Date","property":\[{"value":"yyyy-MM-dd","name":"dateFormat"},{"value":"2016-12-01","name":"sBeginDate"},{"value":"2017-01-9","name":"sEndDate"},{"value":"10","name":"sPartionDay"}\]},
    {"name":"date_default_rule","clazz":"Date","property":\[{"value":"yyyy-MM-dd","name":"dateFormat"},{"value":"2016-12-01","name":"sBeginDate"},{"value":"2017-01-9","name":"sEndDate"},{"value":"10","name":"sPartionDay"},{"value":"0","name":"defaultNode"}\]}\],
    "user":\[
    {"type":"ManagerUser","properties":{"readOnly":false,"name":"root","password":
    ","usingDecrypt":"true","whiteIPs":"172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1","maxCon":1000}},
    {"type":"ManagerUser","properties":{"readOnly":true,"name":"root1","password":"111111","usingDecrypt":"false","whiteIPs":"172.100.9.8","maxCon":0}},
    {"type":"ManagerUser","properties":{"name":"root2","password":"111111","whiteIPs":"127.0.0.1,0:0:0:0:0:0:0:1"}},
    {"type":"ShardingUser","properties":{"schemas":"schema1","name":"test","password":
    ,"usingDecrypt":"true","whiteIPs":"0:0:0:0:0:0:0:1"}},
    {"type":"ShardingUser","properties":{"schemas":"schema1,schema2","tenant":"tenant1","readOnly":false,"name":"test1","password":"111111","usingDecrypt":"false","whiteIPs":""}},
    {"type":"ShardingUser","properties":{"schemas":"schema1","name":"test2","password":"111111","usingDecrypt":"false","whiteIPs":"2001:3984:3989::12,2001:3984:3989:0:0:0:0:13"}},
    {"type":"ShardingUser","properties":{"schemas":"schema1,schema3","tenant":"tenant2","readOnly":true,"blacklist":"blacklist1","name":"test3","password":"111111","usingDecrypt":"false","maxCon":0}},
    {"type":"ShardingUser","properties":{"schemas":"schema1,schema2","tenant":"tenant3","blacklist":"black2",
    "privileges":{"check":true,"schema":\[
    {"name":"schema1","dml":"0000","table":\[{"name":"tableA","dml":"1111"},{"name":"tableB","dml":"1111"}\]},{"name":"schema2","dml":"1111","table":\[{"name":"test1","dml":"0000"},{"name":"test2","dml":"0110"}\]}\]},"name":"test4","password":"111111","maxCon":1000}},
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group4","name":"rwS1","password":"111111","whiteIPs":"2001:3984:3989:0000:0000:0000:0000:0014-2001:3984:3989:0:0:0:0:16","maxCon":0}},
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group3","tenant":"tenant3","name":"rwS2","password":"111111","usingDecrypt":"false"}},
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group4","blacklist":"black2","name":"rwS3","password":"111111","maxCon":0}}],
    "blacklist":\[
    {"name":"blacklist1","property":\[{"value":"true","name":"metadataAllow"},{"value":"false","name":"conditionDoubleConstAllow"},{"value":"false","name":"conditionDoubleConstAllow"}\]},
    {"name":"black2","property":\[{"value":"false","name":"conditionDoubleConstAllow"},{"value":"false","name":"conditionDoubleConstAllow"},{"value":"false","name":"intersectAllow"},{"value":"true","name":"metadataAllow"}\]}\]}
    """


    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      $a sequenceHandlerType=1
      """
    When Add some data in "sequence_db_conf.properties"
    """
    `schema1`.`test_auto`=dn1
    """
    Then Restart dble in "dble-1" success
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    "sequence_db_conf.properties":{"`schema1`.`test_auto`":"dn1"}}
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group5" delayThreshold="-1" >
        <heartbeat errorRetryCount="1" timeout="0" >select 1</heartbeat>
        <dbInstance name="hostM2" password="111111" usingDecrypt="false" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="false">
           <property name="lifo">true</property>
        </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" failed for
    """
    db json to map occurred  parse errors, The detailed results are as follows . com.actiontech.dble.config.util.ConfigException: These properties of system are not recognized: lifo
    """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
    """
    <property name="lifo">true</property>
    """



   Scenario: test modify dble's config xml and reload dble #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" disableHA='false' >
        <heartbeat errorRetryCount="0" timeout="10" >select user()</heartbeat>
        <dbInstance name="hostM1" password="EZGuPOlq+lyYvtnAHPYN7NOido4idWDJfdH0aAWsXzfPhxDw0FWIDoYtxy0LL45slFFtLXl9NukyJujadQEoUA==" usingDecrypt="true" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
            <property name="testOnCreate">true</property>
            <property name="testOnBorrow">false</property>
            <property name="testOnReturn">true</property>
            <property name="testWhileIdle">false</property>
            <property name="connectionTimeout">53000</property>
            <property name="connectionHeartbeatTimeout">5200</property>
            <property name="timeBetweenEvictionRunsMillis">50000</property>
            <property name="idleTimeout">90000</property>
            <property name="heartbeatPeriodMillis">30000</property>
            <property name="evictorShutdownTimeoutMillis">10000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="-1" >
        <heartbeat errorRetryCount="1" timeout="0" >select 1</heartbeat>
        <dbInstance name="hostM2" password="111111" usingDecrypt="false" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="false">
           <property name="testOnCreate">true</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="200" >
        <heartbeat errorRetryCount="3" timeout="1000" >select @@read_only</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" />
        <dbInstance name="hostS3" password="111111" usingDecrypt="false" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false" readWeight="3" >
            <property name="testOnCreate">true</property>
            <property name="testOnBorrow">true</property>
            <property name="testOnReturn">true</property>
            <property name="testWhileIdle">true</property>
            <property name="connectionTimeout">50000</property>
            <property name="connectionHeartbeatTimeout">500</property>
            <property name="timeBetweenEvictionRunsMillis">40000</property>
            <property name="idleTimeout">600030</property>
            <property name="heartbeatPeriodMillis">230000</property>
            <property name="evictorShutdownTimeoutMillis">100000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="2" name="ha_group4" delayThreshold="500" disableHA='true'>
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM4" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true" readWeight="1" disabled="true">
            <property name="testOnCreate">true</property>
            <property name="testOnBorrow">false</property>
            <property name="testWhileIdle">true</property>
            <property name="connectionTimeout">50000</property>
            <property name="connectionHeartbeatTimeout">500</property>

        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="1000" minCon="10" primary="false" readWeight="12" />
        <dbInstance name="hostS2" password="111111" usingDecrypt="false" url="172.100.9.12:3306" user="test" maxCon="1000" minCon="10" primary="false" readWeight="2" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="CrdAFIIPXnXdq7Tc2RRejBwN5pBt0diz/MM9nbLEC7IW62kIJ6Umo0DWjH6KmRGtLF7fmi6rZBB+2TEfqLMf4g==" usingDecrypt="true" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1" readOnly="false" maxCon="1000" />
    <managerUser name="root1" password="111111" usingDecrypt="false" readOnly="true" maxCon="0" whiteIPs="172.100.9.8"/>
    <managerUser name="root2" password="111111" whiteIPs="127.0.0.1,0:0:0:0:0:0:0:1"/>

    <shardingUser name="test" password="ZOCAWNiqk8c5e0/A9hi7vwiyVdJyuKrlIcdeohsZ7w5p0rI5S5io92tFActLroFjzaWWlav9Zlx39AKgwHr2Lw==" usingDecrypt="true" schemas="schema1" whiteIPs="0:0:0:0:0:0:0:1"/>
    <shardingUser name="test1" password="111111" usingDecrypt="false" schemas="schema1,schema2" whiteIPs="" readOnly="false" tenant="tenant1" />
    <shardingUser name="test2" password="111111" usingDecrypt="false" schemas="schema1" whiteIPs="2001:3984:3989::12,2001:3984:3989:0:0:0:0:13"/>
    <shardingUser name="test3" password="111111" usingDecrypt="false" schemas="schema1,schema3" readOnly="true" tenant="tenant2" maxCon="0" blacklist="blacklist1"/>
    <shardingUser name="test4" password="111111" schemas="schema1,schema2" tenant="tenant3" maxCon="1000" blacklist="black2">
        <privileges check="true">
            <schema name="schema1" dml="0000" >
                <table name="tableA" dml="1111"></table>
                <table name="tableB" dml="1111"></table>
            </schema>
            <schema name="schema2" dml="1111" >
                <table name="test1" dml="0000"></table>
                <table name="test2" dml="0110"></table>
            </schema>
        </privileges>
    </shardingUser>

    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group4" maxCon="0" whiteIPs="2001:3984:3989:0000:0000:0000:0000:0014-2001:3984:3989:0:0:0:0:16"/>
    <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" usingDecrypt="false" tenant="tenant3"/>
    <rwSplitUser name="rwS3" password="111111" dbGroup="ha_group4" maxCon="0" blacklist="black2" />


    <blacklist name="blacklist1">
        <property name="metadataAllow">true</property>
        <property name="conditionDoubleConstAllow">false</property>
        <property name="conditionDoubleConstAllow">false</property>
    </blacklist>
    <blacklist name="black2">
        <property name="conditionDoubleConstAllow">false</property>
        <property name="conditionDoubleConstAllow">false</property>
        <property name="intersectAllow">false</property>
        <property name="metadataAllow">true</property>
    </blacklist>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="sharding_1_t1" shardingNode="dn5" sqlMaxLimit="100"/>
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" incrementColumn="id2" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" sqlRequiredSharding="true"/>
        <shardingTable name="sharding_enum_string_t1" shardingNode="dn1,dn2,dn3,dn4" function="fixed_nonuniform_string_rule" shardingColumn="id"/>
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
             <childTable name="er_child" joinColumn="id" parentColumn="id" incrementColumn="id3" sqlMaxLimit="-1"/>
        </shardingTable>
        <shardingTable name="sharding_date_t1" shardingNode="dn1,dn2,dn3,dn4" function="date_default_rule" shardingColumn="id"/>
    </schema>

    <schema name="schema2" sqlMaxLimit="-1">
        <shardingTable name="sharding_4_t3" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule" shardingColumn="id"/>
        <globalTable name="global3" shardingNode="dn1,dn2,dn3,dn4" cron="/5 * * * * ? *" checkClass="CHECKSUM" />
        <globalTable name="global4" shardingNode="dn1,dn3,dn5" cron="/10 * * * * ?" checkClass="COUNT" />
        <globalTable name="global5" shardingNode="dn1,dn3,dn5" sqlMaxLimit="200"/>
    </schema>

    <schema name="schema3" shardingNode="dn5" >
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />

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
    <function name="date_rule" class="Date">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2016-12-01</property>
        <property name="sEndDate">2017-01-9</property>
        <property name="sPartionDay">10</property>
    </function>
    <function name="date_default_rule" class="Date">
        <property name="dateFormat">yyyy-MM-dd</property>
        <property name="sBeginDate">2016-12-01</property>
        <property name="sEndDate">2017-01-9</property>
        <property name="sPartionDay">10</property>
        <property name="defaultNode">0</property>
    </function>
    """
    Then execute admin cmd "reload @@config_all"

    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    "dbGroup":\[
    {"rwSplitMode":0,"name":"ha_group1","delayThreshold":100,"disableHA":"false","heartbeat":{"value":"select user()","timeout":10,"errorRetryCount":0},
    "dbInstance":\[
    {"name":"hostM1","url":"172.100.9.5:3306","password":"
    ,"user":"test","maxCon":1000,"minCon":10,"usingDecrypt":"true","primary":true,
    "property":\[
    {"value":"true","name":"testOnCreate"},{"value":"false","name":"testOnBorrow"},{"value":"true","name":"testOnReturn"},
    {"value":"false","name":"testWhileIdle"},{"value":"53000","name":"connectionTimeout"},{"value":"5200","name":"connectionHeartbeatTimeout"},
    {"value":"50000","name":"timeBetweenEvictionRunsMillis"},{"value":"90000","name":"idleTimeout"},
    {"value":"30000","name":"heartbeatPeriodMillis"},{"value":"10000","name":"evictorShutdownTimeoutMillis"}\]}\]},
    {"rwSplitMode":1,"name":"ha_group2","delayThreshold":-1,"heartbeat":{"value":"select 1","timeout":0,"errorRetryCount":1},
    "dbInstance":\[
    {"name":"hostM2","url":"172.100.9.3:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"usingDecrypt":"false","disabled":"false","primary":true,
    "property":\[
    {"value":"true","name":"testOnCreate"}\]}\]},
    {"rwSplitMode":2,"name":"ha_group3","delayThreshold":200,"heartbeat":{"value":"select @@read_only","timeout":1000,"errorRetryCount":3},
    "dbInstance":\[
    {"name":"hostM3","url":"172.100.9.6:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true},
    {"name":"hostS3","url":"172.100.9.2:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"usingDecrypt":"false","readWeight":"3","primary":false,
    "property":\[{"value":"true","name":"testOnCreate"},{"value":"true","name":"testOnBorrow"},{"value":"true","name":"testOnReturn"},
    {"value":"true","name":"testWhileIdle"},{"value":"50000","name":"connectionTimeout"},{"value":"500","name":"connectionHeartbeatTimeout"},
    {"value":"40000","name":"timeBetweenEvictionRunsMillis"},{"value":"600030","name":"idleTimeout"},{"value":"230000","name":"heartbeatPeriodMillis"},
    {"value":"100000","name":"evictorShutdownTimeoutMillis"}\]}\]},
    {"rwSplitMode":2,"name":"ha_group4","delayThreshold":500,"disableHA":"true","heartbeat":{"value":"show slave status"},
    "dbInstance":\[
    {"name":"hostM4","url":"172.100.9.10:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"disabled":"true","readWeight":"1","primary":true,
    "property":\[
    {"value":"true","name":"testOnCreate"},{"value":"false","name":"testOnBorrow"},
    {"value":"true","name":"testWhileIdle"},{"value":"50000","name":"connectionTimeout"},{"value":"500","name":"connectionHeartbeatTimeout"}\]},
    {"name":"hostS1","url":"172.100.9.11:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"readWeight":"12","primary":false},
    {"name":"hostS2","url":"172.100.9.12:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"usingDecrypt":"false","readWeight":"2","primary":false}\]}\],
    "schema":\[
    {"name":"schema1","sqlMaxLimit":100,"shardingNode":"dn5",
    "table":\[
    {"type":"SingleTable","properties":{"name":"sharding_1_t1","shardingNode":"dn5","sqlMaxLimit":100}},
    {"type":"ShardingTable","properties":{"function":"hash-two","shardingColumn":"id","incrementColumn":"id2","name":"sharding_2_t1","shardingNode":"dn1,dn2"}},
    {"type":"ShardingTable","properties":{"function":"hash-four","shardingColumn":"id","sqlRequiredSharding":true,"name":"sharding_4_t1","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"fixed_nonuniform_string_rule","shardingColumn":"id","name":"sharding_enum_string_t1","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"hash-four","shardingColumn":"id",
    "childTable":\[
    {"name":"er_child","joinColumn":"id","parentColumn":"id","incrementColumn":"id3","sqlMaxLimit":-1}\],
    "name":"er_parent","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"date_default_rule","shardingColumn":"id","name":"sharding_date_t1","shardingNode":"dn1,dn2,dn3,dn4"}}\]},
    {"name":"schema2","sqlMaxLimit":-1,
    "table":\[
    {"type":"ShardingTable","properties":{"function":"fixed_uniform_string_rule","shardingColumn":"id","name":"sharding_4_t3","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"GlobalTable","properties":{"checkClass":"CHECKSUM","cron":"/5 \* \* \* \* ? \*","name":"global3","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"GlobalTable","properties":{"checkClass":"COUNT","cron":"/10 \* \* \* \* ?","name":"global4","shardingNode":"dn1,dn3,dn5"}},
    {"type":"GlobalTable","properties":{"name":"global5","shardingNode":"dn1,dn3,dn5","sqlMaxLimit":200}}\]},
    {"name":"schema3","shardingNode":"dn5"}\],
    "shardingNode":\[
    {"name":"dn1","dbGroup":"ha_group1","database":"db1"},
    {"name":"dn2","dbGroup":"ha_group2","database":"db1"},
    {"name":"dn3","dbGroup":"ha_group1","database":"db2"},
    {"name":"dn4","dbGroup":"ha_group2","database":"db2"},
    {"name":"dn5","dbGroup":"ha_group1","database":"db3"}\],
    "function":\[
    {"name":"hash-two","clazz":"Hash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-three","clazz":"Hash","property":\[{"value":"3","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-four","clazz":"Hash","property":\[{"value":"4","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-string-into-two","clazz":"StringHash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-three-step10","clazz":"Hash","property":\[{"value":"3","name":"partitionCount"},{"value":"10","name":"partitionLength"}\]},
    {"name":"fixed_uniform","clazz":"Hash","property":\[{"value":"4","name":"partitionCount"},{"value":"256","name":"partitionLength"}\]},
    {"name":"fixed_nonuniform","clazz":"Hash","property":\[{"value":"2,1","name":"partitionCount"},{"value":"256,512","name":"partitionLength"}\]},
    {"name":"fixed_uniform_string_rule","clazz":"StringHash","property":\[{"value":"4","name":"partitionCount"},{"value":"256","name":"partitionLength"},{"value":"0:2","name":"hashSlice"}\]},
    {"name":"fixed_nonuniform_string_rule","clazz":"StringHash","property":\[{"value":"2,1","name":"partitionCount"},{"value":"256,512","name":"partitionLength"},{"value":"0:2","name":"hashSlice"}\]},
    {"name":"date_rule","clazz":"Date","property":\[{"value":"yyyy-MM-dd","name":"dateFormat"},{"value":"2016-12-01","name":"sBeginDate"},{"value":"2017-01-9","name":"sEndDate"},{"value":"10","name":"sPartionDay"}\]},
    {"name":"date_default_rule","clazz":"Date","property":\[{"value":"yyyy-MM-dd","name":"dateFormat"},{"value":"2016-12-01","name":"sBeginDate"},{"value":"2017-01-9","name":"sEndDate"},{"value":"10","name":"sPartionDay"},{"value":"0","name":"defaultNode"}\]}\],
    "user":\[
    {"type":"ManagerUser","properties":{"readOnly":false,"name":"root","password":"
    ,"usingDecrypt":"true","whiteIPs":"172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1","maxCon":1000}},
    {"type":"ManagerUser","properties":{"readOnly":true,"name":"root1","password":"111111","usingDecrypt":"false","whiteIPs":"172.100.9.8","maxCon":0}},
    {"type":"ManagerUser","properties":{"name":"root2","password":"111111","whiteIPs":"127.0.0.1,0:0:0:0:0:0:0:1"}},
    {"type":"ShardingUser","properties":{"schemas":"schema1","name":"test","password":"
    ","usingDecrypt":"true","whiteIPs":"0:0:0:0:0:0:0:1"}},
    {"type":"ShardingUser","properties":{"schemas":"schema1,schema2","tenant":"tenant1","readOnly":false,"name":"test1","password":"111111","usingDecrypt":"false","whiteIPs":""}},
    {"type":"ShardingUser","properties":{"schemas":"schema1","name":"test2","password":"111111","usingDecrypt":"false","whiteIPs":"2001:3984:3989::12,2001:3984:3989:0:0:0:0:13"}},
    {"type":"ShardingUser","properties":{"schemas":"schema1,schema3","tenant":"tenant2","readOnly":true,"blacklist":"blacklist1","name":"test3","password":"111111","usingDecrypt":"false","maxCon":0}},
    {"type":"ShardingUser","properties":{"schemas":"schema1,schema2","tenant":"tenant3","blacklist":"black2",
    "privileges":{"check":true,"schema":\[
    {"name":"schema1","dml":"0000","table":\[{"name":"tableA","dml":"1111"},{"name":"tableB","dml":"1111"}\]},{"name":"schema2","dml":"1111","table":\[{"name":"test1","dml":"0000"},{"name":"test2","dml":"0110"}\]}\]},"name":"test4","password":"111111","maxCon":1000}},
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group4","name":"rwS1","password":"111111","whiteIPs":"2001:3984:3989:0000:0000:0000:0000:0014-2001:3984:3989:0:0:0:0:16","maxCon":0}},
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group3","tenant":"tenant3","name":"rwS2","password":"111111","usingDecrypt":"false"}},
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group4","blacklist":"black2","name":"rwS3","password":"111111","maxCon":0}}],
    "blacklist":\[
    {"name":"blacklist1","property":\[{"value":"true","name":"metadataAllow"},{"value":"false","name":"conditionDoubleConstAllow"},{"value":"false","name":"conditionDoubleConstAllow"}\]},
    {"name":"black2","property":\[{"value":"false","name":"conditionDoubleConstAllow"},{"value":"false","name":"conditionDoubleConstAllow"},{"value":"false","name":"intersectAllow"},{"value":"true","name":"metadataAllow"}\]}\]}
    """

    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      $a sequenceHandlerType=1
      """
    Then Restart dble in "dble-1" success
    When Add some data in "sequence_db_conf.properties"
    """
    `schema1`.`test_auto`=dn5
    """
    Then execute admin cmd "reload @@config_all"
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    "sequence_db_conf.properties":{"`schema1`.`test_auto`":"dn5"}}
    """


    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema3" shardingNode="dn5" sqlMaxLimit="-1" >
        <singleTable name="sing1" shardingNode="dn1" sqlMaxLimit="100"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    {"name":"schema3","sqlMaxLimit":-1,"shardingNode":"dn5","table":\[{"type":"SingleTable","properties":{"name":"sing1","shardingNode":"dn1","sqlMaxLimit":100}}
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS3" password="111111" dbGroup="ha_group5" maxCon="0" blacklist="black2" />
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    group[rwS3.ha_group5] for rwSplit isn't configured in db.xml
    """

    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
    """
    <rwSplitUser name="rwS3" password="111111" dbGroup="ha_group5" maxCon="0" blacklist="black2"/>
    """
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    ha_group5
    """



   Scenario: test dble_information dble_config dml  #3
    #case error dml sql
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                   | expect                                                                                                    | db               |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group4',1,'s',1,1,100,'false')   | Insert failure.The reason is incorrect integer value: 's'                                                 | dble_information |
      | conn_0 | true    | insert into dble_db_instance(name,db_group,addr,min_conn_count,max_conn_count,read_weight) value ('M111','ha_group1','172.100.9.1','1','100','1')                     | Field '[port, user, password_encrypt, primary]' doesn't have a default value and cannot be null           | dble_information |
      | conn_0 | true    | insert into dble_rw_split_entry(id,type,db_group) value('5','rwSplitUser','ha_group1')                                                                                | Field '[username, password_encrypt, max_conn_count]' doesn't have a default value and cannot be null      | dble_information |

    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    ha_group4
    M111
    rwSplitUser
    """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
    """
    ha_group4
    M111
    """
    Then check following text exist "N" in file "/opt/dble/conf/user.xml" in host "dble-1"
    """
    rwSplitUser
    """

    #case insert sql
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                    | expect         | db               |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group3','select 1',0,1,0,100,'false')                                                             | success        | dble_information |
      | conn_0 | true    | insert into dble_db_instance(name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM3','ha_group3','172.100.9.1','3306','test','111111','false','true','1','99')         | success        | dble_information |
      | conn_0 | true    | insert into dble_rw_split_entry(username,password_encrypt,encrypt_configured,max_conn_count,db_group) value ('rw1','111111','false','100','ha_group3')                                                                                 | success        | dble_information |
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group3","name":"rw1","password":"111111","usingDecrypt":"false","maxCon":100}
    {"rwSplitMode":0,"name":"ha_group3","delayThreshold":100,"disableHA":"false","heartbeat":{"value":"select 1","timeout":0,"errorRetryCount":1},
    "dbInstance":\[
    {"name":"hostM3","url":"172.100.9.1:3306","password":"111111","user":"test","maxCon":99,"minCon":1,"usingDecrypt":"false","disabled":"false","readWeight":"0","primary":true,
    "property":\[
    {"value":"30000","name":"connectionTimeout"},
    {"value":"20","name":"connectionHeartbeatTimeout"},
    {"value":"false","name":"testOnCreate"},
    {"value":"false","name":"testOnBorrow"},
    {"value":"false","name":"testOnReturn"},
    {"value":"false","name":"testWhileIdle"},
    {"value":"30000","name":"timeBetweenEvictionRunsMillis"},
    {"value":"10000","name":"evictorShutdownTimeoutMillis"},
    {"value":"600000","name":"idleTimeout"},
    {"value":"10000","name":"heartbeatPeriodMillis"}
    """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1">select 1</heartbeat>
        <dbInstance name="hostM3" url="172.100.9.1:3306" password="111111" user="test" maxCon="99" minCon="1" usingDecrypt="false" disabled="false" readWeight="0" primary="true">
            <property name="connectionTimeout">30000</property>
            <property name="connectionHeartbeatTimeout">20</property>
            <property name="testOnCreate">false</property>
            <property name="testOnBorrow">false</property>
            <property name="testOnReturn">false</property>
            <property name="testWhileIdle">false</property>
            <property name="timeBetweenEvictionRunsMillis">30000</property>
            <property name="evictorShutdownTimeoutMillis">10000</property>
            <property name="idleTimeout">600000</property>
            <property name="heartbeatPeriodMillis">10000</property>
        </dbInstance>
    </dbGroup>
    """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
    """
    <rwSplitUser name="rw1" password="111111" usingDecrypt="false" maxCon="100" dbGroup="ha_group3"/>
    """

    #case update sql
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                       | expect         | db               |
      | conn_0 | true    | update dble_db_group set heartbeat_stmt='select user()',heartbeat_timeout=1 where name = 'ha_group3'      | success        | dble_information |
      | conn_0 | true    | update dble_db_instance set max_conn_count= '999' where db_group = 'ha_group3'                            | success        | dble_information |
      | conn_0 | true    | update dble_rw_split_entry set max_conn_count = '1000' where db_group = 'ha_group3'                       | success        | dble_information |
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group3","name":"rw1","password":"111111","usingDecrypt":"false","maxCon":1000}
    {"rwSplitMode":0,"name":"ha_group3","delayThreshold":100,"disableHA":"false","heartbeat":{"value":"select user()","timeout":1,"errorRetryCount":1},
    "dbInstance":\[
    {"name":"hostM3","url":"172.100.9.1:3306","password":"111111","user":"test","maxCon":999,"minCon":1,"usingDecrypt":"false","disabled":"false","id":"hostM3","readWeight":"0","primary":true,
    "property":\[
    {"value":"30000","name":"connectionTimeout"},
    {"value":"20","name":"connectionHeartbeatTimeout"},
    {"value":"false","name":"testOnCreate"},
    {"value":"false","name":"testOnBorrow"},
    {"value":"false","name":"testOnReturn"},
    {"value":"false","name":"testWhileIdle"},
    {"value":"30000","name":"timeBetweenEvictionRunsMillis"},
    {"value":"10000","name":"evictorShutdownTimeoutMillis"},
    {"value":"600000","name":"idleTimeout"},
    {"value":"10000","name":"heartbeatPeriodMillis"}
    """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" disableHA="false">
        <heartbeat timeout="1" errorRetryCount="1">select user()</heartbeat>
        <dbInstance name="hostM3" url="172.100.9.1:3306" password="111111" user="test" maxCon="999" minCon="1" usingDecrypt="false" disabled="false" id="hostM3" readWeight="0" primary="true">
            <property name="connectionTimeout">30000</property>
            <property name="connectionHeartbeatTimeout">20</property>
            <property name="testOnCreate">false</property>
            <property name="testOnBorrow">false</property>
            <property name="testOnReturn">false</property>
            <property name="testWhileIdle">false</property>
            <property name="timeBetweenEvictionRunsMillis">30000</property>
            <property name="evictorShutdownTimeoutMillis">10000</property>
            <property name="idleTimeout">600000</property>
            <property name="heartbeatPeriodMillis">10000</property>
        </dbInstance>
    </dbGroup>
    """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rw1" password="111111" usingDecrypt="false" maxCon="1000" dbGroup="ha_group3"/>
    """

    #case delete sql
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                  | expect         | db               |
      | conn_0 | true    | delete from dble_rw_split_entry where db_group = 'ha_group3'                         | success        | dble_information |
      | conn_0 | true    | delete from dble_db_instance where db_group = 'ha_group3'                            | success        | dble_information |
      | conn_0 | true    | delete from dble_db_group where name='ha_group3'                                     | success        | dble_information |
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group3","name":"rw1","password":"111111","usingDecrypt":"false","maxCon":1000}
    {"rwSplitMode":0,"name":"ha_group3","delayThreshold":100,"disableHA":"false","heartbeat":{"value":"select user()","timeout":1,"errorRetryCount":1},
    {"name":"hostM3","url":"172.100.9.1:3306","password":"111111","user":"test","maxCon":999,"minCon":1,"usingDecrypt":"false","disabled":"false","id":"hostM3","readWeight":"0","primary":true,
    {"value":"30000","name":"connectionTimeout"},
    {"value":"20","name":"connectionHeartbeatTimeout"},
    {"value":"false","name":"testOnCreate"},
    {"value":"false","name":"testOnBorrow"},
    {"value":"false","name":"testOnReturn"},
    {"value":"false","name":"testWhileIdle"},
    {"value":"30000","name":"timeBetweenEvictionRunsMillis"},
    {"value":"10000","name":"evictorShutdownTimeoutMillis"},
    {"value":"600000","name":"idleTimeout"},
    {"value":"10000","name":"heartbeatPeriodMillis"}
    """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" disableHA="false">
        <heartbeat timeout="1" errorRetryCount="1">select user()</heartbeat>
        <dbInstance name="hostM3" url="172.100.9.1:3306" password="111111" user="test" maxCon="999" minCon="1" usingDecrypt="false" disabled="false" id="hostM3" readWeight="0" primary="true">
            <property name="connectionTimeout">30000</property>
            <property name="connectionHeartbeatTimeout">20</property>
            <property name="testOnCreate">false</property>
            <property name="testOnBorrow">false</property>
            <property name="testOnReturn">false</property>
            <property name="testWhileIdle">false</property>
            <property name="timeBetweenEvictionRunsMillis">30000</property>
            <property name="evictorShutdownTimeoutMillis">10000</property>
            <property name="idleTimeout">600000</property>
            <property name="heartbeatPeriodMillis">10000</property>
    """
    Then check following text exist "N" in file "/opt/dble/conf/user.xml" in host "dble-1"
    """
    <rwSplitUser name="rw1" password="111111" usingDecrypt="false" maxCon="1000" dbGroup="ha_group3"/>
    """



   Scenario: test dble_information dble_config dml on btrace #4
    #  DBLE0REQ-1061
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-DprocessorExecutor=/d
      $a -DprocessorExecutor=4
      """
    Given Restart dble in "dble-1" success

    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                    | expect         | db               |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group4','select 1',0,1,2,100,'false')                                                             | success        | dble_information |
      | conn_0 | true    | insert into dble_db_instance(name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM4','ha_group4','172.100.9.2','3306','test','111111','false','true','1','100')        | success        | dble_information |
      | conn_0 | true    | insert into dble_rw_split_entry(username,password_encrypt,encrypt_configured,max_conn_count,db_group) value ('rw1','111111','false','100','ha_group4')                                                                                 | success        | dble_information |

    Given delete file "/opt/dble/BtraceAboutxmlJson.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutxmlJson.java.log" on "dble-1"
    Given update file content "./assets/BtraceAboutxmlJson.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /syncJsonToLocal/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAboutxmlJson.java" in "dble-1"
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                           | db               |
      | conn_0 | true    | delete from dble_rw_split_entry where db_group = 'ha_group4'  | dble_information |
    Then check btrace "BtraceAboutxmlJson.java" output in "dble-1" with "1" times
    """
    get into sleep
    """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                               | expect                                                                                               | db               |
      | conn_1 | false   | insert into dble_rw_split_entry(username,password_encrypt,encrypt_configured,max_conn_count,db_group) value ('rw2','111111','false','100','ha_group4')            | Other threads are executing management commands(insert/update/delete), please try again later.       | dble_information |
      | conn_1 | false   | update dble_db_group set heartbeat_stmt='select user()',heartbeat_timeout=7877 where name = 'ha_group4'                                                           | Other threads are executing management commands(insert/update/delete), please try again later.       | dble_information |
      | conn_1 | false   | update dble_db_instance set max_conn_count= '7833' where db_group = 'ha_group4'                                                                                   | Other threads are executing management commands(insert/update/delete), please try again later.       | dble_information |
      | conn_1 | false   | select * from dble_config           | hasNoStr{rw2}             | dble_information |
      | conn_1 | false   | select * from dble_config           | hasNoStr{7877}            | dble_information |
      | conn_1 | false   | select * from dble_config           | hasNoStr{7833}            | dble_information |

    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                       | db               |
      | conn_3 | true    | reload @@config_all       | dble_information |

    Given stop btrace script "BtraceAboutxmlJson.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutxmlJson.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutxmlJson.java.log" on "dble-1"



   Scenario: test dble_information dble_config dml about some special case #5
    #  DBLE0REQ-1060
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                             | expect          | db               |
      | conn_0 | false   | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group3','select 1',0,1,0,100,'false')                                                      | success         | dble_information |
      | conn_0 | false   | insert into dble_db_instance(name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM3','ha_group3','172.100.9.1','3306','test','111111','false','true','1','99')  | success         | dble_information |
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    {"dbGroup":\[
    {"rwSplitMode":0,"name":"ha_group1","delayThreshold":100,"heartbeat":{"value":"select user()"},"dbInstance":\[{"name":"hostM1","url":"172.100.9.5:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true}\]},
    {"rwSplitMode":0,"name":"ha_group2","delayThreshold":100,"heartbeat":{"value":"select user()"},"dbInstance":\[{"name":"hostM2","url":"172.100.9.6:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true}\]},
    {"rwSplitMode":0,"name":"ha_group3","delayThreshold":100,"disableHA":"false","heartbeat":{"value":"select 1","timeout":0,"errorRetryCount":1},
    "dbInstance":\[{"name":"hostM3","url":"172.100.9.1:3306","password":"111111","user":"test","maxCon":99,"minCon":1,"usingDecrypt":"false","disabled":"false","readWeight":"0","primary":true,
    "property":\[
    {"value":"30000","name":"connectionTimeout"},{"value":"20","name":"connectionHeartbeatTimeout"},{"value":"false","name":"testOnCreate"},{"value":"false","name":"testOnBorrow"},{"value":"false","name":"testOnReturn"},
    {"value":"false","name":"testWhileIdle"},{"value":"30000","name":"timeBetweenEvictionRunsMillis"},{"value":"10000","name":"evictorShutdownTimeoutMillis"},{"value":"600000","name":"idleTimeout"},{"value":"10000","name":"heartbeatPeriodMillis"}\]}\]}\],
    "schema":\[
    {"name":"schema1","sqlMaxLimit":100,"shardingNode":"dn5",
    "table":\[
    {"type":"GlobalTable","properties":{"name":"test","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"hash-two","shardingColumn":"id","name":"sharding_2_t1","shardingNode":"dn1,dn2"}},
    {"type":"ShardingTable","properties":{"function":"hash-four","shardingColumn":"id","name":"sharding_4_t1","shardingNode":"dn1,dn2,dn3,dn4"}}\]}\],
    "shardingNode":\[{"name":"dn1","dbGroup":"ha_group1","database":"db1"},{"name":"dn2","dbGroup":"ha_group2","database":"db1"},{"name":"dn3","dbGroup":"ha_group1","database":"db2"},{"name":"dn4","dbGroup":"ha_group2","database":"db2"},{"name":"dn5","dbGroup":"ha_group1","database":"db3"}\],
    "function":\[
    {"name":"hash-two","clazz":"Hash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-three","clazz":"Hash","property":\[{"value":"3","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-four","clazz":"Hash","property":\[{"value":"4","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-string-into-two","clazz":"StringHash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]}\],
    "user":\[{"type":"ManagerUser","properties":{"name":"root","password":"111111"}},{"type":"ShardingUser","properties":{"schemas":"schema1","name":"test","password":"111111"}}\]}
    """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                                                                                           | expect                                                                                   | db               |
      | conn_0 | false    | insert into dble_rw_split_entry(username,password_encrypt,encrypt_configured,max_conn_count,db_group) value ('rw1','111111','false','100','ha_group3')        | success                                                                                  | dble_information |
      | conn_0 | false    | update dble_rw_split_entry set max_conn_count = '-1' where db_group = 'ha_group3'                                                                             | Update failure.The reason is Column 'max_conn_count' value cannot be less than 0         | dble_information |
      | conn_0 | false    | insert into dble_rw_split_entry(username,password_encrypt,encrypt_configured,max_conn_count,db_group) value ('rw4','111111','false','-1','ha_group3')         | Insert failure.The reason is Column 'max_conn_count' value cannot be less than 0         | dble_information |
      | conn_0 | false    | insert into dble_rw_split_entry(username,password_encrypt,encrypt_configured,max_conn_count,db_group) value ('rw4','111111','false','0','ha_group3')          | success                                                                                  | dble_information |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | conn   | toClose | sql                               |
      | conn_0 | False   | select * from dble_rw_split_entry |
    Then check resultset "rs_A" has lines with following column values
      | id-0 | type-1   | username-2 | encrypt_configured-4 | conn_attr_key-5 | conn_attr_value-6 | white_ips-7 | max_conn_count-8 | blacklist-9 | db_group-10 |
      | 3    | username | rw1        | false                | None            | None              | None        | 100              | None        | ha_group3   |
      | 4    | username | rw4        | false                | None            | None              | None        | no limit         | None        | ha_group3   |

    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    "user":\[
    {"type":"ManagerUser","properties":{"name":"root","password":"111111"}},
    {"type":"ShardingUser","properties":{"schemas":"schema1","name":"test","password":"111111"}},
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group3","name":"rw1","password":"111111","usingDecrypt":"false","maxCon":100}},
    {"type":"RwSplitUser","properties":{"dbGroup":"ha_group3","name":"rw4","password":"111111","usingDecrypt":"false","maxCon":0}}\]}
    """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                | expect         | db               |
      | conn_0 | false    | delete from dble_rw_split_entry where db_group = 'ha_group3'       | success        | dble_information |
      | conn_0 | true     | delete from dble_rw_split_entry where id=4                         | success        | dble_information |



   Scenario: test dble_information dble_config dml about some special issue #6
    #  DBLE0REQ-1158
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      $a sequenceHandlerType=1
      """
    Then Restart dble in "dble-1" success
    When Add some data in "sequence_db_conf.properties"
    """
    `schema1`.`test_auto`=dn5
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql                                                                                                                                                                            | expect           | db               |
      | conn_0 | true     | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group4','select 1',0,1,0,100,'false')     | success          | dble_information |
    Then execute "admin" cmd  in "dble-1" at background
      | conn   | toClose | sql                         | db               |
      | conn_1 | True    | select * from dble_config   | dble_information |
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    """
    {"dbGroup":\[
    {"rwSplitMode":0,"name":"ha_group1","delayThreshold":100,"heartbeat":{"value":"select user()"},"dbInstance":\[{"name":"hostM1","url":"172.100.9.5:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true}\]},
    {"rwSplitMode":0,"name":"ha_group2","delayThreshold":100,"heartbeat":{"value":"select user()"},"dbInstance":\[{"name":"hostM2","url":"172.100.9.6:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true}\]}\],
    "schema":\[
    {"name":"schema1","sqlMaxLimit":100,"shardingNode":"dn5",
    "table":\[
    {"type":"GlobalTable","properties":{"name":"test","shardingNode":"dn1,dn2,dn3,dn4"}},
    {"type":"ShardingTable","properties":{"function":"hash-two","shardingColumn":"id","name":"sharding_2_t1","shardingNode":"dn1,dn2"}},
    {"type":"ShardingTable","properties":{"function":"hash-four","shardingColumn":"id","name":"sharding_4_t1","shardingNode":"dn1,dn2,dn3,dn4"}}\]}\],
    "shardingNode":\[{"name":"dn1","dbGroup":"ha_group1","database":"db1"},{"name":"dn2","dbGroup":"ha_group2","database":"db1"},{"name":"dn3","dbGroup":"ha_group1","database":"db2"},{"name":"dn4","dbGroup":"ha_group2","database":"db2"},{"name":"dn5","dbGroup":"ha_group1","database":"db3"}\],
    "function":\[
    {"name":"hash-two","clazz":"Hash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-three","clazz":"Hash","property":\[{"value":"3","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-four","clazz":"Hash","property":\[{"value":"4","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
    {"name":"hash-string-into-two","clazz":"StringHash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]}\],
    "user":\[{"type":"ManagerUser","properties":{"name":"root","password":"111111"}},{"type":"ShardingUser","properties":{"schemas":"schema1","name":"test","password":"111111"}}\],
    "sequence_db_conf.properties":{"`schema1`.`test_auto`":"dn5"}}
    """
