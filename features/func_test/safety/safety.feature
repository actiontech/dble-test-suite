Feature: multi-tenancy, user-Permission

  @regression
  Scenario: multi-tenancy, authority for certain tenant is right #1
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
        | testB| testB  | conn_1 | False    | drop table if exists mytestA.test2    | Access denied for user |   |
        | testB| testB  | conn_1 | False    | drop table if exists mytestB.test1    | success           |        |
        | testB| testB  | conn_1 | False    | create table mytestB.test1(id int)    | success           |        |
        | testB| testB  | conn_1 | True     | drop table if exists mytestB.test1    | success           |        |
        | testC| testC  | conn_2 | False    | show databases                        | has{('mytestC',)},hasnot{('mytestD',)}  |        |
        | testC| testC  | conn_2 | False    | use mytestD                           | Access denied for user |   |
        | testC| testC  | conn_2 | False    | drop table if exists mytestC.sbtestC1 | success           |        |
        | testC| testC  | conn_2 | False    | create table mytestC.sbtestC1(id int) | success           |        |
        | testC| testC  | conn_2 | True     | drop table if exists mytestC.sbtestC1 | success           |        |