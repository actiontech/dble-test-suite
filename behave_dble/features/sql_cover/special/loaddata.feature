# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by Rita at 2019/3/20
# Modified by wujinling at 2019/8/29
Feature: to verify issue https://github.com/actiontech/dble/issues/1000

  @skip
  Scenario: config parameter "maxCharsPerColumn " in server.xml to limit characters per column #1
    #create file with 68888 characters for one column
     Given create local and server file "test68888.txt" and fill with text
     """
      68888 chars
     """
    # load data in maxCharsPerColumn default value
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose | sql                                                                                                                          | expect  | db     |
        | test         | 111111    | conn_0 | False   | drop table if exists sharding_4_t3                                                                                       | success | schema2 |
        | test         | 111111    | conn_0 | False   | drop table if exists global_4_t1                                                                                         | success | schema2 |
        | test         | 111111    | conn_0 | False   | create table sharding_4_t3(id char(20),aa mediumtext)                                                                 | success | schema2 |
        | test         | 111111    | conn_0 | False   | create table global_4_t1(id char(20),aa mediumtext)                                                                   | success | schema2 |
        | test         | 111111    | conn_0 | False   | load data infile "./test68888.txt" into table sharding_4_t3 fields terminated by ',' lines terminated by '\n';|error totally whack  | schema2 |
        | test         | 111111    | conn_0 | True    | load data infile "./test68888.txt" into table global_4_t1 fields terminated by ',' lines terminated by '\n';  | error totally whack | schema2 |

     #load data with setting maxCharsPerColumn < max column length in test68888.ext
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <system>
          <property name="processors">1</property>
          <property name="processorExecutor">1</property>
          <property name="maxCharsPerColumn">68887</property>
     </system>
    """
    Given Restart dble in "dble-1" success
     Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose | sql                                    | expect  | db     |
        | test         | 111111    | conn_0 | False   | load data infile "./test68888.txt" into table sharding_4_t3 fields terminated by ',' lines terminated by '\n'; |error totally whack  | schema2 |
        | test         | 111111    | conn_0 | True    | load data infile "./test68888.txt" into table global_4_t1 fields terminated by ',' lines terminated by '\n';   | error totally whack | schema2 |

    #load data with setting maxCharsPerColumn >= max column length in test68888.ext
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
     <system>
          <property name="processors">1</property>
          <property name="processorExecutor">1</property>
          <property name="maxCharsPerColumn">68888</property>
     </system>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose | sql                                    | expect  | db     |
        | test         | 111111    | conn_0 | False   | load data infile "./test68888.txt" into table sharding_4_t3 fields terminated by ',' lines terminated by '\n'; |success  | schema2 |
        | test         | 111111    | conn_0 | True    | load data infile "./test68888.txt" into table global_4_t1 fields terminated by ',' lines terminated by '\n';   | success | schema2 |

    Given remove local and server file "test68888.txt"

  Scenario: Load data lines which start with ‘#’ from issue:1101    #2
     Given create local and server file "data.txt" and fill with text
     """
      #1,1
      2,2
     """
    Given create local and server file "data2.txt" and fill with text
     """
      #3,3
      #4,4
     """
    Then execute sql in "dble-1" in "user" mode
        | user   | passwd    | conn   | toClose | sql                                                                                                                                               | expect       | db     |
        | test   | 111111    | conn_0 | True    | drop table if exists sharding_4_t1                                                                                                           | success      | schema1 |
        | test   | 111111    | conn_0 | True    | CREATE TABLE sharding_4_t1 (name varchar(15) DEFAULT NULL,id int(11) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1          | success      | schema1 |
        | test   | 111111    | conn_0 | True    | load data infile './data.txt' into table sharding_4_t1 fields terminated by ',';                                                       |success       | schema1 |
        | test   | 111111    | conn_0 | True    | load data infile './data2.txt' into table sharding_4_t1 fields terminated by ',';                                                      | success      | schema1 |
        | test   | 111111    | conn_0 | True    | select * from sharding_4_t1                                                                                                                    | length{(4)} | schema1 |
        | test   | 111111    | conn_0 | True    | select name from sharding_4_t1 where id=1                                                                                                    | has{('#1')} | schema1 |
        | test   | 111111    | conn_0 | True    | select name from sharding_4_t1 where id=3                                                                                                    | has{('#3')} | schema1 |
        | test   | 111111    | conn_0 | True    | select name from sharding_4_t1 where id=4                                                                                                    | has{('#4')} | schema1 |

  Scenario: load data for table using global sequence from issue:1048    #3
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" incrementColumn="id" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">2</property>
    """
    Given Restart dble in "dble-1" success
    Given create local and server file "ld.txt" and fill with text
     """
      dble
     """
    Then execute sql in "dble-1" in "user" mode
        | user   | passwd    | conn   | toClose | sql                                                                                                                                                                                                                           | expect       | db     |
        | test   | 111111    | conn_0 | False   | drop table if exists test_auto                                                                                                                                                                                            | success      | schema1 |
        | test   | 111111    | conn_0 | False   | create table test_auto(`id` bigint(20) NOT NULL AUTO_INCREMENT, `name` varchar(20) DEFAULT NULL,PRIMARY KEY (`id`))ENGINE=InnoDB AUTO_INCREMENT=1103846109324774874 DEFAULT CHARSET=latin1          | success      | schema1 |
        | test   | 111111    | conn_0 | False   | load data local infile './ld.txt' into table test_auto fields terminated by ',' lines terminated by '\n' (name);                                                                                               |success       | schema1 |
        | test   | 111111    | conn_0 | False   | select * from test_auto                                                                                                                                                                                                     |length{(1)}  | schema1 |
    Given remove local and server file "ld.txt"


  Scenario: : Load data when the column content only has one '"' at the begining - issue:1182   #4
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_shard" dataNode="dn1"/>
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="maxCharsPerColumn">10</property>
    """
    Given Restart dble in "dble-1" success
    Given create local and server file "aa.txt" and fill with text
     """
      1,"ab
      2,cde
      3,fgh
     """
    Given create local and server file "bb.txt" and fill with text
     """
      1,"ab
      2,"cde
      3,fgh"
     """
    Then execute sql in "dble-1" in "user" mode
        | user   | passwd    | conn   | toClose | sql                                                                                                                                                         | expect       | db     |
        | test   | 111111    | conn_0 | False   | drop table if exists test_shard                                                                                                                         | success      | schema1 |
        | test   | 111111    | conn_0 | False   | create table test_shard(id int,name char(20))                                                                                                         | success      | schema1 |
        | test   | 111111    | conn_0 | False   | load data local infile './aa.txt' into table test_shard character SET 'utf8' fields terminated by ',' lines terminated by '\n';           |success       | schema1 |
        | test   | 111111    | conn_0 | False   | load data local infile './bb.txt' into table test_shard character SET 'utf8' fields terminated by ',' lines terminated by '\n';           |success       | schema1 |
        | test   | 111111    | conn_0 | False   | select * from test_shard                                                                                                                                  |length{(6)}  | schema1 |
        | test   | 111111    | conn_0 | False   | drop table if exists test_shard                                                                                                                         |success       | schema1 |
    Given remove local and server file "aa.txt"
    Given remove local and server file "bb.txt"


  Scenario: Load data when the column content contains Tab, from issue:1250 #5
    Given create local and server file "tab.txt" and fill with text
     """
      201	"Mazojys	ddd	ggg"	"Fxoj"	"Finance"	7800
     """
    Then execute sql in "dble-1" in "user" mode
        | user   | passwd    | conn   | toClose | sql                                                                                                                                                         | expect       | db     |
        | test   | 111111    | conn_0 | False   | drop table if exists sharding_4_t1                                                                                                                         | success      | schema1 |
        | test   | 111111    | conn_0 | False   | CREATE TABLE sharding_4_t1(ID INT NOT NULL,FirstName VARCHAR(20),LastName VARCHAR(20),Department VARCHAR(20),Salary INT)                                                                                                        | success      | schema1 |
        | test   | 111111    | conn_0 | False   | load data infile "./tab.txt" into table sharding_4_t1  FIELDS   OPTIONALLY ENCLOSED BY '"'   LINES TERMINATED BY '\n';           |success       | schema1 |
        | test   | 111111    | conn_0 | False   | select * from sharding_4_t1                                                                                                                                  |has{('Mazojys	ddd	ggg')}  | schema1 |
        | test   | 111111    | conn_0 | True   | drop table if exists sharding_4_t1                                                                                                                         |success       | schema1 |
    Given remove local and server file "tab.txt"