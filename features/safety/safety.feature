Feature:# multi-tenancy, user-Permission
  Scenario: #multi-tenancy
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
    Then excute admin cmd "reload @@config_all"

    #Standalone database: A tenant a database
    Then execute sql
        | user | passwd | conn   | toClose  | sql                                   | expect            | db     |
        | testA| testA  | conn_0 | False    | show databases                        | has:{mytestA},hasnot:{mytestB}  |        |
        | testA| testA  | conn_0 | False    | use mytestB                           | Access denied for user |   |
        | testA| testA  | conn_0 | False    | drop table if exists mytestA.test2    | success           |        |
        | testA| testA  | conn_0 | False    | create table mytestA.test2(id int)    | success           |        |
        | testA| testA  | conn_0 | True     | drop table if exists mytestA.test2    | success           |        |
        | testB| testB  | conn_1 | False    | show databases                        | has:{mytestB},hasnot:{mytestA}  |        |
        | testB| testB  | conn_1 | False    | use mytestA                           | Access denied for user |   |
        | testB| testB  | conn_1 | False    | drop table if exists mytestB.test1    | success           |        |
        | testB| testB  | conn_1 | False    | create table mytestB.test1(id int)    | success           |        |
        | testB| testB  | conn_1 | True     | drop table if exists mytestB.test1    | success           |        |
        | testC| testC  | conn_1 | False    | show databases                        | has:{mytestC},hasnot:{mytestD}  |        |
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
    Then excute admin cmd "reload @@config_all"

  Scenario: #1 test user Permission
    #single control: only readonly
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest">
        <table dataNode="dn1,dn2,dn3,dn4" name="readonly_table" rule="hash-four"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_readonly">
        <property name="password">test_readonly</property>
        <property name="schemas">mytest</property>
        <property name="readOnly">true</property>
    </user>
    """
    Then excute admin cmd "reload @@config_all"
    Then Test readonly user features
    """
    {"user":"test_readonly","password":"test_readonly","schema":"mytest","table":"readonly_table"}
    """
    Given delete the following xml segment
      |file        | parent           | child                                            |
      |server.xml  | {'tag':'root'}   | {'tag':'user','kv_map':{'name':'test_readonly'}} |
      |schema.xml  | {'tag':'root'}   | {'tag':'schema','kv_map':{'name':'mytest'}}      |
    Then excute admin cmd "reload @@config_all"

  Scenario: #2 config user Permission
    #single control: only schema level permission
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="mytest">
        <table dataNode="dn1,dn2,dn3,dn4" name="schema_permission" rule="hash-four"/>
    </schema>
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
    Then excute admin cmd "reload @@config_all"

  Scenario: #2 test user Permission
    #single control: only schema level permission
    Then Test only schema level permission feature
    """
    [{"user":"testA","password":"testA","schema":"mytest","dml":"0000","table":"schema_permission"},
    {"user":"testB","password":"testB","schema":"mytest","dml":"1111","table":"schema_permission"},
    {"user":"testC","password":"testC","schema":"mytest","dml":"0001","table":"schema_permission"},
    {"user":"testD","password":"testD","schema":"mytest","dml":"0010","table":"schema_permission"},
    {"user":"testE","password":"testE","schema":"mytest","dml":"0100","table":"schema_permission"},
    {"user":"testF","password":"testF","schema":"mytest","dml":"1000","table":"schema_permission"}
    ]
    """
    Then Delete the user "testA"
    Then Delete the user "testB"
    Then Delete the user "testC"
    Then Delete the user "testD"
    Then Delete the user "testE"
    Then Delete the user "testF"
    Given Delete the "schema_permission" table in the "mytest" logical database in schema.xml
    Then excute admin cmd "reload @@config_all"

  Scenario: #3 config user Permission
    Given Delete the "schema_permission" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
    """
    "name":"schema_permission","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    Then excute admin cmd "reload @@config_all"

  Scenario: #3 config user Permission
    #mixture control: readonly + schema
    Then Delete the user "readonly_schema1"
    Given Add a user consisting of "readonly_schema1" in server.xml
    """
    "password":"readonly_schema1","schemas":"mytest","readOnly":"true"
    """
    Given Add a privilege of "readonly_schema1" user in server.xml
    """
    "privileges"="fathernode:readonly_schema1,check:true"
    "schemas"="name:mytest,dml:1111"
    """
    Then Delete the user "readonly_schema2"
    Given Add a user consisting of "readonly_schema2" in server.xml
    """
    "password":"readonly_schema2","schemas":"mytest","readOnly":"true"
    """
    Given Add a privilege of "readonly_schema2" user in server.xml
    """
    "privileges"="fathernode:readonly_schema2,check:true"
    "schemas"="name:mytest,dml:0000"
    """
    Then Delete the user "readonly_schema3"
    Given Add a user consisting of "readonly_schema3" in server.xml
    """
    "password":"readonly_schema3","schemas":"mytest","readOnly":"true"
    """
    Given Add a privilege of "readonly_schema3" user in server.xml
    """
    "privileges"="fathernode:readonly_schema3,check:true"
    "schemas"="name:mytest,dml:1101"
    """
    Then excute admin cmd "reload @@config_all"
    Then Test config readonly and schema permission feature
    """
    [{"user":"readonly_schema1","password":"readonly_schema1","schema":"mytest","dml":"1111","table":"schema_permission"},
    {"user":"readonly_schema2","password":"readonly_schema2","schema":"mytest","dml":"0000","table":"schema_permission"},
    {"user":"readonly_schema3","password":"readonly_schema3","schema":"mytest","dml":"1101","table":"schema_permission"}
    ]
    """
    Then Delete the user "readonly_schema1"
    Then Delete the user "readonly_schema2"
    Then Delete the user "readonly_schema3"
    Then excute admin cmd "reload @@config_all"

  Scenario: #4 test user Permission
    Then Delete the user "schema_table1"
    Given Add a user consisting of "schema_table1" in server.xml
    """
    "password":"schema_table1","schemas":"mytest"
    """
    Given Add a privilege of "schema_table1" user in server.xml
    """
    "privileges"="fathernode:schema_table1,check:true"
    "schemas"="name:mytest,dml:1111"
    "tables"="fathernode:mytest,name:table1,dml:1111&fathernode:mytest,name:table2,dml:0000&fathernode:mytest,name:table3,dml:0001&fathernode:mytest,name:table4,dml:0010&fathernode:mytest,name:table5,dml:0100&fathernode:mytest,name:table6,dml:1000"
    """
    Then Delete the user "schema_table2"
    Given Add a user consisting of "schema_table2" in server.xml
    """
    "password":"schema_table2","schemas":"mytest"
    """
    Given Add a privilege of "schema_table2" user in server.xml
    """
    "privileges"="fathernode:schema_table2,check:true"
    "schemas"="name:mytest,dml:0000"
    "tables"="fathernode:mytest,name:table1,dml:1111&fathernode:mytest,name:table2,dml:0000&fathernode:mytest,name:table3,dml:0001&fathernode:mytest,name:table4,dml:0010&fathernode:mytest,name:table5,dml:0100&fathernode:mytest,name:table6,dml:1000"
    """
    Then excute admin cmd "reload @@config_all"
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
    Then Delete the user "schema_table1"
    Then Delete the user "schema_table2"
    Given Delete the "schema_permission" table in the "mytest" logical database in schema.xml
    Then excute admin cmd "reload @@config_all"

  Scenario: #test front-end usingDecrypt
    Then Delete the user "test_user"
    Given Add a user consisting of "test_user" in server.xml
      """
      "password":"test_password","schemas":"mytest","usingDecrypt":"1"
      """
    Then excute admin cmd "reload @@config_all"
    Then Check add "client" user success
      """
      {"user":"test_user","password":"test_password","schemas":"mytest"}
      """
    Then Delete the user "test_user"

  Scenario: #test blacklist control
    Then Delete the Firewall in schema.xml
    Given Add a Firewall in schema.xml
    """
    "blacklist"="check:true"
    "propertys"="name:selelctAllow"
    "values"="fatherNode:selelctAllow,value:false"
    """
    Then excute admin cmd "reload @@config_all"