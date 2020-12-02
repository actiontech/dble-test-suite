# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
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
    Then Monitored folling nodes online
    """
    dble-1
    dble-2
    dble-3
    """
    Then stop dble in "dble-2"
    Then Monitored folling nodes online
    """
    dble-1
    dble-3
    """
    Given stop dble cluster and zk service

  Scenario: verify dnindex.properties should not be empty after restart dble #3
    Given stop dble cluster and zk service
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Given replace config files in all dbles with command line config
    Given config zookeeper cluster in all dble nodes with "all zookeeper hosts"
    Given reset dble registered nodes in zk
    Given Restart dble in "dble-1" success
    Then check following " " exist in file "/opt/dble/conf/dnindex.properties" in "dble-1"
    """
    localhost1=0
    """
    Given stop dble cluster and zk service
