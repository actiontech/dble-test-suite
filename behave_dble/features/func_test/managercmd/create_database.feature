# Created by zhaohongjie at 2018/12/7
Feature: test "create databsae @@datanode='dn1,dn2,...'"

  @NORMAL
  Scenario: "create database @@..." for all used datanode #1
     Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
     """
        <dataNode dataHost="172.100.9.5" database="da1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="da1" name="dn2" />
        <dataNode dataHost="172.100.9.5" database="da2" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="da2" name="dn4" />
        <dataNode dataHost="172.100.9.5" database="da3" name="dn5" />
    """
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                         | expect   | db     |
        | test | 111111 | conn_0 | True     | drop database if exists da1 | success  |        |
        | test | 111111 | conn_0 | True     | drop database if exists da2 | success  |        |
        | test | 111111 | conn_0 | True     | drop database if exists da3 | success  |        |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                         | expect   | db     |
        | test | 111111 | conn_0 | True     | drop database if exists da1 | success  |        |
        | test | 111111 | conn_0 | True     | drop database if exists da2 | success  |        |
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                       | expect          | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da1' | has{('da1',),}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da2' | has{('da2',),}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da3' | has{('da3',),}  |         |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                        | expect           | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da1'  |  has{('da1',),}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da2'  |  has{('da2',),}  |         |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                         | expect   | db     |
        | test | 111111 | conn_0 | True     | drop database if exists da1 | success  |        |
        | test | 111111 | conn_0 | True     | drop database if exists da2 | success  |        |
        | test | 111111 | conn_0 | True     | drop database if exists da3 | success  |        |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                         | expect   | db     |
        | test | 111111 | conn_0 | True     | drop database if exists da1 | success  |        |
        | test | 111111 | conn_0 | True     | drop database if exists da2 | success  |        |

  @NORMAL
  Scenario: "create database @@..." for part of used datanode #2
    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "schema.xml"
    """
         <dataNode dataHost="172.100.9.5" database="da11" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="da11" name="dn2" />
        <dataNode dataHost="172.100.9.5" database="da21" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="da21" name="dn4" />
        <dataNode dataHost="172.100.9.5" database="da31" name="dn5" />
    """
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                          | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da11 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da21 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da31 | success  |         |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                          | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da11 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da21 | success  |         |
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "create database @@dataNode ='dn1,dn2'"
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                        | expect          | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da11' | has{('da11',),} |        |
        | test | 111111 | conn_0 | True     | show databases like 'da21' | length{(0)}     |        |
        | test | 111111 | conn_0 | True     | show databases like 'da31' | length{(0)}     |        |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                         | expect           | db    |
        | test | 111111 | conn_0 | True     | show databases like 'da11'  |  has{('da11',),} |       |
        | test | 111111 | conn_0 | True     | show databases like 'da21'  |  length{(0)}     |       |
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                       | expect          | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da11' | has{('da11',),}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da21' | has{('da21',),}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da31' | has{('da31',),}  |         |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                        | expect           | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da11'  |  has{('da11',),}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da21'  |  has{('da21',),}  |         |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                          | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da11 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da21 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da31 | success  |         |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                          | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da11 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da21 | success  |         |

  @NORMAL
  Scenario: "create database @@..." for datanode of style 'dn$x-y' #3
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn10,dn11,dn20,dn21" name="test" rule="hash-four" />
        </schema>

         <dataNode dataHost="172.100.9.5" database="da0$0-1" name="dn1$0-1" />
        <dataNode dataHost="172.100.9.6" database="da0$0-1" name="dn2$0-1" />
        <dataNode dataHost="172.100.9.5" database="da31" name="dn5" />
     """
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                          | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da00 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da01 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da31 | success  |         |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                          | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da00 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da01 | success  |         |
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute admin cmd "create database @@dataNode ='dn10,dn11,dn20,dn21'"
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                        | expect          | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da00' | has{('da00',),} |        |
        | test | 111111 | conn_0 | True     | show databases like 'da01' | has{('da01',),} |         |
        | test | 111111 | conn_0 | True     | show databases like 'da31' | length{(0)}     |         |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                           | expect           | db    |
        | test | 111111 | conn_0 | True     | show databases like 'da00'    |  has{('da00',),} |       |
        | test | 111111 | conn_0 | True     | show databases like 'da01'    |  has{('da01',),} |       |
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose  | sql                          | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da00 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da01 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da31 | success  |         |
    Then execute sql in "mysql-master2"
        | user | passwd | conn   | toClose  | sql                          | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da00 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da01 | success  |         |
