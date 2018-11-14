# -*- coding=utf-8 -*-
Feature: basic sql translate/transmission correct, seperate read/write statements, read load balance

    Scenario: #test balance
      Given start mysql in host "mysql-master2"
#    Given delete the following xml segment
#      |file        | parent          | child               |
#      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
#      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
#      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
#    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
#    """
#	    <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
#		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
#	    </schema>
#	    <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
#	    <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
#	    <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
#	    <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
#	    <dataHost balance="0" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
#		    <heartbeat>select user()</heartbeat>
#		    <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
#              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
#		    </writeHost>
#	    </dataHost>
#    """
#    Then execute admin cmd "reload @@config_all"
#    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4'"
#    Then execute sql in "dble-1" in "user" mode
#    | user | passwd | conn   | toClose | sql                                              | expect   | db      |tb  |count|
#    | test | 111111 | conn_0 | True    | drop table if exists test                     | success  | mytest |test|     |
#    | test | 111111 | conn_0 | True    | create table test(id int,name varchar(20))  | success  | mytest |test|     |
#    Then connect "dble-1" to insert "1000" of data for "test"
#    Then execute sql in "mysql-master2"
#    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
#    | test  | 111111    | conn_0 | True    | set global general_log=on        | success | db1 |
#    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success | db1 |
#    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
#    Then execute sql in "mysql-slave1"
#    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
#    | test  | 111111    | conn_0 | True    | set global general_log=on        | success | db1 |
#    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success | db1 |
#    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
#    Then connect "dble-1" to execute "1000" of select for "test"
#    Then execute sql in "mysql-master2"
#    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
#    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(1000L,),} | db1 |
#    Then execute sql in "mysql-slave1"
#    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
#    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  has{(0L,),} | db1 |
#    Then execute sql in "mysql-master2"
#    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
#    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |
#    Then execute sql in "mysql-slave1"
#    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
#    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |
#    Then execute sql in "mysql-slave2"
#    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
#    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |