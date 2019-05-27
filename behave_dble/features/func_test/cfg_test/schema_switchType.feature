# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/11/28
Feature: test for datahost property switchType
  switchType=-1: no ha
  switchType=1: change master when heartbeat abnormal
  switchType=2: change master due to replication state, heartbeat sql should be "show slave status"
  switchType=3，change master base MySQL galary cluster mechanism，heartbeat sql should be "show status like 'wsrep%'"
  ha works under premise:
  1.writeHost heartbeat abnormal
  2.multiple writeHost
  3.switchtype != -1

  @skip
  Scenario: # Enter scenario name here
    # Enter steps here