# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/12/17
Feature: stop dble cluster and zk service
@skip_restart
  Scenario:  stop dble cluster and zk service
    Given stop dble cluster and zk service