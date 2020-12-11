# Created by admin at 2020/12/7
Feature: test kill query connection

# for DBLE0REQ-12
@btrace
Scenario: check kill query connection front id #1
# case 1: kill current connection
# case 1.1: kill current connection
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | success | schema1 |
    Given prepare a thread execute sql "create table sharding_4_t1(id int)" with "conn_0"
    Then get index:"0" column value of "show @@session" named as "front_id_1"
    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect                 |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
    Given destroy sql threads list

# case 1.2: kill xa connection, xa commit success
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect  | db      |
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
      | conn   | toClose | sql                         | db      |
      | conn_0 | False   | select * from sharding_4_t1 | schema1 |

    Then check resultset "connection_1" has lines with following column values
      | id-0 |
      | 1    |
      | 2    |
      | 3    |
      | 4    |

# case 1.3: kill connection multiple times
    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect                 |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
      | conn_0 | False   | kill query {0} | Query was interrupted. |
      | conn_0 | False   | kill query {0} | Query was interrupted. |

# case 2: kill nonexistent connection
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql             | expect                     |
      | conn_0 | False   | kill query -1   | Unknown connection id:-1   |
      | conn_0 | False   | kill query 8888 | Unknown connection id:8888 |
      | conn_0 | False   | kill query abc  | Invalid connection id:abc  |

# case 3: kill other user's connection
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    	<shardingUser name="test01" password="111111" schemas="schema1"/>
    """
    Then execute admin cmd "reload @@config"

    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql         | expect  |
      | conn_0 | False   | use schema1 | success |

    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | user   | passwd | conn   | toClose | sql            | expect                                | db      |
      | test01 | 111111 | conn_1 | True    | kill query {0} | can't kill other user's connection{0} | schema1 |

    Given delete the following xml segment
      |file        | parent                 | child                                            |
      |user.xml    | {'tag':'root'}         | {'tag':'shardingUser','kv_map':{'name':'test01'}} |
    Then execute admin cmd "reload @@config"

# case 4: kill other connection for the same user
# case 4.1: the connection does not have an executing sql
    Given execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect  |
      | conn_2 | False   | kill query {0} | success |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db      |
      | conn_0 | False   | select * from sharding_4_t1 | success | schema1 |

# case 4.2: the connection has an executing sql
# case 4.2.1:
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql   | expect  | db      |
      | conn_0 | False   | begin | success | schema1 |
    Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /setBackendResponseTime/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "insert into sharding_4_t1(id) values(1),(2),(3),(4)" with "conn_0"
    Then check btrace "BtraceSessionStage.java" output in "dble-1" with "1" times
    """
    end get into setPreExecuteEnd
    """

    Given execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect  |
      | conn_2 | False   | kill query {0} | success |

    Then check sql thread output in "err"
    """
    Query was interrupted.
    """
    Given stop btrace script "BtraceSessionStage.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                                      | db      |
      | conn_0 | False   | select * from sharding_4_t1 | Transaction error, need to rollback.Reason: | schema1 |
      | conn_0 | False   | rollback                    | success                                     | schema1 |
      | conn_0 | False   | select * from sharding_4_t1 | success                                     | schema1 |

# case 4.2.2:
    Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /setBackendResponseTime/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "insert into sharding_4_t1(id) values(5),(6),(7),(8)" with "conn_0"
    Then check btrace "BtraceSessionStage.java" output in "dble-1" with "1" times
  """
    end get into setPreExecuteEnd
    """
    Given execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect  |
      | conn_2 | False   | kill query {0} | success |

    Then check sql thread output in "err"
    """
    was closed ,reason is [Query was interrupted.]
    """
    Given stop btrace script "BtraceSessionStage.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect  | db      |
      | conn_0 | False    | select * from sharding_4_t1 | success | schema1 |

# case 4.2.3:
    Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
    /endRoute/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(30000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
    Given sleep "5" seconds
    Given prepare a thread execute sql "select * from sharding_4_t1" with "conn_0"
    Then check btrace "BtraceSessionStage.java" output in "dble-1" with "1" times
    """
    end get into endParse
    """
    Given execute the sql in "dble-1" in "user" mode by parameter from resultset "front_id_1"
      | conn   | toClose | sql            | expect  |
      | conn_2 | True   | kill query {0} | success |

    Then check sql thread output in "err"
    """
    Query was interrupted.
    """
    Given stop btrace script "BtraceSessionStage.java" in "dble-1"
    Given destroy sql threads list
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceXaDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceXaDelay.java.log" on "dble-1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | select * from sharding_4_t1        | success | schema1 |
      | conn_0 | True    | drop table if exists sharding_4_t1 | success | schema1 |

# for DBLE0REQ-726
  Scenario: check kill front id from dble client #2
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                             | expect  | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1                              | success | schema1 |
      | conn_3 | False   | create table sharding_4_t1(id int,name varchar(20))             | success | schema1 |
      | conn_3 | False   | begin                                                           | success | schema1 |
      | conn_3 | False   | insert into sharding_4_t1 values(1,'1'),(2,'2'),(3,'3'),(4,'4') | success | schema1 |

    Given execute linux command in "dble-1" and save result in "client_front_id"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@processlist" | awk '{print $1, $4}' | grep test | awk 'NR==1 {print $1}'
    """
    Then execute the sql in "dble-1" in "user" mode by parameter from resultset "client_front_id"
      | conn   | toClose | sql      | expect  |
      | conn_4 | True    | kill {0} | success |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "connection_2"
      | conn   | toClose | sql                |
      | conn_5 | True    | show @@processlist |

    Then check resultset "connection_2" has not lines with following column values
      | shardingNode-1 | User-3 | db-5 |
      | dn1            | test   | db1  |
      | dn2            | test   | db1  |
      | dn3            | test   | db2  |
      | dn4            | test   | db2  |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       | expect                     | db      |
      | conn_3 | True    | delete from sharding_4_t1 | MySQL server has gone away | schema1 |
