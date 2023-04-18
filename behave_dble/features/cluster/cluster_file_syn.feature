# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/9/29

Feature: Cluster file synchronization test

  Scenario: ruleFile in the cluster need to be synchronized to each node
    # http://10.186.18.11/jira/browse/DBLE0REQ-1409
    Given stop dble in "dble-2"
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema2" sqlMaxLimit="100">
          <shardingTable name="new_sharding" function="func_enum" shardingColumn="id" shardingNode="dn1,dn2"/>
        </schema>

        <function name="func_enum" class="Enum">
        <property name="mapFile">enum.txt</property>
        <property name="defaultNode">0</property>
        <property name="type">0</property>
        </function>
      """
    Given delete the following xml segment
        |file            | parent          | child                     |
        |user.xml        |{'tag':'root'}   | {'tag':'shardingUser'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
         <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
       """
    Given execute oscmd in "dble-1"
       """
         rm -rf /opt/dble/conf/enum.txt
       """
    Given execute oscmd in "dble-1"
      """
        echo -e '1=0\n2=0\n3=1\n4=1' > /opt/dble/conf/enum.txt
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                              | expect   |
      |conn_0 | true    | reload @@config_all              | success  |
    Then check following text exist "Y" in file "/opt/dble/conf/enum.txt" in host "dble-3"
      """
      1=0
      2=0
      3=1
      4=1
      """
    Then Start dble in "dble-2"
    Then check zk has "Y" the following values in "/dble/cluster-1/online" with retry "10,3" times in "dble-1"
      """
      [1,2,3]
      """
    Then check following text exist "Y" in file "/opt/dble/conf/enum.txt" in host "dble-2"
      """
      1=0
      2=0
      3=1
      4=1
      """
    Then execute sql in "dble-1" in "user" mode
      |conn   | toClose | sql                                                               |  db          | expect   |
      |conn_1 | False   | drop table if exists new_sharding                                 | schema2      | success  |
      |conn_1 | False   | create table new_sharding(id int)                                 | schema2      | success  |
      |conn_1 | true    | insert into table new_sharding values(1),(2),(3),(4),(100),(1000) | schema2      | success  |
     Then execute sql in "mysql-master1" in "mysql" mode
      |conn   | toClose | sql                                                           |  db        | expect                       |
      |conn_2 | true    | select * from new_sharding                                    |  db1       | has{(1,),(2,),(100,),(1000,)}|
     Then execute sql in "mysql-master2" in "mysql" mode
      |conn   | toClose | sql                                                           |  db        | expect                     |
      |conn_3 | true    | select * from new_sharding                                    |  db1       | has{(3,),(4,)}             |

    #modify file context, file also should be synchronized
    Given execute oscmd in "dble-1"
      """
        echo -e '5=1\n6=1\n7=0' >> /opt/dble/conf/enum.txt
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                              | expect   |
      |conn_1 | true    | reload @@config_all              | success  |
    Then check following text exist "Y" in file "/opt/dble/conf/enum.txt" in host "dble-2"
      """
      1=0
      2=0
      3=1
      4=1
      5=1
      6=1
      7=0
      """
    Then check following text exist "Y" in file "/opt/dble/conf/enum.txt" in host "dble-3"
      """
      1=0
      2=0
      3=1
      4=1
      5=1
      6=1
      7=0
      """
    Then execute sql in "dble-1" in "user" mode
      |conn   | toClose | sql                                                              |  db               | expect   |
      |conn_4 | true    | insert into table new_sharding values(5),(6),(7),(10000)         | schema2           | success  |
    Then execute sql in "mysql-master1" in "mysql" mode
      |conn   | toClose | sql                                                           |  db        | expect                            |
      |conn_5 | true    | select * from new_sharding                                    |  db1       | has{(1,),(2,),(7,),(100,),(1000,)}|
    Then execute sql in "mysql-master2" in "mysql" mode
      |conn   | toClose | sql                                                           |  db        | expect                       |
      |conn_6 | true    | select * from new_sharding                                    |  db1       | has{(3,),(4,),(5,),(6,)}     |
    Then execute sql in "dble-1" in "user" mode
      |conn   | toClose | sql                                                              |  db               | expect   |
      |conn_7 | true    | drop table if exists new_sharding                                | schema2           | success  |
    Given execute oscmd in "dble-1"
      """
        rm -rf /opt/dble/conf/enum.txt
      """
    Given execute oscmd in "dble-2"
      """
        rm -rf /opt/dble/conf/enum.txt
      """
    Given execute oscmd in "dble-3"
      """
        rm -rf /opt/dble/conf/enum.txt
      """

