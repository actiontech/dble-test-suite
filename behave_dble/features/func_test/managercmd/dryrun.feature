# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/4/10
# update by quexiuping at 2020/8/26

Feature:  dryrun test

  Scenario: type value "dn9" in sharding.xml is not found from document and http://10.186.18.11/jira/browse/DBLE0REQ-467 #1
    # case http://10.186.18.11/jira/browse/DBLE0REQ-467
    Given add xml segment to node with attribute "{'tag':'schema'}" in "sharding.xml"
    """
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql          | expect                                                                        |
      | dryrun       | has{('Meta', 'WARNING', "Can't get connection for Meta check in shardingNode[hostM1.db1]"),('Cluster', 'NOTICE', 'Dble is in single mod')}          |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    can't get connection for sql :show full tables where Table_type ='BASE TABLE'
    """
    # case type value "dn9" in sharding.xml is not found
    Given add xml segment to node with attribute "{'tag':'schema'}" in "sharding.xml"
    """
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn9" />
    """
    Then execute sql in "dble-1" in "admin" mode
      | sql          | expect                              |
      | dryrun       | shardingNode 'dn9' is not found!    |


