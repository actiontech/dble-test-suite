# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/7
Feature: test KILL [CONNECTION | QUERY] processlist_id

# DBLE0REQ-12
  @btrace
  Scenario: check kill query processlist_id #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-Dprocessors=/d
      /-DprocessorExecutor=/d
      $a -Dprocessors=4
      $a -DprocessorExecutor=4
      """
    Then Restart dble in "dble-1" success
# case 1: kill query current processlist_id
# case 1.1: kill query processlist_id and does not have an executing sql
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | success | schema1 |
    Then get index:"0" column value of "select session_conn_id from dble_information.session_connections where sql_stage <> 'Manager connection' limit 1" named as "front_id_1"
    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect                 |
      | conn_0 | False   | kill query {0} | Query was interrupted. |

# case 1.2: kill query xa processlist_id, xa commit success
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
      | conn_0 | False   | create table sharding_4_t1(id int)                  | success | schema1 |
      | conn_0 | False   | select * from sharding_4_t1                         | success | schema1 |
      | conn_0 | False   | set autocommit=0                                    | success | schema1 |
      | conn_0 | False   | set xa=on                                           | success | schema1 |
      | conn_0 | False   | insert into sharding_4_t1(id) values(1),(2),(3),(4) | success | schema1 |
      | conn_0 | False   | select * from sharding_4_t1                         | success | schema1 |

    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect                 |
      | conn_0 | False   | kill query {0} | Query was interrupted. |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql              | expect  | db      |
      | conn_0 | False   | commit           | success | schema1 |
      | conn_0 | False   | set xa=off       | success | schema1 |
      | conn_0 | False   | set autocommit=1 | success | schema1 |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "connection_1"
      | conn   | toClose | sql                         | expect                        | db      |
      | conn_0 | False   | select * from sharding_4_t1 | has{((1,), (2,), (3,), (4,))} | schema1 |

# case 1.3: kill query processlist_id multiple times
    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect                 |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
      | conn_0 | False   | kill query {0} | Query was interrupted. |

# case 2: kill query nonexistent processlist_id
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql             | expect                      |
      | conn_0 | False   | kill query -1   | Unknown connection id: -1   |
      | conn_0 | False   | kill query 8888 | Unknown connection id: 8888 |
      | conn_0 | False   | kill query abc  | Invalid connection id:abc  |

# case 3: kill query other user's processlist_id
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test01" password="111111" schemas="schema1"/>
    """
    Then execute admin cmd "reload @@config"

    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql         | expect  |
      | conn_0 | False   | use schema1 | success |

    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | user   | passwd | conn   | toClose | sql            | expect                                  | db      |
      | test01 | 111111 | conn_1 | True    | kill query {0} | can't kill other user's connection: {0} | schema1 |

    Given delete the following xml segment
      |file        | parent                 | child                                            |
      |user.xml    | {'tag':'root'}         | {'tag':'shardingUser','kv_map':{'name':'test01'}} |
    Then execute admin cmd "reload @@config"

# case 4: kill query other processlist_id for the same user
# case 4.1: the processlist_id does not have an executing sql
    Given execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect  |
      | conn_2 | False   | kill query {0} | success |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db      |
      | conn_0 | False   | select * from sharding_4_t1 | success | schema1 |

# case 4.2: kill query the processlist_id has an executing sql
# case 4.2.1: at receive ok packet stage and in the transaction
    Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql   | expect  | db      |
      | conn_0 | False   | begin | success | schema1 |
    Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /ok/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
    Given prepare a thread execute sql "insert into sharding_4_t1(id) values(5),(6),(7),(8)" with "conn_0"
    Then check btrace "BtraceSessionStage.java" output in "dble-1" with ">0" times
    """
    get into ok
    """
    Given execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect  |
      | conn_2 | False   | kill query {0} | success |
    # Query was interrupted：还没有下发就被拦截了，其他2种是下发之后被拦截，一个是下发到后端，一个是下发到前端
    Then check sql thread output in "err" by retry "10" times
    """
    Query was interrupted.//stream closed by peer//[stream closed]
    """
    Given stop btrace script "BtraceSessionStage.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                                      | db      |
      | conn_0 | False   | select * from sharding_4_t1 | Transaction error, need to rollback.Reason: | schema1 |
      | conn_0 | False   | rollback                    | success                                     | schema1 |
      | conn_0 | False   | select * from sharding_4_t1 | has{((1,), (2,), (3,), (4,))}               | schema1 |

# case 4.2.2: at receive ok packet stage and not in the transaction
    Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /ok/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
    Given prepare a thread execute sql "insert into sharding_4_t1(id) values(9),(10),(11),(12)" with "conn_0"
    Then check btrace "BtraceSessionStage.java" output in "dble-1" with ">0" times
    """
    get into ok
    """
    Given execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect  |
      | conn_2 | False   | kill query {0} | success |
    Then check sql thread output in "err" by retry "10" times
    """
    Query was interrupted.//stream closed by peer//[stream closed]
    """
    Given stop btrace script "BtraceSessionStage.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                        | db      |
      | conn_0 | True    | select * from sharding_4_t1 | length{(4)}                   | schema1 |
      | conn_1 | False   | select * from sharding_4_t1 | has{((1,), (2,), (3,), (4,))} | schema1 |

# case 4.2.3: at endRoute stage
    Then get index:"0" column value of "select session_conn_id from dble_information.session_connections where sql_stage <> 'Manager connection' limit 1" named as "front_id_2"
    Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /endRoute/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
    Given prepare a thread execute sql "select * from sharding_4_t1" with "conn_1"
    Then check btrace "BtraceSessionStage.java" output in "dble-1" with ">0" times
    """
    get into endRoute
    """
    Given execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_2"
      | conn   | toClose | sql            | expect  |
      | conn_2 | True    | kill query {0} | success |
    Given sleep "5" seconds
    # Query was interrupted：还没有下发就被拦截了，其他2种是下发之后被拦截，一个是下发到后端，一个是下发到前端
    Then check sql thread output in "err" by retry "10" times
    """
    Query was interrupted.//stream closed by peer//[stream closed]
    """
    Given stop btrace script "BtraceSessionStage.java" in "dble-1"
    Given destroy sql threads list
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_1 | False   | select * from sharding_4_t1        | success | schema1 |
      | conn_1 | True    | drop table if exists sharding_4_t1 | success | schema1 |

  Scenario: check kill connection processlist_id for DBLE0REQ-726 #2
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                             | expect  | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1                              | success | schema1 |
      | conn_3 | False   | create table sharding_4_t1(id int,name varchar(20))             | success | schema1 |
      | conn_3 | False   | begin                                                           | success | schema1 |
      | conn_3 | False   | insert into sharding_4_t1 values(1,'1'),(2,'2'),(3,'3'),(4,'4') | success | schema1 |

    Then get index:"0" column value of "select front_id from dble_information.processlist where user='test'" named as "client_front_id"
    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "client_front_id"
      | conn   | toClose | sql      | expect  |
      | conn_4 | True    | kill {0} | success |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "connection_2"
      | conn   | toClose | sql                | expect | db |
      | conn_5 | True    | select db_instance, user, mysql_db from processlist | hasnot{(('hostM1', 'test', 'db1',),('hostM2', 'test', 'db1',),('hostM1', 'test', 'db2',),('hostM2', 'test', 'db2',),)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       | expect                                       | db      |
      | conn_3 | True    | delete from sharding_4_t1 | Lost connection to MySQL server during query | schema1 |
