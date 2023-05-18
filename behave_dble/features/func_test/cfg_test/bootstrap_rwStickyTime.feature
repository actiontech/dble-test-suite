# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2022/3/7


Feature: test rwStickyTime on rwSplit mode
  #about http://10.186.18.11/jira/browse/DBLE0REQ-1305


  Scenario: test rwStickyTime parameters  #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DrwStickyTime=99.99
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ rwStickyTime \] '99.99' data type should be long
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=99.99/-DrwStickyTime=-199/
      """
    Then restart dble in "dble-1" failed for
      """
      Property \[ rwStickyTime \] '-199' in bootstrap.cnf is illegal, you may need use the default value 1000 replaced
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=-199/-DrwStickyTime=abc/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ rwStickyTime \] 'abc' data type should be long
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=abc/-DrwStickyTime=null/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ rwStickyTime \] 'null' data type should be long
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=null/-DrwStickyTime=/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ rwStickyTime \] '' data type should be long
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=/-DrwStickyTime=@/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ rwStickyTime \] '@' data type should be long
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-DrwStickyTime/d
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                  | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}     | dble_information |


  @restore_global_setting
  Scenario: test rwStickyTime when db.xml rwSplitMode="0"  #1
    """
    {'restore_global_setting':{'mysql-master2':{'general_log':0},'mysql-slave1':{'general_log':0}}}
    """
    Given delete the following xml segment
      | file          | parent           | child                   |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                  | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}     | dble_information |

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | drop database if exists testdb            | success |   |
      | rwS1 | 111111  | conn_0 | true    | create database testdb                    | success |   |
      | rwS1 | 111111  | conn_0 | False   | use testdb                                | success |   |
      | rwS1 | 111111  | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | create table testtb(id int)               | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (1),(2),(3),(4) | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb where id=1          | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where id=2          | success | testdb |

    Then check general log in host "mysql-master2" has "select id from testtb where id=1"
    Then check general log in host "mysql-master2" has "select id from testtb where id=2"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=1"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=2"


    ### set rwStickyTime default data
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DrwStickyTime=1000
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}      | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (5)             | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb where id=3          | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where id=4          | success | testdb |

    Then check general log in host "mysql-master2" has "select id from testtb where id=3"
    Then check general log in host "mysql-master2" has "select id from testtb where id=4"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=3"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=4"

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=1000/-DrwStickyTime=5000/
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                  | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}     | dble_information |
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('5000ms',),)}      | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (6),(7)         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb where id=5          | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb where id=6          | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(5)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where id=7          | success | testdb |

    Then check general log in host "mysql-master2" has "select id from testtb where id=5"
    Then check general log in host "mysql-master2" has "select id from testtb where id=6"
    Then check general log in host "mysql-master2" has "select id from testtb where id=7"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=5"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=6"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=7"

##### hint sql
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                                   | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (66),(77)                   | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=master*/select * from testtb          | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | /*!dble:db_type=slave*/select * from testtb           | java.io.IOException: force slave,but the dbGroup[ha_group2] doesn't contain active slave dbInstance | testdb |


    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=5000/-DrwStickyTime=0/
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect              | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('0ms',),)}      | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (8),(9)         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb where id=8          | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where id=9          | success | testdb |

    Then check general log in host "mysql-master2" has "select id from testtb where id=8"
    Then check general log in host "mysql-master2" has "select id from testtb where id=9"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=8"
    Then check general log in host "mysql-slave1" has not "select id from testtb where id=9"

