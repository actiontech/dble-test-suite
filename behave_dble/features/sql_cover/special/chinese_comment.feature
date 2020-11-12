# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/9/20
Feature: verify issue http://10.186.18.21/universe/ushard/issues/92 #Enter feature name here
  # todo: the issue only occur under ushard ha env


  Scenario: #1 support comment has chinese
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                         | expect  | db      | charset |
      | conn_0 | False   | drop table if exists test_table                                                                                             | success | schema1 | utf8mb4 |
      | conn_0 | False   | create table test_table(`series` bigint(20) NOT NULL DEFAULT '1' COMMENT '行号',PRIMARY KEY (`series`)) DEFAULT CHARSET=utf8 | success | schema1 | utf8mb4 |
      | conn_0 | True    | drop table test_table                                                                                                       | success | schema1 | utf8mb4 |



