Feature:# multi-tenancy, user-Permission
  Scenario: #config multi-tenancy
    Given Delete the dataNode "dn6" in schema.xml
    Given Delete the dataNode "dn7" in schema.xml
    Given Delete the dataNode "dn8" in schema.xml
    Given Add the dataNode in schema.xml
    """
    {"name":"dn6","dataHost":"172.100.9.6","database":"db3"}
    """
    Given Add the dataNode in schema.xml
    """
    {"name":"dn7","dataHost":"172.100.9.5","database":"db4"}
    """
    Given Add the dataNode in schema.xml
    """
    {"name":"dn8","dataHost":"172.100.9.6","database":"db4"}
    """
    Then Delete the "mytestA" schema in schema.xml
    Given Add a "mytestA" schema in schema.xml
    Given Add a table consisting of "mytestA" in schema.xml
    """
    "name":"test1","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    Given Add a table consisting of "mytestA" in schema.xml
    """
    "name":"test2","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    Then Delete the "mytestB" schema in schema.xml
    Given Add a "mytestB" schema in schema.xml
    Given Add a table consisting of "mytestB" in schema.xml
    """
    "name":"test1","dataNode":"dn5,dn6,dn7,dn8","rule":"hash-four"
    """
    Given Drop a tableRule "eight-long" in rule.xml
    Given Drop a "eight" function in rule.xml
    Given Add a "eight" hash function in rule.xml
    """
    "partitionCount":"8","partitionLength":"1"
    """
    Given Add a tableRule consisting of "eight-long","id","eight" in rule.xml
    Then Delete the "mytestC" schema in schema.xml
    Given Add a "mytestC" schema in schema.xml
    Given Add a table consisting of "mytestC" in schema.xml
    """
    "name":"sbtestC1","dataNode":"dn1,dn2,dn3,dn4,dn5,dn6,dn7,dn8","rule":"eight-long"
    """
    Then Delete the "mytestD" schema in schema.xml
    Given Add a "mytestD" schema in schema.xml
    Given Add a table consisting of "mytestD" in schema.xml
    """
    "name":"sbtestD1","dataNode":"dn1,dn2,dn3,dn4,dn5,dn6,dn7,dn8","rule":"eight-long"
    """
    Then Delete the user "testA"
    Given Add a user consisting of "testA" in server.xml
    """
    "password":"testA","schemas":"mytestA"
    """
    Then Delete the user "testB"
    Given Add a user consisting of "testB" in server.xml
    """
    "password":"testB","schemas":"mytestB"
    """
    Then Delete the user "testC"
    Given Add a user consisting of "testC" in server.xml
    """
    "password":"testC","schemas":"mytestC"
    """
    Then Delete the user "testD"
    Given Add a user consisting of "testD" in server.xml
    """
    "password":"testD","schemas":"mytestD"
    """
    When Execute reload @@config_all

  Scenario: #test multi-tenancy
    #Standalone database: A tenant a database
    Then Test multi-tenancy features
    """
    [{"user":"testA","password":"testA","is_schema":"mytestA","not_schema":"mytestB","table":"test2"},
    {"user":"testB","password":"testB","is_schema":"mytestB","not_schema":"mytestA","table":"test1"}]
    """
    #shared database:
    Then Test multi-tenancy features
    """
    [{"user":"testC","password":"testC","is_schema":"mytestC","not_schema":"mytestD","table":"sbtestC1"},
    {"user":"testD","password":"testD","is_schema":"mytestD","not_schema":"mytestC","table":"sbtestD1"}
    ]
    """

  Scenario: #clean multi-tenancy config
    Then Delete the "mytestA" schema in schema.xml
    Then Delete the "mytestB" schema in schema.xml
    Then Delete the "mytestC" schema in schema.xml
    Then Delete the "mytestD" schema in schema.xml
    Given Delete the dataNode "dn6" in schema.xml
    Given Delete the dataNode "dn7" in schema.xml
    Given Delete the dataNode "dn8" in schema.xml
    Given Drop a tableRule "eight-long" in rule.xml
    Given Drop a "eight" function in rule.xml
    Then Delete the user "testA"
    Then Delete the user "testB"
    Then Delete the user "testC"
    Then Delete the user "testD"
    When Execute reload @@config_all

  Scenario: #1 test user Permission
    #single control: only readonly
    Then Delete the user "test_readonly"
    Given Add a table consisting of "mytest" in schema.xml
    """
    "name":"readonly_table","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    Given Add a user consisting of "test_readonly" in server.xml
    """
    "password":"test_readonly","schemas":"mytest","readOnly":"true"
    """
    When Execute reload @@config_all
    Then Test readonly user features
    """
    {"user":"test_readonly","password":"test_readonly","schema":"mytest","table":"readonly_table"}
    """
    Then Delete the user "test_readonly"
    Given Delete the "readonly_table" table in the "mytest" logical database in schema.xml
    When Execute reload @@config_all

  Scenario: #2 config user Permission
    #single control: only schema level permission
    Given Delete the "schema_permission" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
    """
    "name":"schema_permission","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    Then Delete the user "testA"
    Given Add a user consisting of "testA" in server.xml
    """
    "password":"testA","schemas":"mytest"
    """
    Given Add a privilege of "testA" user in server.xml
    """
    "privileges"="fathernode:testA,check:true"
    "schemas"="name:mytest,dml:0000"
    """
    Then Delete the user "testB"
    Given Add a user consisting of "testB" in server.xml
    """
    "password":"testB","schemas":"mytest"
    """
    Given Add a privilege of "testB" user in server.xml
    """
    "privileges"="fathernode:testB,check:true"
    "schemas"="name:mytest,dml:1111"
    """
    Then Delete the user "testC"
    Given Add a user consisting of "testC" in server.xml
    """
    "password":"testC","schemas":"mytest"
    """
    Given Add a privilege of "testC" user in server.xml
    """
    "privileges"="fathernode:testC,check:true"
    "schemas"="name:mytest,dml:0001"
    """
    Then Delete the user "testD"
    Given Add a user consisting of "testD" in server.xml
    """
    "password":"testD","schemas":"mytest"
    """
    Given Add a privilege of "testD" user in server.xml
    """
    "privileges"="fathernode:testD,check:true"
    "schemas"="name:mytest,dml:0010"
    """
    Then Delete the user "testE"
    Given Add a user consisting of "testE" in server.xml
    """
    "password":"testE","schemas":"mytest"
    """
    Given Add a privilege of "testE" user in server.xml
    """
    "privileges"="fathernode:testE,check:true"
    "schemas"="name:mytest,dml:0100"
    """
    Then Delete the user "testF"
    Given Add a user consisting of "testF" in server.xml
    """
    "password":"testF","schemas":"mytest"
    """
    Given Add a privilege of "testF" user in server.xml
    """
    "privileges"="fathernode:testF,check:true"
    "schemas"="name:mytest,dml:1000"
    """
    When Execute reload @@config_all

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
    When Execute reload @@config_all

  Scenario: #3 config user Permission
    Given Delete the "schema_permission" table in the "mytest" logical database in schema.xml
    Given Add a table consisting of "mytest" in schema.xml
    """
    "name":"schema_permission","dataNode":"dn1,dn2,dn3,dn4","rule":"hash-four"
    """
    When Execute reload @@config_all

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
    When Execute reload @@config_all
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
    When Execute reload @@config_all

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
    When Execute reload @@config_all
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
    When Execute reload @@config_all

  Scenario: #test front-end usingDecrypt
    Then Delete the user "test_user"
    Given Add a user consisting of "test_user" in server.xml
      """
      "password":"test_password","schemas":"mytest","usingDecrypt":"1"
      """
    When execute reload @@config_all
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
    When Execute reload @@config_all