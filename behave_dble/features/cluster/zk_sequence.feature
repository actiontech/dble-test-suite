# Created by maofei at 2019/5/20
Feature: Functional testing of global sequence generated by distributed timestamp
  @skip_restart
  Scenario: Verify the illegal value of the parameter in the sequence_distributed_conf.properties  #1
  #    case points:
  #  1.Verify the illegal value of the INSTANCEID
  #  2.Verify the illegal value of the CLUSTERID
  #  3.Verify the illegal value of the START_TIME
  #  4.START_TIME>the time of dble start
  #  5.START_TIME+17 years<the time of dble start
    Given reset dble registered nodes in zk
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_auto" dataNode="dn1,dn2,dn3,dn4" incrementColumn="id" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="sequnceHandlerType">3</property>
    """
    Then start dble in order
    #case 1: Verify the illegal value of the INSTANCEID
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=32
    """
    Then restart dble in "dble-1" failed for
    """
     INSTANCEID Id can't be greater than 31 or less than 0
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=-1
    """
    Then restart dble in "dble-1" failed for
    """
     INSTANCEID Id can't be greater than 31 or less than 0
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /INSTANCEID/c INSTANCEID=01
    """
    Given Restart dble in "dble-1" success
    #case 2: Verify the illegal value of the CLUSTERID
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /CLUSTERID/c CLUSTERID=32
    """
    Then restart dble in "dble-1" failed for
    """
     CLUSTERID Id can't be greater than 31 or less than 0
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /CLUSTERID/c CLUSTERID=-1
    """
    Then restart dble in "dble-1" failed for
    """
     CLUSTERID Id can't be greater than 31 or less than 0
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /CLUSTERID/c CLUSTERID=01
    """
    Given Restart dble in "dble-1" success
    #case 3: Verify the illegal value of the START_TIME
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /START_TIME/c START_TIME=2010/11/04 09:42:54
    """
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
#    Given Restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    START_TIME in sequence_distributed_conf.properties parse exception, starting from 2010-11-04 09:42:54
    """
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /START_TIME/c START_TIME=2010-11-04 09:42:54
    """
#    Given Restart dble in "dble-1" success
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    #case 4: START_TIME>the time of dble start
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /START_TIME/c START_TIME=2190-10-01 09:42:54
    """
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    START_TIME in sequence_distributed_conf.properties mustn'\''t be over than dble start time, starting from 2010-11-04 09:42:54
    """
    #case 5: START_TIME+17 years<the time of dble start
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /START_TIME/c START_TIME=2000-10-01 09:42:54
    """
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                | expect       | db      |
      | conn_0 | False    |drop table if exists test_auto                      | success      | schema1 |
      | conn_0 | False    |create table test_auto(id bigint,time char(120))    | success      | schema1 |
      | conn_0 | True     |insert into test_auto values(1)                     | Global sequence has reach to max limit and can generate duplicate sequences  | schema1 |
    Given update file content "{install_dir}/dble/conf/sequence_distributed_conf.properties" in "dble-1" with sed cmds
    """
    /START_TIME/c START_TIME=2010-11-04 09:42:54
    """
    Then stop dble in "dble-1"
    Given sleep "60" seconds
    Then Start dble in "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | sql                              | expect         | db     |
      |insert into test_auto values(1)   | success        | schema1 |