# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/5/12

Feature: Keep slow log on, dble may occur oom

  @btrace
  Scenario: Keep slow log on, dble may occur oom , issues/2638     #1

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /enableSlowLog/d
      $a -DenableSlowLog=1
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                   | expect        |
      | conn_1 | true    | reload @@slow_query.time = 0          | success       |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect   | db          |
      | conn_0 | False   | drop table if exists sharding_2_t1                      | success  | schema1     |
      | conn_0 | False   | create table sharding_2_t1(id int , name varchar(12))   | success  | schema1     |
      | conn_0 | False   | insert into sharding_2_t1 value (1,1)                   | success  | schema1     |

    Given delete file "/opt/dble/BtraceAboutslowlog.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutslowlog.java.log" on "dble-1"
    Given prepare a thread run btrace script "BtraceAboutslowlog.java" in "dble-1"
    Given execute sql "1000" times in "dble-1" at concurrent
      | sql                                                   | db      |
      | /*!dble:shardingnode=dn1*/select * from sharding_2_t1 | schema1 |

## when use 3.21.02 will has log output
#    Then check btrace "BtraceAboutslowlog.java" output in "dble-1" with "900" times
#    """
#    enter setShardingNodes
#    """
    Then check btrace "BtraceAboutslowlog.java" output in "dble-1" with "0" times
    """
    enter setShardingNodes
    """
    Given stop btrace script "BtraceAboutslowlog.java" in "dble-1"
    Given destroy btrace threads list
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect      | db      |
      | conn_0 | False   | set @@trace=1                                             | success     | schema1 |
      | conn_0 | False   | /*!dble:shardingnode=dn1*/select * from sharding_2_t1     | success     | schema1 |
      | conn_0 | true    | show trace                                                | length{(8)} | schema1 |

      Then check following text exist "Y" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      drop table if exists sharding_2_t1
      create table sharding_2_t1(id int , name varchar(12))
      insert into sharding_2_t1 value (1,1)
      dble:shardingnode=dn1
      select \* from sharding_2_t1
      dn1_First_Result_Fetch
      dn1_Last_Result_Fetch
      SINGLE_NODE_QUERY
      """
    Given execute oscmd in "dble-1"
    """
    >/opt/dble/slowlogs/slow-query.log
    """

#######case : load data
    Given execute oscmd in "dble-1"
    """
    echo -e '1,1\n2,2\n3,3\n4,4\n5,5\n6,6\n7,7\n8,8\n9,9\n10,10\n11,11\n12,12\n13,13\n14,14\n15,15\n16,16\n17,17\n18,18\n19,19\n20,20' > /opt/dble/test.txt
    """
    Given delete file "/opt/dble/BtraceAboutslowlog.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutslowlog.java.log" on "dble-1"
    Given prepare a thread run btrace script "BtraceAboutslowlog.java" in "dble-1"
    Given execute sql "1000" times in "dble-1" at concurrent
      | sql                                                                                     | db      |
      | load data infile './test.txt' into table sharding_2_t1 fields terminated by ','         | schema1 |

## when use 3.21.02 will has log output
#    Then check btrace "BtraceAboutslowlog.java" output in "dble-1" with "900" times
#    """
#    enter setShardingNodes
#    """
    Then check btrace "BtraceAboutslowlog.java" output in "dble-1" with "0" times
    """
    enter setShardingNodes
    """
    Given stop btrace script "BtraceAboutslowlog.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutslowlog.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutslowlog.java.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect          | db      |
      | conn_0 | true    | select * from sharding_2_t1 limit 30000        | length{(20001)} | schema1 |
      Then check following text exist "Y" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      load data infile
      test.txt
      into table sharding_2_t1 fields terminated by
      select \* from sharding_2_t1 limit 30000
      dn1_First_Result_Fetch
      dn1_Last_Result_Fetch
      dn2_First_Result_Fetch
      dn2_Last_Result_Fetch
      MULTI_NODE_QUERY
      """
      Then check following text exist "N" in file "/opt/dble/slowlogs/slow-query.log" in host "dble-1"
      """
      drop table if exists sharding_2_t1
      create table sharding_2_t1(id int , name varchar(12))
      insert into sharding_2_t1 value (1,1)
      SINGLE_NODE_QUERY
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect   | db      |
      | conn_0 | true    | drop table if exists sharding_2_t1         | success  | schema1 |