Feature:# multi-tenancy, user-Permission
  @current
  Scenario: #1 multi-tenancy
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytestA">
        <table dataNode="dn1,dn2,dn3,dn4" name="test1" rule="hash-four"/>
        <table dataNode="dn1,dn2,dn3,dn4" name="test2" rule="hash-four"/>
    </schema>
    <schema name="mytestB">
        <table dataNode="dn5,dn6,dn7,dn8" name="test1" rule="hash-four"/>
    </schema>
    <schema name="mytestC">
        <table dataNode="dn1,dn2,dn3,dn4,dn5,dn6,dn7,dn8" name="sbtestC1" rule="eight-long"/>
    </schema>
    <schema name="mytestD">
        <table dataNode="dn1,dn2,dn3,dn4,dn5,dn6,dn7,dn8" name="sbtestD1" rule="eight-long"/>
    </schema>
    <dataNode dataHost="172.100.9.6" database="db3" name="dn6"/>
    <dataNode dataHost="172.100.9.5" database="db4" name="dn7"/>
    <dataNode dataHost="172.100.9.6" database="db4" name="dn8"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="eight-long">
            <rule>
                <columns>id</columns>
                <algorithm>eight</algorithm>
            </rule>
        </tableRule>
        <function class="Hash" name="eight">
            <property name="partitionCount">8</property>
            <property name="partitionLength">1</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="testA">
        <property name="password">testA</property>
        <property name="schemas">mytestA</property>
    </user>
    <user name="testB">
        <property name="password">testB</property>
        <property name="schemas">mytestB</property>
    </user>
    <user name="testC">
        <property name="password">testC</property>
        <property name="schemas">mytestC</property>
    </user>
    <user name="testD">
        <property name="password">testD</property>
        <property name="schemas">mytestD</property>
    </user>
    """
    Then execute admin cmd "reload @@config_all"

    #Standalone database: A tenant a database
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                   | expect            | db     |
        | testA| testA  | conn_0 | False    | show databases                        | has{('mytestA',)},hasnot{('mytestB',)}  |        |
        | testA| testA  | conn_0 | False    | use mytestB                           | Access denied for user |   |
        | testA| testA  | conn_0 | False    | drop table if exists mytestA.test2    | success           |        |
        | testA| testA  | conn_0 | False    | create table mytestA.test2(id int)    | success           |        |
        | testA| testA  | conn_0 | True     | drop table if exists mytestA.test2    | success           |        |
        | testB| testB  | conn_1 | False    | show databases                        | has{('mytestB',)},hasnot{('mytestA',)}  |        |
        | testB| testB  | conn_1 | False    | use mytestA                           | Access denied for user |   |
        | testB| testB  | conn_1 | False    | drop table if exists mytestB.test1    | success           |        |
        | testB| testB  | conn_1 | False    | create table mytestB.test1(id int)    | success           |        |
        | testB| testB  | conn_1 | True     | drop table if exists mytestB.test1    | success           |        |
        | testC| testC  | conn_1 | False    | show databases                        | has{('mytestC',)},hasnot{('mytestD',)}  |        |
        | testC| testC  | conn_1 | False    | use mytestD                           | Access denied for user |   |
        | testC| testC  | conn_1 | False    | drop table if exists mytestC.sbtestC1 | success           |        |
        | testC| testC  | conn_1 | False    | create table mytestC.sbtestC1(id int) | success           |        |
        | testC| testC  | conn_1 | True     | drop table if exists mytestC.sbtestC1 | success           |        |

    #clean multi-tenancy config
    Given delete the following xml segment
      |file        | parent                 | child                                  |
      |rule.xml    | {'tag':'root'}         | {'tag':'tableRule','kv_map':{'name':'eight-long'}} |
      |rule.xml    | {'tag':'root'}         | {'tag':'function','kv_map':{'name':'eight'}}  |
      |schema.xml  | {'tag':'root'}         | {'tag':'dataNode','kv_map':{'name':'dn6'}}    |
      |schema.xml  | {'tag':'root'}         | {'tag':'dataNode','kv_map':{'name':'dn7'}}    |
      |schema.xml  | {'tag':'root'}         | {'tag':'dataNode','kv_map':{'name':'dn8'}}    |
      |schema.xml  | {'tag':'root'}         | {'tag':'schema','kv_map':{'name':'mytestA'}}  |
      |schema.xml  | {'tag':'root'}         | {'tag':'schema','kv_map':{'name':'mytestB'}}  |
      |schema.xml  | {'tag':'root'}         | {'tag':'schema','kv_map':{'name':'mytestC'}}  |
      |schema.xml  | {'tag':'root'}         | {'tag':'schema','kv_map':{'name':'mytestD'}}  |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testA'}}      |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testB'}}      |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testC'}}      |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testD'}}      |
    Then execute admin cmd "reload @@config_all"

  Scenario: #2 test user Permission
    #single control: only readonly
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table dataNode="dn1,dn2,dn3,dn4" name="readonly_table" rule="hash-four"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_readonly">
        <property name="password">test_readonly</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql                                   | expect            | db     |
        | test         | 111111        | conn_0 | False   | drop table if exists readonly_table   | success           | mytest |
        | test_readonly| test_readonly | conn_1 | False   | create table readonly_table(id int, data varchar(10))  | User READ ONLY |mytest |
        | test         | 111111        | conn_0 | False   | create table readonly_table(id int, data varchar(10))  | success        |mytest |
        | test_readonly| test_readonly | conn_1 | False   | drop table readonly_table             | User READ ONLY    | mytest |
        | test_readonly| test_readonly | conn_1 | False   | alter table readonly_table add column data1 varchar(10)| User READ ONLY | mytest |
        | test_readonly| test_readonly | conn_1 | False   | insert into readonly_table values (1, 'aaa')           | User READ ONLY | mytest |
        | test_readonly| test_readonly | conn_1 | False   | update readonly_table set data = 'bbb' where id = 1    | User READ ONLY | mytest |
        | test_readonly| test_readonly | conn_1 | False   | delete from readonly_table                             | User READ ONLY | mytest |
        | test_readonly| test_readonly | conn_1 | False   | select * from readonly_table                           | success        | mytest |
        | test         | 111111        | conn_0 | False   | drop table if exists readonly_table   | success           | mytest|
    Given delete the following xml segment
      |file        | parent                                      | child                                              |
      |server.xml  | {'tag':'root'}                              | {'tag':'user','kv_map':{'name':'test_readonly'}}   |
      |schema.xml  | {'tag':'schema','kv_map':{'name':'mytest'}} | {'tag':'table','kv_map':{'name':'readonly_table'}} |
    Then execute admin cmd "reload @@config_all"

  Scenario: #3 config user Permission
    #single control: only schema level permission
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table dataNode="dn1,dn2,dn3,dn4" name="schema_permission" rule="hash-four"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="testA">
        <property name="password">testA</property>
        <property name="schemas">mytest</property>
        <privileges check="true">
            <schema name="mytest" dml="0000" />
        </privileges>
    </user>
    <user name="testB">
        <property name="password">testB</property>
        <property name="schemas">mytest</property>
        <privileges check="true">
            <schema name="mytest" dml="1111" />
        </privileges>
    </user>
    <user name="testC">
        <property name="password">testC</property>
        <property name="schemas">mytest</property>
        <privileges check="true">
            <schema name="mytest" dml="0001" />
        </privileges>
    </user>
    <user name="testD">
        <property name="password">testD</property>
        <property name="schemas">mytest</property>
        <privileges check="true">
            <schema name="mytest" dml="0010" />
        </privileges>
    </user>
    <user name="testE">
        <property name="password">testE</property>
        <property name="schemas">mytest</property>
        <privileges check="true">
            <schema name="mytest" dml="0100" />
        </privileges>
    </user>
    <user name="testF">
        <property name="password">testF</property>
        <property name="schemas">mytest</property>
        <privileges check="true">
            <schema name="mytest" dml="1000" />
        </privileges>
    </user>
    """
    Then execute admin cmd "reload @@config_all"

    #single control: only schema level permission
    Then Test only schema level permission feature
      | user  | password | schema | dml   | table             |
      | testA | testA    | mytest | 0000  | schema_permission |
      | testB | testB    | mytest | 1111  | schema_permission |
      | testC | testC    | mytest | 0001  | schema_permission |
      | testD | testD    | mytest | 0010  | schema_permission |
      | testE | testE    | mytest | 0100  | schema_permission |
      | testF | testF    | mytest | 1000  | schema_permission |
    #clean multi-tenancy config
    Given delete the following xml segment
      |file        | parent                 | child                                         |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testA'}}      |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testB'}}      |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testC'}}      |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testD'}}      |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testE'}}      |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'testF'}}      |
    Then execute admin cmd "reload @@config_all"

  Scenario: #6 config user Permission
    #mixture control: readonly + schema
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="readonly_schema1">
        <property name="password">readonly_schema1</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
        <privileges check="true">
            <schema name="mytest" dml="1111" />
        </privileges>
    </user>
    <user name="readonly_schema2">
        <property name="password">readonly_schema2</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
        <privileges check="true">
            <schema name="mytest" dml="0000" />
        </privileges>
    </user>
    <user name="readonly_schema3">
        <property name="password">readonly_schema3</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
        <privileges check="true">
            <schema name="mytest" dml="1101" />
        </privileges>
    </user>
    """
    Then execute admin cmd "reload @@config_all"

    Then Test config readonly and schema permission feature
    """
    [{"user":"readonly_schema1","password":"readonly_schema1","schema":"mytest","dml":"1111","table":"schema_permission"},
    {"user":"readonly_schema2","password":"readonly_schema2","schema":"mytest","dml":"0000","table":"schema_permission"},
    {"user":"readonly_schema3","password":"readonly_schema3","schema":"mytest","dml":"1101","table":"schema_permission"}
    ]
    """
    Given delete the following xml segment
      |file        | parent                 | child                                               |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'readonly_schema1'}} |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'readonly_schema2'}} |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'readonly_schema3'}} |
    Then execute admin cmd "reload @@config_all"

  Scenario: #4 test user Permission
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="schema_table1">
        <property name="password">schema_table1</property>
        <property name="schemas">mytest</property>
        <privileges check="true">
            <schema name="mytest" dml="1111">
                <table name="table1" dml="1111"></table>
                <table name="table2" dml="0000"></table>
                <table name="table3" dml="0001"></table>
                <table name="table4" dml="0010"></table>
                <table name="table5" dml="0100"></table>
                <table name="table6" dml="1000"></table>
            </schema>
        </privileges>
    </user>
    <user name="schema_table2">
        <property name="password">schema_table2</property>
        <property name="schemas">mytest</property>
        <privileges check="true">
            <schema name="mytest" dml="0000">
                <table name="table1" dml="1111"></table>
                <table name="table2" dml="0000"></table>
                <table name="table3" dml="0001"></table>
                <table name="table4" dml="0010"></table>
                <table name="table5" dml="0100"></table>
                <table name="table6" dml="1000"></table>
            </schema>
        </privileges>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then Test config schema and table permission feature
    """
    [{"user":"schema_table1","password":"schema_table1","schema":"mytest","schema_dml":"1111","single_table":"schema_permission","tables_config":
        {"tables":[{"dml":"1111","table":"table1"},
                   {"dml":"0000","table":"table2"},
                   {"dml":"0001","table":"table3"},
                   {"dml":"0010","table":"table4"},
                   {"dml":"0100","table":"table5"},
                   {"dml":"1000","table":"table6"}]
        }
     },
     {"user":"schema_table2","password":"schema_table2","schema":"mytest","schema_dml":"0000","single_table":"schema_permission","tables_config":
        {"tables":[{"dml":"1111","table":"table1"},
                   {"dml":"0000","table":"table2"},
                   {"dml":"0001","table":"table3"},
                   {"dml":"0010","table":"table4"},
                   {"dml":"0100","table":"table5"},
                   {"dml":"1000","table":"table6"}]
        }
     }
    ]
    """
    Given delete the following xml segment
      |file        | parent                 | child                                            |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'schema_table1'}} |
      |server.xml  | {'tag':'root'}         | {'tag':'user','kv_map':{'name':'schema_table2'}} |
      |schema.xml  | {'tag':'schema','kv_map':{'name':'mytest'}} | {'tag':'table','kv_map':{'name':'schema_permission'}} |
    Then execute admin cmd "reload @@config_all"