#### DBLE0REQ-1681
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
       """
       because in the sticky time range，so select write instance
       """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111 | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111 | conn_0 | true    | drop database if exists testdb            | success |        |


  @restore_global_setting
  Scenario: test rwStickyTime when db.xml rwSplitMode="1"  #2
    """
    {'restore_global_setting':{'mysql-master2':{'general_log':0},'mysql-slave1':{'general_log':0}}}
    """
    Given delete the following xml segment
      | file          | parent           | child                   |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}      | dble_information |

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given record current dble log line number in "log_num_1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | drop database if exists testdb            | success |   |
      | rwS1 | 111111  | conn_0 | true    | create database testdb                    | success |   |
      | rwS1 | 111111  | conn_0 | False   | use testdb                                | success |   |
      | rwS1 | 111111  | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | create table testtb(id int,age int)       | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (1,1),(2,2)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb                    | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where id=1          | success | testdb |

    Then check general log in host "mysql-master2" has "select age from testtb"
    Then check general log in host "mysql-master2" has not "select id from testtb where id=1"
    Then check general log in host "mysql-slave1" has "select id from testtb where id=1"
    Then check general log in host "mysql-slave1" has not "select age from testtb"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_1" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 2           |

    ### set rwStickyTime default data
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DrwStickyTime=1000
      """
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_2"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                  | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}     | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (3,3),(4,4)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=2         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=3         | success | testdb |

    Then check general log in host "mysql-master2" has "select age from testtb where id=2"
    Then check general log in host "mysql-master2" has not "select id from testtb where age=3"
    Then check general log in host "mysql-slave1" has "select id from testtb where age=3"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=2"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_2" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 2           |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=1000/-DrwStickyTime=6000/
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}      | dble_information |
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_3"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('6000ms',),)}      | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (5,5),(6,6)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=5         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=6         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(5)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=5         | success | testdb |

    Then check general log in host "mysql-master2" has "select age from testtb where id=5"
    Then check general log in host "mysql-master2" has "select age from testtb where id=6"
    Then check general log in host "mysql-master2" has not "select id from testtb where age=5"
    Then check general log in host "mysql-slave1" has "select id from testtb where age=5"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=5"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=6"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_3" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 4           |

#####  mulit sql
    Given record current dble log line number in "log_num_30"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | true    | insert into testtb values (1,1),(2,2);select 1;select sleep(6);select age from testtb where age = 123     | success | testdb |
    Then check general log in host "mysql-master2" has "select age from testtb where age = 123"
    Then check general log in host "mysql-slave1" has not "select age from testtb where age = 123"
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_30" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 0           |

#####  hint sql
    Given record current dble log line number in "log_num_31"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                                            | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (23,31),(16,61)                      | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=master*/select * from testtb where id = 33     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=slave*/select * from testtb where id = 43      | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(6)                                                | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=master*/select age from testtb where id = 23   | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | /*!dble:db_type=slave*/select id from testtb where id = 16     | success | testdb |

    Then check general log in host "mysql-master2" has "select \* from testtb where id = 33"
    Then check general log in host "mysql-master2" has "select age from testtb where id = 23"
    Then check general log in host "mysql-master2" has not "select \* from testtb where id = 43"
    Then check general log in host "mysql-master2" has not "select id from testtb where id = 16"
    Then check general log in host "mysql-slave1" has "select \* from testtb where id = 43"
    Then check general log in host "mysql-slave1" has "select id from testtb where id = 16"
    Then check general log in host "mysql-slave1" has not "select \* from testtb where id = 33"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id = 23"
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_31" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 1           |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=6000/-DrwStickyTime=0/
      """
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_4"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect             | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('0ms',),)}     | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (7,7),(8,8)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=7         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(5)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=8         | success | testdb |

    Then check general log in host "mysql-master2" has not "select age from testtb where id=7"
    Then check general log in host "mysql-master2" has not "select id from testtb where age=8"
    Then check general log in host "mysql-slave1" has "select id from testtb where age=8"
    Then check general log in host "mysql-slave1" has "select age from testtb where id=7"
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_4" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 0           |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111 | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111 | conn_0 | true    | drop database if exists testdb            | success |        |


  @restore_global_setting
  Scenario: test rwStickyTime when db.xml rwSplitMode="2" #3
    """
    {'restore_global_setting':{'mysql-master2':{'general_log':0},'mysql-slave1':{'general_log':0}}}
    """
    Given delete the following xml segment
      | file          | parent           | child                   |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}      | dble_information |

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given record current dble log line number in "log_num_1"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | drop database if exists testdb            | success |   |
      | rwS1 | 111111  | conn_0 | true    | create database testdb                    | success |   |
      | rwS1 | 111111  | conn_0 | False   | use testdb                                | success |   |
      | rwS1 | 111111  | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | create table testtb(id int,age int)       | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (1,1),(2,2)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb                     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(2)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select age from testtb                    | success | testdb |

    Then check general log in host "mysql-master2" has "select id from testtb"
    Then check general log in host "mysql-slave1" has not "select id from testtb"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_1" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 2           |

    ### set rwStickyTime default data
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DrwStickyTime=1000
      """
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_2"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                  | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}     | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (3,3),(4,4)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=2         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=3         | success | testdb |

    Then check general log in host "mysql-master2" has "select age from testtb where id=2"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=2"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_2" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 2           |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=1000/-DrwStickyTime=4000/
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}      | dble_information |
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_3"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('4000ms',),)}      | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (5,5),(6,6)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=5         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=6         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(4)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=5         | success | testdb |

    Then check general log in host "mysql-master2" has "select age from testtb where id=5"
    Then check general log in host "mysql-master2" has "select age from testtb where id=6"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=5"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=6"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_3" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 4           |

#####  mulit sql
    Given record current dble log line number in "log_num_30"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | true    | insert into testtb values (1,1),(2,2);select 1;select sleep(6);select age from testtb where age = 123     | success | testdb |
    Then check general log in host "mysql-master2" has "select age from testtb where age = 123"
    Then check general log in host "mysql-slave1" has not "select age from testtb where age = 123"
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_30" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 0           |
    
#####  hint sql
    Given record current dble log line number in "log_num_31"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                                            | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (23,31),(16,61)                      | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=master*/select * from testtb where id = 33     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=slave*/select * from testtb where id = 43      | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(6)                                                | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=master*/select age from testtb where id = 23   | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | /*!dble:db_type=slave*/select id from testtb where id = 16     | success | testdb |

    Then check general log in host "mysql-master2" has "select \* from testtb where id = 33"
    Then check general log in host "mysql-master2" has "select age from testtb where id = 23"
    Then check general log in host "mysql-master2" has not "select \* from testtb where id = 43"
    Then check general log in host "mysql-master2" has not "select id from testtb where id = 16"
    Then check general log in host "mysql-slave1" has "select \* from testtb where id = 43"
    Then check general log in host "mysql-slave1" has "select id from testtb where id = 16"
    Then check general log in host "mysql-slave1" has not "select \* from testtb where id = 33"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id = 23"
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_31" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 1           |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=4000/-DrwStickyTime=0/
      """
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_4"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect              | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('0ms',),)}      | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (7,7),(8,8)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=7         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(5)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=8         | success | testdb |

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_4" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 0           |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111 | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111 | conn_0 | true    | drop database if exists testdb            | success |        |


  @restore_global_setting
  Scenario: test rwStickyTime when db.xml rwSplitMode="3"  #4
    """
    {'restore_global_setting':{'mysql-master2':{'general_log':0},'mysql-slave1':{'general_log':0}}}
    """
    Given delete the following xml segment
      | file          | parent           | child                   |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}      | dble_information |

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given record current dble log line number in "log_num_1"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | drop database if exists testdb            | success |   |
      | rwS1 | 111111  | conn_0 | true    | create database testdb                    | success |   |
      | rwS1 | 111111  | conn_0 | False   | use testdb                                | success |   |
      | rwS1 | 111111  | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | create table testtb(id int,age int)       | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (1,1),(2,2)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb                     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(2)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select age from testtb                    | success | testdb |

    Then check general log in host "mysql-master2" has "select id from testtb"
    Then check general log in host "mysql-master2" has not "select age from testtb"
    Then check general log in host "mysql-slave1" has not "select id from testtb"
    Then check general log in host "mysql-slave1" has "select age from testtb"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_1" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 2           |

    ### set rwStickyTime default data
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DrwStickyTime=1000
      """
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_2"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}      | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (3,3),(4,4)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=2         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=3         | success | testdb |

    Then check general log in host "mysql-master2" has "select age from testtb where id=2"
    Then check general log in host "mysql-master2" has not "select id from testtb where age=3"
    Then check general log in host "mysql-slave1" has "select id from testtb where age=3"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=2"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_2" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 2           |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=1000/-DrwStickyTime=6000/
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('1000ms',),)}      | dble_information |
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_3"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect                  | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('6000ms',),)}     | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (5,5),(6,6)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=5         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(1)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=6         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(5)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=5         | success | testdb |

    Then check general log in host "mysql-master2" has "select age from testtb where id=5"
    Then check general log in host "mysql-master2" has "select age from testtb where id=6"
    Then check general log in host "mysql-master2" has not "select id from testtb where age=5"
    Then check general log in host "mysql-slave1" has "select id from testtb where age=5"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=5"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id=6"

    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_3" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 4           |

#####  mulit sql
    Given record current dble log line number in "log_num_30"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | true    | insert into testtb values (1,1),(2,2);select 1;select sleep(6);select age from testtb where age = 123     | success | testdb |
    Then check general log in host "mysql-master2" has "select age from testtb where age = 123"
    Then check general log in host "mysql-slave1" has not "select age from testtb where age = 123"
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_30" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 0           |
    
#####  hint sql
    Given record current dble log line number in "log_num_31"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                                            | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (23,31),(16,61)                      | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=master*/select * from testtb where id = 33     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=slave*/select * from testtb where id = 43      | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(6)                                                | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | /*!dble:db_type=master*/select age from testtb where id = 23   | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | /*!dble:db_type=slave*/select id from testtb where id = 16     | success | testdb |

    Then check general log in host "mysql-master2" has "select \* from testtb where id = 33"
    Then check general log in host "mysql-master2" has "select age from testtb where id = 23"
    Then check general log in host "mysql-master2" has not "select \* from testtb where id = 43"
    Then check general log in host "mysql-master2" has not "select id from testtb where id = 16"
    Then check general log in host "mysql-slave1" has "select \* from testtb where id = 43"
    Then check general log in host "mysql-slave1" has "select id from testtb where id = 16"
    Then check general log in host "mysql-slave1" has not "select \* from testtb where id = 33"
    Then check general log in host "mysql-slave1" has not "select age from testtb where id = 23"
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_31" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 1           |


    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DrwStickyTime=6000/-DrwStickyTime=0/
      """
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_num_4"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                       | expect              | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = 'rwStickyTime'            | has{(('0ms',),)}      | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (7,7),(8,8)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb where id=7         | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(5)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select id from testtb where age=8         | success | testdb |

    Then check general log in host "mysql-master2" has not "select age from testtb where id=7"
    Then check general log in host "mysql-master2" has not "select id from testtb where age=8"
    Then check general log in host "mysql-slave1" has "select id from testtb where age=8"
    Then check general log in host "mysql-slave1" has "select age from testtb where id=7"
    Then check the occur times of following key in file "/opt/dble/logs/dble.log" after line "log_num_4" in "dble-1"
      | key                                                   | occur_times |
      | because in the sticky time range                      | 0           |



  @restore_global_setting @restore_mysql_service
  Scenario: test rwStickyTime when db.xml rwSplitMode="1" and rwSplitMode="3" then slave mysql down #5
    """
    {'restore_global_setting':{'mysql-master2':{'general_log':0},'mysql-slave1':{'general_log':0}}}
    {'restore_mysql_service':{'mysql-slave1':{'start_mysql':1},'mysql-master2':{'start_mysql':1}}}
    """
    Given delete the following xml segment
      | file          | parent           | child                   |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" />
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DrwStickyTime=3000
      """
    Then restart dble in "dble-1" success

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | drop database if exists testdb            | success |   |
      | rwS1 | 111111  | conn_0 | true    | create database testdb                    | success |   |
      | rwS1 | 111111  | conn_0 | False   | use testdb                                | success |   |
      | rwS1 | 111111  | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | create table testtb(id int,age int)       | success | testdb |

    Given stop mysql in host "mysql-slave1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (1,1),(2,2)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb                     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select age from testtb                    | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(3)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select age from testtb                    | the dbGroup[ha_group2] doesn't contain active dbInstance. | testdb |

    Given start mysql in host "mysql-slave1"
    Given delete the following xml segment
      | file          | parent           | child                   |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given stop mysql in host "mysql-slave1"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd  | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111  | conn_0 | False   | insert into testtb values (3,3),(4,4)     | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select id from testtb where id = 1        | success | testdb |
      | rwS1 | 111111  | conn_0 | False   | select sleep(3)                           | success | testdb |
      | rwS1 | 111111  | conn_0 | true    | select age from testtb where age = 4      | success | testdb |

    Then check general log in host "mysql-master2" has "select age from testtb where age = 4"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111 | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111 | conn_0 | true    | drop database if exists testdb            | success |        |


  @restore_global_setting
  Scenario: test rwStickyTime and delete /update #6
    """
    {'restore_global_setting':{'mysql-master2':{'general_log':0},'mysql-slave1':{'general_log':0}}}
    """
    Given delete the following xml segment
      | file          | parent           | child                   |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
      | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
      | user.xml      | {'tag':'root'}   | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" />
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DrwStickyTime=6000
      """
    Then restart dble in "dble-1" success

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                           | expect  | db     |
      | rwS1 | 111111 | conn_0 | False   | drop database if exists testdb                                | success |        |
      | rwS1 | 111111 | conn_0 | true    | create database testdb                                        | success |        |
      | rwS1 | 111111 | conn_0 | False   | use testdb                                                    | success |        |
      | rwS1 | 111111 | conn_0 | False   | drop table if exists testtb                                   | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | create table testtb(id int,age int)                           | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | insert into testtb values (1,1),(2,2)                         | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | update testtb set id = 3 where age = 2                        | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select id from testtb where age = 18                          | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select sleep(6)                                               | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select id from testtb where age = 28                          | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | delete from testtb where age = 2                              | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select id from testtb where age between 1 and 5               | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select count(*) from testtb where 1=1                         | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | show tables                                                   | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select sleep(6)                                               | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select id from testtb where age = 38                          | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select SQL_SMALL_RESULT count(*),age from testtb group by age | success | testdb |
      | rwS1 | 111111 | conn_0 | true    | select id from testtb where age = 38                          | success | testdb |

    Then check following text exist "Y" in file "/root/sandboxes/sandbox/master/data/mysql-2.log" in host "mysql-master2"
       """
       drop database if exists testdb
       create database testdb
       use testdb
       drop table if exists testtb
       create table testtb\(id int,age int\)
       insert into testtb values \(1,1\),\(2,2\)
       update testtb set id = 3 where age = 2
       select id from testtb where age = 18
       select sleep\(6\)
       delete from testtb where age = 2
       select id from testtb where age between 1 and 5
       select count\(\*\) from testtb where 1=1
       show tables
       """
    Then check following text exist "N" in file "/root/sandboxes/sandbox/master/data/mysql-2.log" in host "mysql-master2"
       """
       select id from testtb where age = 28
       select id from testtb where age = 38
       select SQL_SMALL_RESULT count\(\*\),age from testtb group by age
       """
    Then check following text exist "Y" in file "/root/sandboxes/sandbox/node1/data/mysql-2.log" in host "mysql-slave1"
       """
       select id from testtb where age = 28
       select id from testtb where age = 38
       select SQL_SMALL_RESULT count\(\*\),age from testtb group by age
       """
    Then check following text exist "N" in file "/root/sandboxes/sandbox/node1/data/mysql-2.log" in host "mysql-slave1"
       """
       select id from testtb where age = 18
       show tables
       select sleep\(6\)
       select id from testtb where age between 1 and 5
       select count\(\*\) from testtb where 1=1
       """

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111 | conn_0 | False   | begin                                     | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | update testtb set id = 43 where age = 21  | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select sleep(6)                           | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select id,age from testtb order by null   | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | commit                                    | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select id from testtb order by id limit 3 | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select last_insert_id()                   | success | testdb |
      | rwS1 | 111111 | conn_0 | False   | select sleep(6)                           | success | testdb |
      | rwS1 | 111111 | conn_0 | true    | select sum(age) from testtb               | success | testdb |

    Then check following text exist "Y" in file "/root/sandboxes/sandbox/master/data/mysql-2.log" in host "mysql-master2"
       """
       begin
       update testtb set id = 43 where age = 21
       select sleep\(6\)
       select id,age from testtb order by null
       commit
       select id from testtb order by id limit 3
       select last_insert_id\(\)
       """
    Then check following text exist "N" in file "/root/sandboxes/sandbox/master/data/mysql-2.log" in host "mysql-master2"
       """
       select sum\(age\) from testtb
       """
    Then check following text exist "Y" in file "/root/sandboxes/sandbox/node1/data/mysql-2.log" in host "mysql-slave1"
       """
       select sum\(age\) from testtb
       """
    Then check following text exist "N" in file "/root/sandboxes/sandbox/node1/data/mysql-2.log" in host "mysql-slave1"
       """
       update testtb set id = 43 where age = 21
       select sleep\(6\)
       select id,age from testtb order by null
       select id from testtb order by id limit 3
       select last_insert_id\(\)
       """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                       | expect  | db     |
      | rwS1 | 111111 | conn_0 | False   | drop table if exists testtb               | success | testdb |
      | rwS1 | 111111 | conn_0 | true    | drop database if exists testdb            | success |        |