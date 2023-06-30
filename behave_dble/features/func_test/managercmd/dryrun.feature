# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/4/10 update by quexiuping at 2020/12/02

Feature: # dryrun test

  @skip
    ##这个版本的结果是不稳定的
  Scenario: check cmd "dryrun"  #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
       """
       <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
       </schema>
       """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql         |
      | dryrun      |
    Then check resultset "A" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                  |
      | Xml     | NOTICE  | There is No RWSplit User                                                  |
      | Cluster | NOTICE  | Dble is in single mod                                                     |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
       """
       <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
          <table name="global" dataNode="dn1,dn2,dn3,dn4" type="global" />
          <table name="sing" dataNode="dn5" />
          <table name="sharding_4" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
       </schema>

       <schema name="schema2" >
           <table name="sharding_2" dataNode="dn1,dn3" rule="hash-two" />
       </schema>
       """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | sql         |
      | dryrun      |
    Then check resultset "B" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                    |
      | Meta    | WARNING | Table schema1.global doesn't exists in dataNode(s)[dn1,dn2,dn3,dn4]     |
      | Meta    | WARNING | Table schema1.sing doesn't exists in dataNode(s)[dn5]                   |
      | Meta    | WARNING | Table schema1.sharding_4 doesn't exists in dataNode(s)[dn1,dn2,dn3,dn4] |
      | Meta    | WARNING | Table schema2.sharding_2 doesn't exists in dataNode(s)[dn1,dn3]         |
      | Xml     | WARNING | Schema:schema2 has no user                                                  |
      | Xml     | NOTICE  | There is No RWSplit User                                                    |
      | Cluster | NOTICE  | Dble is in single mod                                                       |

    Given delete the following xml segment
      | file       | parent         | child                  |
      | user.xml   | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group1" maxCon="0"/>
       """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | sql         |
      | dryrun      |
    Then check resultset "C" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                  |
      | Xml     | NOTICE  | There is No Sharding User                                                 |
      | Cluster | NOTICE  | Dble is in single mod                                                     |
    Then check resultset "C" has not lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                    |
      | Meta    | WARNING | Table schema1.global doesn't exists in dataNode(s)[dn1,dn2,dn3,dn4]     |
      | Meta    | WARNING | Table schema1.sing doesn't exists in dataNode(s)[dn5]                   |
      | Meta    | WARNING | Table schema1.sharding_4 doesn't exists in dataNode(s)[dn1,dn2,dn3,dn4] |
      | Meta    | WARNING | Table schema2.sharding_2 doesn't exists in dataNode(s)[dn1,dn3]         |
      | Xml     | WARNING | Schema:schema2 has no user                                                  |
      | Xml     | NOTICE  | There is No RWSplit User                                                    |
