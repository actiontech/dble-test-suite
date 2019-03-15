Feature: install dble cluster, degrade to single dble, recover to cluster

  @BLOCKER
  @skip_restart
  Scenario: install zk cluster, degrade to single dble, recover to cluster #1
    Given stop dble cluster and zk service
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Given replace config files in all dbles with command line config
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
    Given stop dble cluster and zk service
    Then Start dble in "dble-1"
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
    Given stop dble cluster and zk service

  Scenario: config dble cluster with all zookeeper hosts,check online nodes #2
    Given stop dble cluster and zk service
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Given replace config files in all dbles with command line config
    Given config zookeeper cluster in all dble nodes with "all zookeeper hosts"
    Given reset dble registered nodes in zk
    Then start dble in order
    Given sleep "30" seconds
    Then Monitored folling nodes online
    """
    dble-1
    dble-2
    dble-3
    """
    Then stop dble in "dble-2"
    Given sleep "60" seconds
    Then Monitored folling nodes online
    """
    dble-1
    dble-3
    """
    Given stop dble cluster and zk service