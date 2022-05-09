# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/4/27

Feature: check user hint

  # DBLE0REQ-1484
  Scenario: check rwSplitUser hint when log level is info #1
#    Given reset replication and none system databases
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" />
        <dbInstance name="hostS3" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                         | expect         | db  |
      | split1 | 111111 | conn_1 | False   | drop table if exists test_table                             | success        | db1 |
      | split1 | 111111 | conn_1 | False   | create table test_table(id int, age int)                    | success        | db1 |
      | split1 | 111111 | conn_1 | False   | insert into test_table values(1,10),(2,20),(3,30),(4,40)    | success        | db1 |
      | split1 | 111111 | conn_1 | False   | /*!dble:db_type=master*/select * from test_table where id=1 | has{((1,10),)} | db1 |
      | split1 | 111111 | conn_1 | False   | /*!dble:db_type=slave*/select * from test_table where id=1  | has{((1,10),)} | db1 |
      | split1 | 111111 | conn_1 | False   | /*#dble:db_type=master*/select * from test_table where id=1 | has{((1,10),)} | db1 |
      | split1 | 111111 | conn_1 | True    | /*#dble:db_type=slave*/select * from test_table where id=1  | has{((1,10),)} | db1 |
    Given set log4j2 log level to "info" in "dble-1"
    Given sleep "35" seconds
    Given execute oscmd in "dble-1"
    """
    mysql -usplit1 -p111111 -P8066 -h172.100.9.1 -Ddb1 -c -e "/*#dble:db_type=master*/select * from test_table where id=1;/*#dble:db_type=slave*/select * from test_table where id=1;" && \
    mysql -usplit1 -p111111 -P8066 -h172.100.9.1 -Ddb1 -e "/*!dble:db_type=master*/select * from test_table where id=1;/*!dble:db_type=slave*/select * from test_table where id=1;"
    """
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                         | expect         | db  |
      | split1 | 111111 | conn_2 | False   | /*!dble:db_type=master*/select * from test_table where id=1 | has{((1,10),)} | db1 |
      | split1 | 111111 | conn_2 | False   | /*!dble:db_type=slave*/select * from test_table where id=1  | has{((1,10),)} | db1 |
      | split1 | 111111 | conn_2 | False   | /*#dble:db_type=master*/select * from test_table where id=1 | has{((1,10),)} | db1 |
      | split1 | 111111 | conn_2 | False   | /*#dble:db_type=slave*/select * from test_table where id=1  | has{((1,10),)} | db1 |
      | split1 | 111111 | conn_2 | True    | drop table if exists test_table                             | success        | db1 |

  Scenario: check shardingUser hint when log level is info #2
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect           | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                      | success          | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(10))                     | success          | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,'11'),(2,'22'),(3,'33'),(4,'44')     | success          | schema1 |
      | conn_1 | False   | /*!dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1        | length{(0)}      | schema1 |
      | conn_1 | False   | /*!dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1        | has{((1,'11'),)} | schema1 |
      | conn_1 | False   | /*#dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1        | length{(0)}      | schema1 |
      | conn_1 | True    | /*#dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1        | has{((1,'11'),)} | schema1 |
    Given set log4j2 log level to "info" in "dble-1"
    Given sleep "35" seconds
    Given execute oscmd in "dble-1"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -c -e "/*#dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1;/*#dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1;" && \
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "/*!dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1;/*!dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1;"
    """
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect           | db      |
      | conn_2 | False   | /*!dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1        | length{(0)}      | schema1 |
      | conn_2 | False   | /*!dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1        | has{((1,'11'),)} | schema1 |
      | conn_2 | False   | /*#dble:shardingnode=dn1*/select * from sharding_4_t1 where id=1        | length{(0)}      | schema1 |
      | conn_2 | False   | /*#dble:shardingnode=dn2*/select * from sharding_4_t1 where id=1        | has{((1,'11'),)} | schema1 |
      | conn_2 | True    | drop table if exists sharding_4_t1                                      | success          | schema1 |