# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2020/9/10
Feature:#test fresh backend connection pool

  Scenario: #Use check session transaction ISOLATION level for any changes to confirm whether the connection pool has been refreshed
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-slave1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given execute sql in "mysql-slave2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level REPEATABLE READ             | success    | db1 |
    Given Restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="150" minCon="10" readWeight="1" primary="true"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="150" minCon="10" readWeight="1"/>
          <dbInstance name="hostM3" password="111111" url="172.100.9.3:3306" user="test" maxCon="150" minCon="10" readWeight="2"/>
      </dbGroup>
    """
    Given execute admin cmd "reload @@config_all" success
    Given execute sql in "mysql-master1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-master2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-slave1"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "mysql-slave2"
      | conn   | toClose | sql                      | expect                  | db  |
      | conn_0 | True   | set global transaction ISOLATION level READ UNCOMMITTED             | success    | db1 |
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql      | expect            | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1   | success          | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int)   | success          | schema1 |
      | conn_0 | False    | begin   | success          | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2),(3),(4)    | success          | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM2' | success |
    # ha_group2 master not fresh session.tx_isolation is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  hasStr{REPEATABLE-READ}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM1,hostM3' | success |
    #ha_group2 master fresh session.tx_isolation is new
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}         | schema1 |
    # ha_group1 not fresh session.tx_isolation is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    #connection in Transaction is old
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect                  | db      |
      | conn_0 | False   | SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                        | expect  |
      | fresh conn where dbGroup ='ha_group1' | success |
    # ha_group1 fresh session.tx_isolation is new
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect                                 | db      |
      | conn_1 | True    | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('READ-UNCOMMITTED',),}         | schema1 |
    #connection in Transaction is old
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                              | expect                         | db      |
      | conn_0 | False   | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |
      | conn_0 | True    | commit                           | success                       | schema1 |
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                               | expect                       | db      |
      | conn_0 | True    | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |
    Given execute sql in "dble-1" in "user" mode                              
      | conn   | toClose | sql                                                   | expect  | db      |
      | conn_0 | False   | begin                                                 | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    Given execute sql in "mysql-master1"                                      
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-master2"                                      
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-slave1"                                       
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    Given execute sql in "mysql-slave2"                                       
      | conn   | toClose | sql                                                           | expect  | db  |
      | conn_1 | True    | set global transaction ISOLATION level REPEATABLE READ | success | db1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group1' and dbInstance='hostM1,hostM1' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn1*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode
      | sql                                                            | expect                               |
      | fresh conn where dbGroup ='ha_group2' and dbInstance='hostM1,hostM1,hostM2' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect                  | db      |
      | conn_1 | True   | /*!dble:shardingNode=dn2*/SELECT @@session.tx_isolation   |  has{('REPEATABLE-READ',),}         | schema1 |
    When execute sql in "dble-1" in "admin" mode                              
      | sql                                                | expect  |
      | fresh conn forced where dbGroup ='ha_group1' | success |
    When execute sql in "dble-1" in "admin" mode                              
      | sql                                                | expect  |
      | fresh conn forced where dbGroup ='ha_group2' | success |
    Then execute sql in "dble-1" in "user" mode                               
      | conn   | toClose | sql                              | expect                        | db      |
      | conn_1 | True    | SELECT @@session.tx_isolation | has{('REPEATABLE-READ',),} | schema1 |








