# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/7/27


Feature: on zookeeper to check start config


  Scenario:  when one dble start success ,the config sync other dble #1
    Given stop dble cluster and zk service
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <shardingNode dbGroup="ha_group22" database="db1" name="dn2" />
      """
    Then restart dble in "dble-1" failed for
      """
      The dbGroup\[ha_group22\] associated with ShardingNode\[dn2\] does not exist
      """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      dbGroup="ha_group22"
      """
    Then check following text exist "N" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      dbGroup="ha_group22"
      """
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding  >/tmp/dble_conf_sharding.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_conf_sharding.log" in host "dble-1"
      """
      Node does not exist
      """
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls / >/tmp/dble_zk.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk.log" in host "dble-1"
      """
      \[dble, zookeeper\]
      """

    Given stop dble cluster and zk service
    Given replace config files in all dbles with command line config
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema2" shardingNode="dn1" sqlMaxLimit="101" >
          <shardingTable name="sharding" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
        <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="1000" >
          <heartbeat>select 5</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1111" minCon="22" primary="true">
          </dbInstance>
        </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
       <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order

    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/db  >/tmp/dble_conf_db.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_conf_db.log" in host "dble-1"
      """
      {"dbGroup":\[
      {"rwSplitMode":0,"name":"ha_group1","delayThreshold":100,"heartbeat":{"value":"select user()"},
      "dbInstance":\[{"name":"hostM1","url":"172.100.9.5:3306","password":"111111","user":"test","maxCon":1000,"minCon":10,"primary":true}\]},
      {"rwSplitMode":0,"name":"ha_group2","delayThreshold":1000,"heartbeat":{"value":"select 5"},
      "dbInstance":\[{"name":"hostM2","url":"172.100.9.6:3306","password":"111111","user":"test","maxCon":1111,"minCon":22,"primary":true}
      """
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding  >/tmp/dble_conf_sharding.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_conf_sharding.log" in host "dble-1"
      """
      {"schema":\[
      {"name":"schema1","sqlMaxLimit":100,"shardingNode":"dn5",
      "table":\[
      {"type":"GlobalTable","properties":{"name":"test","shardingNode":"dn1,dn2,dn3,dn4"}},
      {"type":"ShardingTable","properties":{"function":"hash-two","shardingColumn":"id","name":"sharding_2_t1","shardingNode":"dn1,dn2"}},
      {"type":"ShardingTable","properties":{"function":"hash-four","shardingColumn":"id","name":"sharding_4_t1","shardingNode":"dn1,dn2,dn3,dn4"}}\]},
      {"name":"schema2","sqlMaxLimit":101,"shardingNode":"dn1",
      "table":\[
      {"type":"ShardingTable","properties":{"function":"hash-two","shardingColumn":"id","name":"sharding","shardingNode":"dn1,dn2"}}\]}\],
      "shardingNode":\[
      {"name":"dn1","dbGroup":"ha_group1","database":"db1"},{"name":"dn2","dbGroup":"ha_group2","database":"db1"},{"name":"dn3","dbGroup":"ha_group1","database":"db2"},
      {"name":"dn4","dbGroup":"ha_group2","database":"db2"},{"name":"dn5","dbGroup":"ha_group1","database":"db3"}\],
      "function":\[
      {"name":"hash-two","clazz":"Hash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
      {"name":"hash-three","clazz":"Hash","property":\[{"value":"3","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
      {"name":"hash-four","clazz":"Hash","property":\[{"value":"4","name":"partitionCount"},{"value":"1","name":"partitionLength"}\]},
      {"name":"hash-string-into-two","clazz":"StringHash","property":\[{"value":"2","name":"partitionCount"},{"value":"1","name":"partitionLength"}
      """
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/user  >/tmp/dble_conf_user.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_conf_user.log" in host "dble-1"
      """
      {"user":\[{"type":"ManagerUser","properties":{"name":"root","password":"111111"}},{"type":"ShardingUser","properties":{"schemas":"schema1,schema2","name":"test","password":"111111"}
      """
    Given execute linux command in "dble-1"
      """
      rm -rf /tmp/dble_*
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <shardingNode dbGroup="ha_group22" database="db1" name="dn2" />
      """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      The dbGroup[ha_group22] associated with ShardingNode[dn2] does not exist
      """
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      dbGroup="ha_group22"
      """
    Then check following text exist "N" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      dbGroup="ha_group22"
      """
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding  >/tmp/dble_conf_sharding.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_conf_sharding.log" in host "dble-1"
      """
      "shardingNode":\[
      {"name":"dn1","dbGroup":"ha_group1","database":"db1"},{"name":"dn2","dbGroup":"ha_group2","database":"db1"},{"name":"dn3","dbGroup":"ha_group1","database":"db2"},
      {"name":"dn4","dbGroup":"ha_group2","database":"db2"},{"name":"dn5","dbGroup":"ha_group1","database":"db3"}\],
      """
    Then check following text exist "N" in file "/tmp/dble_conf_sharding.log" in host "dble-1"
      """
      {"name":"dn2","dbGroup":"ha_group22","database":"db1"}
      """

    Then restart dble in "dble-1" success
     ## The restart is successful because the metadata overwrites the wrong config, Use correct metadata in zk conf
    Then check following text exist "N" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      dbGroup="ha_group22"
      """

    Given execute linux command in "dble-1"
      """
      rm -rf /tmp/dble_*
      """