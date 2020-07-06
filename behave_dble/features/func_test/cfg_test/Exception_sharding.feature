# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: sharding basic config test

  Scenario: config with no shardingNode, reload fail #1
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |

    Then execute admin cmd "reload @@config_all" get the following output
    """
    shardingNode 'dn5' is not found!
    """

  Scenario: config without the names of shardingNode, reload fail #2
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |

    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
    """
        <shardingNode dbGroup="ha_group1" database="db1"/>
        <shardingNode dbGroup="ha_group2" database="db1"/>

    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Attribute "name" is required and must be specified for element type "shardingNode"
    """


  Scenario: config without the names of shardingNode, reload fail #2
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |

    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml"
    """
        <shardingNode dbGroup="ha_group1" database="db1"/>
        <shardingNode dbGroup="ha_group2" database="db1"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Attribute "name" is required and must be specified for element type "shardingNode"
    """

  Scenario: config two shardingNode with same name, reload fail #3
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |

    Given add xml segment to node with attribute "{'tag':'root','prev':'schema'}" in "sharding.xml" with duplicate name
    """
        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    shardingNode dn1 duplicated!
    """

  Scenario: config with no function, reload fail #4
    Given delete the following xml segment
      | file         | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'function'} |

    Then execute admin cmd "reload @@config_all" get the following output
    """
    can't find function of name :hash-two in table sharding_2_t1
    """


  Scenario: config the value of sqlmaxLimit as -100, reload success #5
    Given delete the following xml segment
      | file         | parent         | child            |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="-100">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Given Restart dble in "dble-1" success
#    Then connect "dble-1" to insert "10000" of data for "sharding_2_t1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1               | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name char(20)) | success | schema1 |

    Then connect "dble-1" to insert "10000" of data for "sharding_4_t1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect          | db      |
      | conn_0 | True    | select * from sharding_4_t1 | length{(10000)} | schema1 |


  Scenario: config "schema" node attr "shardingColumn" as two spaces, reload fail #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="  " />
    </schema>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Attribute value "" of type NMTOKEN must be a name token
    """

  Scenario: test the effectiveness of wildcard , reload success #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn$1-2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn$1-4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"


  Scenario: test the effectiveness of wildcard , reload success #8

#    some problem with this case, the count of shardingNode should be equal to partitionCount,
#    but when the count of shardingNode is larger than partitionCount ,it reloads successfully

    Given delete the following xml segment
      | file         | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'function'} |

    Given add xml segment to node with attribute "{'tag':'root','prev':'shardingNode'}" in "sharding.xml"
    """
      <function class="Hash" name="hash-two">
          <property name="partitionCount">2</property>
          <property name="partitionLength">1</property>
      </function>
      <function class="Hash" name="hash-three">
          <property name="partitionCount">3</property>
          <property name="partitionLength">1</property>
      </function>
      <function class="Hash" name="hash-four">
          <property name="partitionCount">2</property>
          <property name="partitionLength">1</property>
      </function>
    """
    Then execute admin cmd "reload @@config_all"

    Given delete the following xml segment
      | file         | parent         | child              |
      | sharding.xml | {'tag':'root'} | {'tag':'function'} |
    Given add xml segment to node with attribute "{'tag':'root','prev':'shardingNode'}" in "sharding.xml"
    """
      <function class="Hash" name="hash-two">
          <property name="partitionCount">4</property>
          <property name="partitionLength">1</property>
      </function>
      <function class="Hash" name="hash-three">
          <property name="partitionCount">3</property>
          <property name="partitionLength">1</property>
      </function>
      <function class="Hash" name="hash-four">
          <property name="partitionCount">4</property>
          <property name="partitionLength">1</property>
      </function>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    please make sure table shardingnode size = function partition size
    """

  Scenario:test the parameter of slow_log and flow_control
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect         |
      | conn_0 | False   | show @@slow_query_log                                                                  | has{('0',)}    |
      | conn_0 | False   | enable @@slow_query_log                                                                | success        |
      | conn_0 | False   | show @@slow_query_log                                                                  | has{('1',)}    |

      | conn_0 | False   | show @@slow_query.time                                                                 | has{('100',)}  |
      | conn_0 | False   | reload @@slow_query.time = 200                                                         | success        |
      | conn_0 | False   | show @@slow_query.time                                                                 | has{('200',)}  |

      | conn_0 | False   | show @@slow_query.flushperiod                                                          | has{('1',)}    |
      | conn_0 | False   | reload @@slow_query.flushperiod = 200                                                  | success        |
      | conn_0 | False   | show @@slow_query.flushperiod                                                          | has{('200',)}  |

      | conn_0 | False   | show @@slow_query.flushsize                                                            | has{('1000',)} |
      | conn_0 | False   | reload @@slow_query.flushsize = 500                                                    | success        |
      | conn_0 | True    | show @@slow_query.flushsize                                                            | has{('500',)}  |

      | conn_0 | False   | flow_control @@set enableFlowControl = true flowControlStart= 200 flowControlEND = 100 | success        |

    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
    """
    enableSlowLog=1
    flushSlowLogSize=500
    flushSlowLogPeriod=200
    sqlSlowTime=200
    enableFlowControl=true
    flowControlStartThreshold=200
    flowControlStopThreshold=100
    """

    Then Restart dble in "dble-1" success

    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
    """
    enableSlowLog=1
    flushSlowLogSize=500
    flushSlowLogPeriod=200
    sqlSlowTime=200
    enableFlowControl=true
    flowControlStartThreshold=200
    flowControlStopThreshold=100
    """

  Scenario: config with Multi_sharding tables, reload success
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="tb_parent" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id">
            <childTable name="tb_child1" joinColumn="child1_id" parentColumn="id" sqlMaxLimit="201" incrementColumn="id">
                <childTable name="tb_grandson1" joinColumn="grandson1_id" parentColumn="child1_id"/>
                     <childTable name="tb_great_grandson1" joinColumn="great_grandson1_id" parentColumn="grandson1_id"/>
                <childTable name="tb_grandson2" joinColumn="grandson2_id" parentColumn="child1_id2"/>
            </childTable>
            <childTable name="tb_child2" joinColumn="child2_id" parentColumn="id"/>
            <childTable name="tb_child3" joinColumn="child3_id" parentColumn="id2"/>
        </shardingTable>
        </schema>
    """
    Then execute admin cmd "reload @@config_all"

  Scenario: config with no sqlMaxLimit, reload success
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <schema shardingNode="dn5" name="schema1">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
            <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        </schema>
    """
    Then execute admin cmd "reload @@config_all"


    
