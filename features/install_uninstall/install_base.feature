Feature: #install dble
  Scenario: #install single dble in a clean environment
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Then Start dble in "dble-1"
  Scenario: #change single mode to zk cluster
    Given config zookeeper cluster in all dble nodes
  Scenario: #change zk cluster to single mode
    Given Restore and ensure that all dble nodes are not cluster-mode
  Scenario: #install zk cluster in a clean enviroment
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Given config zookeeper cluster in all dble nodes
  Scenario: #change log level
    Given Set the log level to "debug" and restart server in "dble-1"

  Scenario: #update dble in a base environment
    Given uninstall dble in "dble-1"
    Given install dble in "dble-1"
    Then Start dble in "dble-1"

