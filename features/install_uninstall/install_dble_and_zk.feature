Feature: #install dble
  Scenario: #install zk cluster in a clean enviroment
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Given config zookeeper cluster in all dble nodes