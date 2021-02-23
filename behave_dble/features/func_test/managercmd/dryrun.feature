# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/4/10 update by quexiuping at 2020/12/02

Feature: # dryrun test

  Scenario: check cmd "dryrun"  #1
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql         |
      | dryrun      |
    Then check resultset "A" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                  |
      | Xml     | NOTICE  | There is No RWSplit User                                                  |
      | Cluster | NOTICE  | Dble is in single mod                                                     |


