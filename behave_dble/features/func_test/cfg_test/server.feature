Feature: test config in server.xml

  @TRIVIAL
  Scenario: add client user with illegal label, reload fail #1
     #1.1  client user with illegal label got error
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">schema1</property>
        <property name="test">0</property>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    """
    These properties of user[test_user]  are not recognized: test
    """

  @TRIVIAL
  Scenario: add client user with schema which does not exist, start dble fail #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <user name="test_user3">
        <property name="password">test_password</property>
        <property name="schemas">testdb</property>
     </user>
    """
    Then Restart dble in "dble-1" failed for
     """
     schema testdb referred by user test_user3 is not exist!
     """

  @BLOCKER
  Scenario: add client user with usingDecrypt=1, start/reload success, query success #3
    Given encrypt passwd and add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="schemas">schema1</property>
        <property name="usingDecrypt">1</property>
    </user>
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test_user    | test_password | conn_0 | True    | select 1 | success | schema1 |

  @TRIVIAL
  Scenario: config server.xml with only <user> node, start dble success #4
    Given delete the following xml segment
      |file        | parent           | child            |
      |server.xml  | {'tag':'root'}   | {'tag':'system'} |
    Given Restart dble in "dble-1" success

  @TRIVIAL
  Scenario: both single & multiple manager user reload and do management cmd success #5
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "show @@version" with user "root" passwd "111111"
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">test_password</property>
        <property name="manager">true</property>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "show @@version" with user "test_user" passwd "test_password"

  @CRITICAL
  Scenario:config ip whitehost to both management and client user, client user not in whitehost access denied #6
    Given add xml segment to node with attribute "{'tag':'root','prev':'system'}" in "server.xml"
    """
    <firewall>
        <whitehost>
            <host host="172.100.9.253" user="root,test"/>
        </whitehost>
    </firewall>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test_user">
        <property name="password">111111</property>
        <property name="schemas">schema1</property>
    </user>
    <user name="mng_user">
        <property name="password">111111</property>
        <property name="schemas">schema1</property>
    </user>
    """
    Given Restart dble in "dble-1" success
    Then execute admin cmd "show @@version" with user "root" passwd "111111"
    Then execute sql in "dble-1" in "admin" mode
        | user        | passwd | conn   | toClose | sql      | expect  | db     |
        | mng_user   | 111111 | conn_0 | True    | show @@version |Access denied for user 'mng_user' with host '172.100.9.253 |  |
    Then execute sql in "dble-1" in "user" mode
        | user        | passwd | conn   | toClose | sql      | expect  | db     |
        | test        | 111111 | conn_0 | True    | select 1 |success  | schema1 |
        | test_user   | 111111 | conn_0 | True    | select 1 |Access denied for user 'test_user' with host '172.100.9.253 | schema1 |

  @CRITICAL
  Scenario: config sql blacklist #7
    Given add xml segment to node with attribute "{'tag':'root','prev':'system'}" in "server.xml"
    """
    <firewall>
        <blacklist check="true">
                <property name="conditionDoubleConstAllow">false</property>
                <property name="conditionAndAlwayFalseAllow">false</property>
                 <property name="conditionAndAlwayTrueAllow">false</property>
                 <property name="constArithmeticAllow">false</property>
                 <property name="alterTableAllow">false</property>
                 <property name="commitAllow">false</property>
                 <property name="deleteAllow">false</property>
                 <property name="dropTableAllow">false</property>
                 <property name="insertAllow">false</property>
                 <property name="intersectAllow">false</property>
                 <property name="lockTableAllow">false</property>
                 <property name="minusAllow">false</property>
                 <property name="callAllow">false</property>
                 <property name="replaceAllow">false</property>
                 <property name="setAllow">false</property>
                 <property name="describeAllow">false</property>
                 <property name="limitZeroAllow">false</property>
                 <property name="conditionOpXorAllow">false</property>
                 <property name="conditionOpBitwseAllow">false</property>
                 <property name="startTransactionAllow">false</property>
                 <property name="truncateAllow">false</property>
                 <property name="updateAllow">false</property>
                 <property name="useAllow">false</property>
                 <property name="blockAllow">false</property>
                 <property name="deleteWhereNoneCheck">false</property>
                 <property name="updateWhereNoneCheck">false</property>
        </blacklist>
    </firewall>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test         | 111111 | conn_0 | False    | create table if not exists test_table_1(id int) |success | schema1 |
        | test         | 111111 | conn_0 | False    | create table if not exists test_table_12(id int) |success | schema1 |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where 1 = 1 and 2 = 1; |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 567 and 1!= 1 |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 567 and 1 = 1 |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 2-1 |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | alter table test_table_1 add name varchar(20)   |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | commit   |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | delete from test_table_1 where id =1   |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | drop table test_table_1   |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | insert test_table_1 values(1)   |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | intersect    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | lock tables test_table_1 read  |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | minus    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | call test_table_1    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | replace into test_table_1(id)values (2)  |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | set xa =1    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | describe test_table_1    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 limit 0    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 1^1   |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where id = 1&1     |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | start transation    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | truncate table test_table_1    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | update test_table_1 set id =10 where id =1    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | use schema1    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | BEGIN select * from suntest;END;   |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | delete from test_table_1    |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | update test_table_1 set id =10   |error totally whack | schema1 |
    Given add xml segment to node with attribute "{'tag':'root','prev':'system'}" in "server.xml"
    """
    <firewall>
        <blacklist check="true">
                <property name="selelctAllow">false</property>
                <property name="createTableAllow">false</property>
                <property name="showAllow">false</property>
        </blacklist>
    </firewall>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd        | conn   | toClose | sql      | expect  | db     |
        | test         | 111111 | conn_0 | False    | create table if not exists test_table_1(id int) |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | select * from test_table_1 where 1 = 1 and 2 = 1; |error totally whack | schema1 |
        | test         | 111111 | conn_0 | False    | show tables |error totally whack | schema1 |

  @CRITICAL
  Scenario: config "user" attr "maxCon" (front-end maxCon) greater than 0 #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
      <user name="root">
        <property name="password">111111</property>
        <property name="manager">true</property>
        <property name="maxCon">2</property>
      </user>
      <user name="test">
        <property name="password">111111</property>
        <property name="schemas">schema1</property>
         <property name="maxCon">1</property>
      </user>
      <user name="action">
        <property name="password">action</property>
        <property name="schemas">schema1</property>
        <property name="readOnly">true</property>
        <property name="maxCon">1</property>
      </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose  | sql      | expect  | db     |
        | test         | 111111       | conn_0 | False    | select 1 | success | schema1 |
        | test         | 111111       | new    | True     | select 1 | Access denied for user 'test',too many connections for this user | schema1 |
        | action       | action    | conn_1 | False    | select 1 | success | schema1 |
        | action       | action    | new    | True     | select 1 | Access denied for user 'action',too many connections for this user | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user         | passwd    | conn   | toClose | sql      | expect  | db     |
        | root         | 111111    | conn_2 | False   | show @@version | success | schema1 |
        | root         | 111111    | conn_3 |False    | show @@version | success | schema1 |
        | root         | 111111    | new    | False   | show @@version | Access denied for user 'root',too many connections for this user | schema1 |

  @NORMAL
  Scenario: config "user" attr "maxCon" (front-end maxCon) 0 means using no checking, without "system" property "maxCon" configed #9
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
      <user name="root">
        <property name="password">111111</property>
        <property name="manager">true</property>
      </user>
      <user name="test">
        <property name="password">111111</property>
        <property name="schemas">schema1</property>
         <property name="maxCon">0</property>
      </user>
      <user name="action">
        <property name="password">action</property>
        <property name="schemas">schema1</property>
        <property name="readOnly">true</property>
        <property name="maxCon">0</property>
      </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose | sql      | expect  | db     |
        | test         | 111111       | conn_4 | False   | select 1 | success | schema1 |
        | test         | 111111       | conn_5 | False   | select 1 | success | schema1 |
        | action       | action    | conn_6 | False   | select 1 | success | schema1 |
        | action       | action    | conn_7 | False   | select 1 | success | schema1 |

  @CRITICAL
  Scenario: config sum(all "user" attr "maxCon") > "system" property "maxCon", exceeding connection will fail #10
    Given delete the following xml segment
      |file        | parent           | child          |
      |server.xml  | {'tag':'root'}   | {'tag':'root'} |

    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <system>
           <property name="useGlobleTableCheck">1</property>
           <property name="processors">1</property>
          <property name="processorExecutor">1</property>
          <property name="maxCon">1</property>
     </system>

     <user name="root">
          <property name="password">111111</property>
          <property name="manager">true</property>
     </user>
     <user name="test">
          <property name="password">111111</property>
          <property name="schemas">schema1</property>
          <property name="maxCon">1</property>
     </user>
     <user name="action">
          <property name="password">action</property>
          <property name="schemas">schema1</property>
          <property name="readOnly">true</property>
          <property name="maxCon">1</property>
     </user>

    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose | sql      | expect  | db     |
        | test         | 111111       | conn_0 | False   | select 1 | success | schema1 |
        | test         | 111111       | new    | False   | select 1 | too many connections for this user | schema1 |
        | action       | action    | conn_1 | False   | select 1 | too many connections for dble server | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user     | passwd    | conn   | toClose | sql            | expect  | db     |
        | root     | 111111    | conn_2 | False   | show @@version | success | schema1 |

  Scenario: test tableStructureCheckTask from issue:1098 #11

    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
       <property name="checkTableConsistency">1</property>
	    <property name="checkTableConsistencyPeriod">1000</property>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                     | expect          |db       |
      | test  | 111111 | conn_0  | True    | create table test_table(id int,name char(20))           | success         | schema1 |
    Then execute sql in "mysql-master1"
      | user  | passwd | conn    | toClose | sql                                            | expect          |db       |
      | test  | 111111 | conn_0  | True    | alter table test_table drop name           | success         | db1 |
    Given sleep "2" seconds
    Then check following " " exist in file "/opt/dble/logs/dble.log" in "dble-1"
    """
    structure are not consistent in different data node
    are modified by other,Please Check IT
    """
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                           | expect          |db       |
      | test  | 111111 | conn_0  | True    | drop table if exists test_table           | success         | schema1 |


