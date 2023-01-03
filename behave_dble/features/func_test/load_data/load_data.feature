# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/8
  # 2.19.11.0#dble-7888
Feature: connect dble in mysql-master1, and execute cmd "load data" with relative path or absolute path

  Scenario: load data with relative path #1
    Given execute oscmd in "dble-1"
    """
    echo -e '1,1\n2,2\n3,3' > /opt/dble/test.txt
    """
    Given execute oscmd in "mysql-master1"
    """
    echo -e '20,20\n30,30' > /root/sandboxes/sandbox/data/test.txt
    """
    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    drop table if exists schema1.test
    create table schema1.test(id int,c int)
    load data infile './test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    """
    Then execute sql in "dble-1" in "user" mode
      | sql                | expect                         | db      |
      | select * from test | hasStr{(1, 1), (2, 2), (3, 3)} | schema1 |

    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    load data local infile './test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                 | expect                                             | db      |
      | conn_0 | False   | select * from test  | hasStr{(1, 1), (2, 2), (3, 3), (20, 20), (30, 30)} | schema1 |
      | conn_0 | True    | truncate table test | success                                            | schema1 |

    #load data with absolute path #2
    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    load data infile '/opt/dble/test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    load data local infile '/root/sandboxes/sandbox/data/test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    """
    Then execute sql in "dble-1" in "user" mode
      | sql                | expect                                             | db      |
      | select * from test | hasStr{(1, 1), (2, 2), (3, 3), (20, 20), (30, 30)} | schema1 |
    Given execute oscmd in "dble-1"
    """
    rm -rf /opt/dble/test.txt
    """
    Given execute oscmd in "mysql-master1"
    """
    rm -rf /root/sandboxes/sandbox/data/test.txt
    """

  #DBLE0REQ-1587
  Scenario: The value of a column in the data is empty, and the data can be successfully inserted  #2
    Given execute oscmd in "dble-1"
    """
    echo -e '1,abc\n2,\n3,qwe' > /opt/dble/test.txt
    """
    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    drop table if exists schema1.test
    create table schema1.test(id int,c varchar(10))
    load data infile '/opt/dble/test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    """
    Then execute sql in "dble-1" in "user" mode
      | sql                | expect                                  | db      |
      | select * from test | hasStr{(1, 'abc'), (2, ''), (3, 'qwe')} | schema1 |

    Given execute oscmd in "dble-1"
    """
    rm -rf /opt/dble/test.txt
    """

  #DBLE0REQ-1595
  Scenario: When load data empty file, there will be unexpected data import  #3
    Given execute oscmd in "dble-1"
    """
    echo -e '' > /opt/dble/test.txt
    """
    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    drop table if exists schema1.test
    create table schema1.test(id int,c varchar(10))
    load data infile '/opt/dble/test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    """

    Then execute sql in "dble-1" in "user" mode
      | sql                | expect     | db      |
      | select * from test | hasStr{()} | schema1 |

    Given execute oscmd in "dble-1"
    """
    rm -rf /opt/dble/test.txt
    """