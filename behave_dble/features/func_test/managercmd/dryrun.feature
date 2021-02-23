# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/4/10 update by quexiuping at 2020/12/02

Feature: # dryrun test


  Scenario: check cmd "dryrun"  #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
       """
       <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
       </schema>
       """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | sql         |
      | dryrun      |
    Then check resultset "A" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                  |
      | Xml     | NOTICE  | There is No RWSplit User                                                  |
      | Cluster | NOTICE  | Dble is in single mod                                                     |

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
       """
       <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
          <globalTable name="global" shardingNode="dn1,dn2,dn3,dn4" />
          <singleTable name="sing" shardingNode="dn5" />
          <shardingTable name="sharding_4" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
       </schema>

       <schema name="schema2" >
           <shardingTable name="sharding_2" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
       </schema>
       """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | sql         |
      | dryrun      |
    Then check resultset "B" has lines with following column values
      | TYPE-0  | LEVEL-1 | DETAIL-2                                                                    |
      | Meta    | WARNING | Table schema1.global doesn't exists in shardingNode(s)[dn1,dn2,dn3,dn4]     |
      | Meta    | WARNING | Table schema1.sing doesn't exists in shardingNode(s)[dn5]                   |
      | Meta    | WARNING | Table schema1.sharding_4 doesn't exists in shardingNode(s)[dn1,dn2,dn3,dn4] |
      | Meta    | WARNING | Table schema2.sharding_2 doesn't exists in shardingNode(s)[dn1,dn3]         |
      | Xml     | WARNING | Schema:schema2 has no user                                                  |
      | Xml     | NOTICE  | There is No RWSplit User                                                    |
      | Cluster | NOTICE  | Dble is in single mod                                                       |

    Given delete the following xml segment
      | file       | parent         | child                  |
      | user.xml   | {'tag':'root'} | {'tag':'managerUser'}  |
      | user.xml   | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <managerUser name="root" password="111111"/>
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
      | Meta    | WARNING | Table schema1.global doesn't exists in shardingNode(s)[dn1,dn2,dn3,dn4]     |
      | Meta    | WARNING | Table schema1.sing doesn't exists in shardingNode(s)[dn5]                   |
      | Meta    | WARNING | Table schema1.sharding_4 doesn't exists in shardingNode(s)[dn1,dn2,dn3,dn4] |
      | Meta    | WARNING | Table schema2.sharding_2 doesn't exists in shardingNode(s)[dn1,dn3]         |
      | Xml     | WARNING | Schema:schema2 has no user                                                  |
      | Xml     | NOTICE  | There is No RWSplit User                                                    |
