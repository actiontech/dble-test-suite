# Created by lizizi at 2020/7/3
Feature: config sharding config files incorrect and restart dble or reload configs

  Scenario: config db property, reload the configs #1
    Given update file content "/opt/dble/conf/sharding.xml" in "dble-1" with sed cmds
    """
      /<shardingNode dbGroup/d
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      shardingNode 'dn5' is not found!
    """

  Scenario: config db property, reload the configs #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema shardingNode="" name="schema1" sqlMaxLimit="100"/>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
      sharding schema1 didn't config tables,so you must set shardingNode property
    """