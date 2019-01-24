Feature:Date sharding function
  @BLOCKER
  Scenario: Date sharding function #1
    #test: sBeginDate not configured
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <tableRule name="date_rule">
            <rule>
                <columns>id</columns>
                <algorithm>date_func</algorithm>
            </rule>
        </tableRule>
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sEndDate">2018-01-31</property>
            <property name="sPartionDay">10</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: java.lang.RuntimeException: sBeginDate can not be null
    """

    #test: sBegin < sEndDate-nodes*sPartition+1
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-01-01</property>
            <property name="sEndDate">2018-01-31</property>
            <property name="sPartionDay">10</property>
        </function>
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="date_table" dataNode="dn1,dn2,dn3,dn4" rule="date_rule" />
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    please make sure table datanode size = function partition size
    """

    #test: set sBeginDate and defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-12-01</property>
            <property name="sEndDate">2018-01-8</property>
            <property name="sPartionDay">10</property>
            <property name="defaultNode">3</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                                   | expect                                      | db     |
        | test | 111111 | conn_0 | False    | drop table if exists date_table                                   | success                                     | mytest |
        | test | 111111 | conn_0 | False    | create table date_table(id date)                                  | success   | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values(null)/*dest_node:dn4*/           | success   | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-11-11')/*dest_node:dn4*/  | success                                      | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-01')/*dest_node:dn1*/  | success                                      | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-11')/*dest_node:dn2*/  | success                                      | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-21')/*dest_node:dn3*/  | success                                      | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-31')/*dest_node:dn4*/  | success                                      | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2018-1-8')/*dest_node:dn4*/    | success                                      | mytest |
        | test | 111111 | conn_0 | True     | insert into date_table values('2018-01-9')/*dest_node:dn4*/   | success                                      | mytest |
        | test | 111111 | conn_0 | False    | drop table if exists date_table                                   | success                                     | mytest |
        | test | 111111 | conn_0 | False    | create table date_table(id timestamp, c timestamp)             | success   | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values (null,null)              | Sharding column can't be null when the table in MySQL column is not null   | mytest |



    #test: set sEndDate and no defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-12-01</property>
            <property name="sEndDate">2018-01-8</property>
            <property name="sPartionDay">10</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                           | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists date_table                               | success | mytest |
        | test | 111111 | conn_0 | False    | create table date_table(id date)                              | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values(null)                           | can't find any valid data node | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-01')/*dest_node:dn1*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-11')/*dest_node:dn2*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-21')/*dest_node:dn3*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-31')/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2018-01-8')/*dest_node:dn4*/    | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2018-01-9')/*dest_node:dn4*/    | success | mytest |
        | test | 111111 | conn_0 | True     | insert into date_table values('2017-11-11')                    | can't find any valid data node | mytest |

     #test: not sEndDate and set defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-12-01</property>
            <property name="sPartionDay">10</property>
            <property name="defaultNode">3</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                           | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists date_table                               | success | mytest |
        | test | 111111 | conn_0 | False    | create table date_table(id date)                              | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-11-11')/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-01')/*dest_node:dn1*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-11')/*dest_node:dn2*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-21')/*dest_node:dn3*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-31')/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2018-1-8')/*dest_node:dn4*/    | success | mytest |
        | test | 111111 | conn_0 | True     | insert into date_table values('2018-11-11')                   | can't find any valid data node | mytest |

    #test: set not sEndDate and not defaultNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sBeginDate">2017-12-01</property>
            <property name="sPartionDay">10</property>
        </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                           | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists date_table                               | success | mytest |
        | test | 111111 | conn_0 | False    | create table date_table(id date)                              | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-01')/*dest_node:dn1*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-11')/*dest_node:dn2*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-21')/*dest_node:dn3*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-12-31')/*dest_node:dn4*/  | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2018-1-8')/*dest_node:dn4*/    | success | mytest |
        | test | 111111 | conn_0 | False    | insert into date_table values('2017-11-11')                   | can't find any valid data node | mytest |
        | test | 111111 | conn_0 | True     | insert into date_table values('2018-11-11')                   | can't find any valid data node | mytest |

    #test: use of limit in sharding_key
    Then Test the use of limit by the sharding column
    """
    {"table":"date_table","key":"id"}
    """
     #test: data types in sharding_key
    Then Test the data types supported by the sharding column in "date.sql"

    #clearn all conf
    Given delete the following xml segment
      |file        | parent                                        | child                                  |
      |rule.xml    | {'tag':'root'}                                | {'tag':'tableRule','kv_map':{'name':'date_rule'}} |
      |rule.xml    | {'tag':'root'}                                | {'tag':'function','kv_map':{'name':'date_func'}}  |
      |schema.xml  | {'tag':'schema','kv_map':{'name':'mytest'}}   | {'tag':'table','kv_map':{'name':'date_table'}}    |
    Then execute admin cmd "reload @@config_all"
