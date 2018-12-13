# Created by yexiaoli at 2018/12/13
Feature: # install_dble_cluster.feature:to config dble in zk cluster

  Scenario: # install zk cluster
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Given config zookeeper cluster in all dble nodes
    Then start dble in order