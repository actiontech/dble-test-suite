# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yexiaoli at 2018/12/13
Feature: install_dble_cluster.feature:to config dble in zk cluster

  @skip_restart
  Scenario: install zk cluster
    Given stop dble cluster and zk service
    Given a clean environment in all dble nodes
    Given install dble in all dble nodes
    Given replace config files in all dbles with command line config
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order