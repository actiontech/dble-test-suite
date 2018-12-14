Feature: install dble cluster, degrade to single dble, recover to cluser

  @smoke
  Scenario: install zk cluster, degrade to single dble, recover to cluser
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Given config zookeeper cluster in all dble nodes
    Then start dble in order
    Given stop dble cluster and zk service
    Then Start dble in "dble-1"
    Given config zookeeper cluster in all dble nodes
    Then start dble in order
    Given stop all dbles