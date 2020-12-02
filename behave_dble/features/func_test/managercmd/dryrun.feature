# Copyright (C) 2016-2021 ActionTech.
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/4/10 update by quexiuping at 2020/12/02

Feature: # dryrun test

  Scenario: # from DBLE0REQ-721  #1
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql         |
      | dryrun      |
    Then check resultset "A" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                  |
      | Meta    | WARNING | Table schema1.test don't exists in shardingNode[dn1,dn2,dn3,dn4]          |
      | Meta    | WARNING | Table schema1.sharding_2_t1 don't exists in shardingNode[dn1,dn2]         |
      | Meta    | WARNING | Table schema1.sharding_4_t1 don't exists in shardingNode[dn1,dn2,dn3,dn4] |
#      | Xml     | NOTICE  | There is No RWSplit User                                                  |
      | Cluster | NOTICE  | Dble is in single mod                                                     |