# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/8/16

Feature: check heartbeat
  #DBLE0REQ-1371
  Scenario: check heartbeat connection - dbInstance has only one heartbeat connection #2
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect  |
      | conn_0 | False   | dbGroup @@disable name='ha_group1' instance='hostM1'                | success |
      | conn_0 | False   | fresh conn forced where dbGroup='ha_group1' and dbInstance='hostM1' | success |
      | conn_0 | False   | dbGroup @@enable name='ha_group1' instance='hostM1'                 | success |
      | conn_0 | False   | reload @@config_all                                                 | success |
      | conn_0 | False   | reload @@config_all -fr                                             | success |
      | conn_0 | True    | select * from dble_information.backend_connections where used_for_heartbeat='true' and db_instance_name='hostM1' | length{(1)} |
    Given sleep "60" seconds
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    setTimeout
    """