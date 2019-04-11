# Created by Rita at 2019/3/20
Feature: to verify issue https://github.com/actiontech/dble/issues/1000

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
        | test   | 111111    | conn_0 | False   | drop table if exists sharding_4_t1                                                                                                           | success      | schema1 |
        | test   | 111111    | conn_0 | False   | CREATE TABLE sharding_4_t1 (name varchar(15) DEFAULT NULL,id int(11) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1          | success      | schema2 |
        | test   | 111111    | conn_0 | False   | load data infile './data.txt' into table sharding_4_t1 fields terminated by ',';                                                       |success       | schema1 |
        | test   | 111111    | conn_0 | True    | load data infile './data2.txt' into table sharding_4_t1 fields terminated by ',';                                                      | success      | schema1 |
        | test   | 111111    | conn_0 | True    | select * from sharding_4_t1                                                                                                                    | length{(4)} | schema1 |
        | test   | 111111    | conn_0 | True    | select name from sharding_4_t1 where id=1                                                                                                    | has{('#1')} | schema1 |
        | test   | 111111    | conn_0 | True    | select name from sharding_4_t1 where id=3                                                                                                    | has{('#3')} | schema1 |
        | test   | 111111    | conn_0 | True    | select name from sharding_4_t1 where id=4                                                                                                    | has{('#4')} | schema1 |
