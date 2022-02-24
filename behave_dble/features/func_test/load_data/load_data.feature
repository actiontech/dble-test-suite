# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/8
Feature: connect dble in mysql-master1, and execute cmd "load data" with relative path or absolute path

  Scenario: load data with relative path #1
    Given execute oscmd in "dble-1"
    """
    echo -e '1,1\n2,2\n3,3' > /opt/dble/test.txt
    """
    Given execute oscmd in "mysql-master1"
    """
    echo -e '20,20\n30,30' > /usr/local/mysql/data/test.txt
    """
    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    drop table if exists schema1.test
    create table schema1.test(id int,c int)
    load data infile './test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                | expect                         | db      |
      | test | 111111 | new  | True    | select * from test | hasStr{(1, 1), (2, 2), (3, 3)} | schema1 |

    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    load data local infile './test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                 | expect                                             | db      |
      | test | 111111 | new  | True    | select * from test  | hasStr{(1, 1), (2, 2), (3, 3), (20, 20), (30, 30)} | schema1 |
      | test | 111111 | new  | True    | truncate table test | success                                            | schema1 |

    #load data with absolute path #2
    Given connect "dble-1" with user "test" in "mysql-master1" to execute sql
    """
    load data infile '/opt/dble/test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    load data local infile '/usr/local/mysql/data/test.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'
    """
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn | toClose | sql                | expect                                             | db      |
      | test | 111111 | new  | True    | select * from test | hasStr{(1, 1), (2, 2), (3, 3), (20, 20), (30, 30)} | schema1 |
    Given execute oscmd in "dble-1"
    """
    rm -rf /opt/dble/test.txt
    """
    Given execute oscmd in "mysql-master1"
    """
    rm -rf /usr/local/mysql/data/test.txt
    """